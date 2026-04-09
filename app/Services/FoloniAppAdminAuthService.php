<?php

namespace App\Services;

use Illuminate\Http\Client\Response;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Http;
use RuntimeException;

class FoloniAppAdminAuthService
{
    private const TOKEN_CACHE_KEY = 'foloni_app_admin_access_token';

    public function authenticate(string $user, string $password): array
    {
        $payload = $this->loginAndFetchPayload($user, $password);

        return [
            'token' => (string) data_get($payload, 'result.token', ''),
            'user' => trim($user),
            'name' => (string) data_get($payload, 'result.name', trim($user)),
            'payload' => $payload,
        ];
    }

    public function getAccessToken(): string
    {
        $cachedToken = Cache::get(self::TOKEN_CACHE_KEY);

        if (is_string($cachedToken) && $cachedToken !== '') {
            return $cachedToken;
        }

        $token = $this->loginAndFetchToken();

        Cache::put(
            self::TOKEN_CACHE_KEY,
            $token,
            now()->addMinutes(max(1, (int) config('services.foloni_app_admin.token_cache_minutes', 30))),
        );

        return $token;
    }

    public function forgetAccessToken(): void
    {
        Cache::forget(self::TOKEN_CACHE_KEY);
    }

    public function authorizedGet(string $url, array $query = []): Response
    {
        $response = $this->sendAuthorizedGet($url, $query, $this->getAccessToken());

        if ($this->shouldRefreshAccessToken($response)) {
            $this->forgetAccessToken();
            $response = $this->sendAuthorizedGet($url, $query, $this->getAccessToken());
        }

        return $response;
    }

    public function authorizedPost(string $url, array $payload = []): Response
    {
        $response = $this->sendAuthorizedPost($url, $payload, $this->getAccessToken());

        if ($this->shouldRefreshAccessToken($response)) {
            $this->forgetAccessToken();
            $response = $this->sendAuthorizedPost($url, $payload, $this->getAccessToken());
        }

        return $response;
    }

    private function loginAndFetchToken(): string
    {
        $user = (string) config('services.foloni_app_admin.user');
        $password = (string) config('services.foloni_app_admin.password');

        if ($user === '' || $password === '') {
            throw new RuntimeException('Konfigurasi admin Foloni App belum lengkap.');
        }

        $payload = $this->loginAndFetchPayload($user, $password);
        $token = (string) data_get($payload, 'result.token', '');

        if ($token === '') {
            throw new RuntimeException('Token admin Foloni App belum tersedia. Coba lagi sebentar ya.');
        }

        return $token;
    }

    private function loginAndFetchPayload(string $user, string $password): array
    {
        $loginUrl = (string) config('services.foloni_app_admin.login_url');

        if ($loginUrl === '' || trim($user) === '' || $password === '') {
            throw new RuntimeException('Konfigurasi admin Foloni App belum lengkap.');
        }

        try {
            $response = Http::acceptJson()
                ->asJson()
                ->timeout(20)
                ->post($loginUrl, [
                    'user' => trim($user),
                    'pass' => $password,
                ]);
        } catch (\Throwable $exception) {
            throw new RuntimeException(
                'Layanan admin Foloni App sedang bermasalah. Coba lagi sebentar ya.',
                previous: $exception,
            );
        }

        if (! $response->ok()) {
            throw new RuntimeException('Login admin Foloni App belum berhasil. Coba lagi sebentar ya.');
        }

        $body = $response->json();

        if (! is_array($body) || (int) ($body['status_code'] ?? 0) !== 1) {
            throw new RuntimeException('Login admin Foloni App belum berhasil. Coba lagi sebentar ya.');
        }

        if ((string) data_get($body, 'result.token', '') === '') {
            throw new RuntimeException('Token admin Foloni App belum tersedia. Coba lagi sebentar ya.');
        }

        return $body;
    }

    private function sendAuthorizedGet(string $url, array $query, string $token): Response
    {
        try {
            return Http::acceptJson()
                ->withToken($token)
                ->timeout(20)
                ->get($url, $query);
        } catch (\Throwable $exception) {
            throw new RuntimeException(
                'Layanan member Foloni App sedang bermasalah. Coba lagi sebentar ya.',
                previous: $exception,
            );
        }
    }

    private function sendAuthorizedPost(string $url, array $payload, string $token): Response
    {
        try {
            return Http::acceptJson()
                ->asJson()
                ->withToken($token)
                ->timeout(20)
                ->post($url, $payload);
        } catch (\Throwable $exception) {
            throw new RuntimeException(
                'Layanan member Foloni App sedang bermasalah. Coba lagi sebentar ya.',
                previous: $exception,
            );
        }
    }

    private function shouldRefreshAccessToken(Response $response): bool
    {
        if ($response->status() === 401) {
            return true;
        }

        $body = $response->json();
        $message = strtolower(trim((string) ($body['message'] ?? '')));

        return (int) ($body['statusCode'] ?? 0) === 400
            && str_contains($message, 'header');
    }
}
