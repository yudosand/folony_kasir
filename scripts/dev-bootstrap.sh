#!/usr/bin/env bash

set -euo pipefail

APP_SLUG="folony_kasir"
APP_DIR="/var/www/${APP_SLUG}"
APP_USER="${SUDO_USER:-$USER}"
PHP_VERSION="8.3"

if [[ "${EUID}" -eq 0 ]]; then
  echo "Jalankan script ini sebagai user biasa yang punya akses sudo, bukan sebagai root."
  exit 1
fi

require_sudo() {
  if ! sudo -n true 2>/dev/null; then
    echo "Script ini butuh akses sudo. Kamu mungkin akan diminta memasukkan password sudo."
    sudo -v
  fi
}

prompt_default() {
  local label="$1"
  local default_value="$2"
  local result
  read -r -p "${label} [${default_value}]: " result
  if [[ -z "${result}" ]]; then
    result="${default_value}"
  fi
  printf '%s' "${result}"
}

prompt_secret() {
  local label="$1"
  local result
  read -r -s -p "${label}: " result
  echo
  printf '%s' "${result}"
}

set_env_value() {
  local env_file="$1"
  local key="$2"
  local value="$3"
  local escaped

  escaped=$(printf '%s' "${value}" | sed -e 's/[\/&\\]/\\&/g')

  if grep -q "^${key}=" "${env_file}"; then
    sed -i "s/^${key}=.*/${key}=${escaped}/" "${env_file}"
  else
    printf '\n%s=%s\n' "${key}" "${value}" >> "${env_file}"
  fi
}

