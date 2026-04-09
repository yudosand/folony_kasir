<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Login Admin - Folony Kasir</title>
    <style>
        body {
            margin: 0;
            min-height: 100vh;
            display: grid;
            place-items: center;
            background: linear-gradient(180deg, #fff7f2 0%, #f3f4f6 100%);
            font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif;
            color: #111827;
        }
        .login-card {
            width: min(100%, 420px);
            background: white;
            border: 1px solid #e5e7eb;
            border-radius: 24px;
            box-shadow: 0 24px 48px rgba(15, 23, 42, 0.08);
            padding: 28px;
        }
        h1 { margin: 0; font-size: 28px; }
        p { margin: 10px 0 0; color: #6b7280; }
        .field { display: grid; gap: 8px; margin-top: 18px; }
        label { font-size: 14px; font-weight: 700; color: #4b5563; }
        input {
            width: 100%;
            min-height: 46px;
            border-radius: 14px;
            border: 1px solid #d1d5db;
            padding: 0 14px;
            font: inherit;
            box-sizing: border-box;
        }
        .password-field {
            position: relative;
        }
        .password-field input {
            padding-right: 52px;
        }
        .password-toggle {
            position: absolute;
            right: 8px;
            top: 50%;
            transform: translateY(-50%);
            width: 36px;
            height: 36px;
            border: 0;
            border-radius: 10px;
            margin: 0;
            padding: 0;
            background: transparent;
            color: #6b7280;
            font-size: 18px;
            font-weight: 400;
            letter-spacing: 0;
            cursor: pointer;
        }
        .password-toggle:hover {
            background: #f3f4f6;
        }
        .error { margin-top: 6px; color: #b91c1c; font-size: 13px; }
        button {
            width: 100%;
            min-height: 48px;
            margin-top: 22px;
            border-radius: 14px;
            border: 0;
            background: #f97316;
            color: white;
            font: inherit;
            font-weight: 600;
            letter-spacing: 0.01em;
            cursor: pointer;
        }
    </style>
</head>
<body>
    <form method="POST" action="{{ route('admin.login.store') }}" class="login-card">
        @csrf
        <h1>Login Admin</h1>
        <p>Masuk ke dashboard admin Folony Kasir untuk memantau user, invoice, dan transaksi poin.</p>

        <div class="field">
            <label for="user">User Admin</label>
            <input id="user" type="text" name="user" value="{{ old('user') }}" placeholder="Masukkan user admin" required>
            @error('user')
                <div class="error">{{ $message }}</div>
            @enderror
        </div>

        <div class="field">
            <label for="password">Password Admin</label>
            <div class="password-field">
                <input id="password" type="password" name="password" placeholder="Masukkan password admin" required>
                <button type="button" class="password-toggle" data-password-toggle aria-label="Tampilkan password">👁</button>
            </div>
            @error('password')
                <div class="error">{{ $message }}</div>
            @enderror
        </div>

        <button type="submit">Masuk ke Dashboard</button>
    </form>
    <script>
        const toggleButton = document.querySelector('[data-password-toggle]');
        const passwordInput = document.getElementById('password');

        if (toggleButton && passwordInput) {
            toggleButton.addEventListener('click', () => {
                const isHidden = passwordInput.type === 'password';
                passwordInput.type = isHidden ? 'text' : 'password';
                toggleButton.setAttribute(
                    'aria-label',
                    isHidden ? 'Sembunyikan password' : 'Tampilkan password'
                );
                toggleButton.textContent = isHidden ? '🙈' : '👁';
            });
        }
    </script>
</body>
</html>