write_nginx_config() {
  local server_name="$1"

  sudo tee "/etc/nginx/sites-available/${APP_SLUG}" >/dev/null <<EOF
server {
    listen 80;
    server_name ${server_name};

    root ${APP_DIR}/public;
    index index.php index.html;

    client_max_body_size 10M;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php${PHP_VERSION}-fpm.sock;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

  sudo ln -sfn "/etc/nginx/sites-available/${APP_SLUG}" "/etc/nginx/sites-enabled/${APP_SLUG}"

  if [[ -f /etc/nginx/sites-enabled/default ]]; then
    sudo rm -f /etc/nginx/sites-enabled/default
  fi
}

fix_nginx_ipv6_default() {
  if [[ -f /etc/nginx/sites-available/default ]]; then
    sudo sed -i 's/^[[:space:]]*listen \[::\]:80 default_server;/    # listen [::]:80 default_server;/' /etc/nginx/sites-available/default
    sudo sed -i 's/^[[:space:]]*listen \[::\]:80;/    # listen [::]:80;/' /etc/nginx/sites-available/default
  fi

  if [[ -f /etc/nginx/sites-enabled/default ]]; then
    sudo sed -i 's/^[[:space:]]*listen \[::\]:80 default_server;/    # listen [::]:80 default_server;/' /etc/nginx/sites-enabled/default
    sudo sed -i 's/^[[:space:]]*listen \[::\]:80;/    # listen [::]:80;/' /etc/nginx/sites-enabled/default
  fi
}

install_packages() {
  sudo apt update
  sudo DEBIAN_FRONTEND=noninteractive apt install -y \
    nginx \
    git \
    unzip \
    curl \
    mysql-server \
    composer \
    nodejs \
    npm \
    "php${PHP_VERSION}" \
    "php${PHP_VERSION}-fpm" \
    "php${PHP_VERSION}-cli" \
    "php${PHP_VERSION}-mysql" \
    "php${PHP_VERSION}-mbstring" \
    "php${PHP_VERSION}-xml" \
    "php${PHP_VERSION}-curl" \
    "php${PHP_VERSION}-zip" \
    "php${PHP_VERSION}-gd" \
    "php${PHP_VERSION}-intl" \
    "php${PHP_VERSION}-bcmath"

  fix_nginx_ipv6_default

  sudo ufw allow 80/tcp || true
  sudo ufw allow 443/tcp || true

  sudo nginx -t
  sudo systemctl enable nginx
  sudo systemctl restart nginx
  sudo systemctl enable "php${PHP_VERSION}-fpm"
  sudo systemctl restart "php${PHP_VERSION}-fpm"
  sudo systemctl enable mysql
  sudo systemctl restart mysql
}

setup_database() {
  local db_name="$1"
  local db_user="$2"
  local db_password="$3"

  sudo mysql <<EOF
CREATE DATABASE IF NOT EXISTS \`${db_name}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '${db_user}'@'localhost' IDENTIFIED BY '${db_password}';
ALTER USER '${db_user}'@'localhost' IDENTIFIED BY '${db_password}';
GRANT ALL PRIVILEGES ON \`${db_name}\`.* TO '${db_user}'@'localhost';
FLUSH PRIVILEGES;
EOF
}

clone_or_update_repo() {
  local repo_url="$1"
  local branch_name="$2"

  sudo mkdir -p /var/www
  sudo chown -R "${APP_USER}:${APP_USER}" /var/www

  if [[ ! -d "${APP_DIR}/.git" ]]; then
    git clone --branch "${branch_name}" "${repo_url}" "${APP_DIR}"
  else
    git -C "${APP_DIR}" fetch origin
    git -C "${APP_DIR}" checkout "${branch_name}"
    git -C "${APP_DIR}" pull --ff-only origin "${branch_name}"
  fi
}

configure_laravel() {
  local env_file="${APP_DIR}/.env"
  local app_url="$1"
  local db_name="$2"
  local db_user="$3"
  local db_password="$4"
  local foodukm_login_url="$5"
  local foodukm_register_url="$6"
  local foloni_admin_login_url="$7"
  local foloni_member_points_url="$8"
  local foloni_point_history_url="$9"
  local foloni_point_mutation_url="${10}"
  local foloni_admin_user="${11}"
  local foloni_admin_password="${12}"

  if [[ ! -f "${env_file}" ]]; then
    cp "${APP_DIR}/.env.example" "${env_file}"
  fi

  set_env_value "${env_file}" "APP_NAME" "\"Folony Kasir API\""
  set_env_value "${env_file}" "APP_ENV" "development"
  set_env_value "${env_file}" "APP_DEBUG" "true"
  set_env_value "${env_file}" "APP_URL" "${app_url}"
  set_env_value "${env_file}" "DB_CONNECTION" "mysql"
  set_env_value "${env_file}" "DB_HOST" "127.0.0.1"
  set_env_value "${env_file}" "DB_PORT" "3306"
  set_env_value "${env_file}" "DB_DATABASE" "${db_name}"
  set_env_value "${env_file}" "DB_USERNAME" "${db_user}"
  set_env_value "${env_file}" "DB_PASSWORD" "${db_password}"
  set_env_value "${env_file}" "FILESYSTEM_DISK" "public"
  set_env_value "${env_file}" "FOODUKM_LOGIN_URL" "${foodukm_login_url}"
  set_env_value "${env_file}" "FOODUKM_REGISTER_URL" "${foodukm_register_url}"
  set_env_value "${env_file}" "FOLONI_APP_ADMIN_LOGIN_URL" "${foloni_admin_login_url}"
  set_env_value "${env_file}" "FOLONI_APP_MEMBER_POINTS_URL" "${foloni_member_points_url}"
  set_env_value "${env_file}" "FOLONI_APP_POINT_HISTORY_URL" "${foloni_point_history_url}"
  set_env_value "${env_file}" "FOLONI_APP_POINT_MUTATION_URL" "${foloni_point_mutation_url}"
  set_env_value "${env_file}" "FOLONI_APP_ADMIN_USER" "${foloni_admin_user}"
  set_env_value "${env_file}" "FOLONI_APP_ADMIN_PASSWORD" "${foloni_admin_password}"

  cd "${APP_DIR}"

  composer install --no-interaction --prefer-dist --optimize-autoloader
  npm install
  npm run build

  if grep -q '^APP_KEY=$' "${env_file}" || ! grep -q '^APP_KEY=base64:' "${env_file}"; then
    php artisan key:generate --force
  fi
  php artisan optimize:clear
  php artisan migrate --force
  php artisan storage:link || true

  sudo chown -R www-data:www-data "${APP_DIR}/storage" "${APP_DIR}/bootstrap/cache"
  sudo chmod -R ug+rwx "${APP_DIR}/storage" "${APP_DIR}/bootstrap/cache"
}

main() {
  require_sudo

  local repo_url
  local branch_name
  local server_name
  local app_url
  local db_name
  local db_user
  local db_password
  local foodukm_login_url
  local foodukm_register_url
  local foloni_admin_login_url
  local foloni_member_points_url
  local foloni_point_history_url
  local foloni_point_mutation_url
  local foloni_admin_user
  local foloni_admin_password

  echo "=== Folony Kasir Dev Bootstrap ==="
  repo_url=$(prompt_default "Git repository URL" "https://github.com/yudosand/folony_kasir.git")
  branch_name=$(prompt_default "Git branch" "master")
  server_name=$(prompt_default "Server name / domain (boleh _)" "_")
  app_url=$(prompt_default "APP_URL" "http://$(curl -fsSL ifconfig.me || printf 'localhost')")
  db_name=$(prompt_default "Database name" "folony_pos_dev")
  db_user=$(prompt_default "Database user" "folony_dev")
  db_password=$(prompt_secret "Database password")
  foodukm_login_url=$(prompt_default "FOODUKM_LOGIN_URL" "https://dev.foodukm.com/app/api_login_v2")
  foodukm_register_url=$(prompt_default "FOODUKM_REGISTER_URL" "https://dev.foodukm.com/app/api_registrasi_v2")
  foloni_admin_login_url=$(prompt_default "FOLONI_APP_ADMIN_LOGIN_URL" "https://dev.foodukm.com/adm/user/login")
  foloni_member_points_url=$(prompt_default "FOLONI_APP_MEMBER_POINTS_URL" "https://dev.foodukm.com/adm/finance/poin/member")
  foloni_point_history_url=$(prompt_default "FOLONI_APP_POINT_HISTORY_URL" "https://dev.foodukm.com/adm/finance/poin/history")
  foloni_point_mutation_url=$(prompt_default "FOLONI_APP_POINT_MUTATION_URL" "https://dev.foodukm.com/adm/finance/poin")
  foloni_admin_user=$(prompt_default "FOLONI_APP_ADMIN_USER" "")
  foloni_admin_password=$(prompt_secret "FOLONI_APP_ADMIN_PASSWORD")

  install_packages
  setup_database "${db_name}" "${db_user}" "${db_password}"
  clone_or_update_repo "${repo_url}" "${branch_name}"
  configure_laravel \
    "${app_url}" \
    "${db_name}" \
    "${db_user}" \
    "${db_password}" \
    "${foodukm_login_url}" \
    "${foodukm_register_url}" \
    "${foloni_admin_login_url}" \
    "${foloni_member_points_url}" \
    "${foloni_point_history_url}" \
    "${foloni_point_mutation_url}" \
    "${foloni_admin_user}" \
    "${foloni_admin_password}"
  write_nginx_config "${server_name}"

  sudo nginx -t
  sudo systemctl restart nginx

  echo
  echo "Bootstrap selesai."
  echo "Aplikasi ada di: ${APP_DIR}"
  echo "Coba buka: ${app_url}"
}

main "$@"
