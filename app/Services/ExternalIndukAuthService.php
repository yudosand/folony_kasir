<?php

namespace App\Services;

use Illuminate\Support\Arr;
use Illuminate\Support\Facades\Http;
use Illuminate\Validation\ValidationException;
use RuntimeException;

class ExternalIndukAuthService
{
    public function register(array $payload): array
    {
        $registerUrl = (string) config('services.foodukm_auth.register_url');

        if ($registerUrl === '') {
            throw new RuntimeException('URL daftar induk belum dikonfigurasi.');
        }

        $phone = (string) $payload['phone'];
        $requestPayload = [
            'nama' => $payload['name'],
            'email' => $payload['email'] ?? sprintf('%s@folony-kasir.local', preg_replace('/\D+/', '', $phone) ?: 'user'),
            'pass' => $payload['password'],
            'nomor_hp' => $phone,
            'os_version' => $payload['os_version'] ?? 'android',
            'firebase_token' => $payload['fcm_token'] ?? '',
            'idDevice' => $payload['id_device'] ?? 'folony-kasir-device',
            'referall' => $payload['referal'],
            'is_outlet' => $payload['is_outlet'] ?? 0,
            'outlet_name' => $payload['outlet_name'] ?? '',
            'outlet_address' => $payload['outlet_address'] ?? '',
            'outlet_province' => $payload['outlet_province'] ?? '',
            'outlet_city' => $payload['outlet_city'] ?? '',
            'outlet_subdistrict' => $payload['outlet_subdistrict'] ?? '',
            'outlet_business' => $payload['outlet_business'] ?? '',
        ];

        try {
            $response = Http::asForm()
                ->acceptJson()
                ->timeout(20)
                ->post($registerUrl, $requestPayload);
        } catch (\Throwable $exception) {
            throw new RuntimeException(
                'Layanan daftar induk sedang bermasalah. Coba lagi sebentar ya.',
                previous: $exception,
            );
        }

        if (! $response->ok()) {
            throw new RuntimeException('Layanan daftar induk sedang bermasalah. Coba lagi sebentar ya.');
        }

        $body = $response->json();
        if (! is_array($body)) {
            throw new RuntimeException('Respons daftar induk tidak valid. Coba lagi sebentar ya.');
        }

        if ((int) ($body['statusCode'] ?? 0) !== 1) {
            $message = $this->normalizeRegisterMessage(
                (string) ($body['message'] ?? 'Pendaftaran belum berhasil. Coba lagi ya.')
            );
            $errorKey = str_contains(strtolower($message), 'referal')
                || str_contains(strtolower($message), 'kode referal')
                ? 'referal'
                : 'phone';

            throw ValidationException::withMessages([
                $errorKey => [$message !== '' ? $message : 'Pendaftaran belum berhasil. Coba lagi ya.'],
            ]);
        }

        return $body;
    }

    public function authenticate(array $payload): array
    {
        $loginUrl = (string) config('services.foodukm_auth.login_url');

        if ($loginUrl === '') {
            throw new RuntimeException('URL login induk belum dikonfigurasi.');
        }

        $requestPayload = [
            'fuserid' => $payload['phone'],
            'fpassword' => $payload['password'],
            'fcm_token' => $payload['fcm_token'] ?? '',
            'lat' => $payload['lat'] ?? '',
            'long' => $payload['long'] ?? '',
            'idDevice' => $payload['id_device'] ?? 'folony-kasir-device',
            'os_version' => $payload['os_version'] ?? 'android',
        ];

        try {
            $response = Http::asForm()
                ->acceptJson()
                ->timeout(20)
                ->post($loginUrl, $requestPayload);
        } catch (\Throwable $exception) {
            throw new RuntimeException(
                'Layanan login induk sedang bermasalah. Coba lagi sebentar ya.',
                previous: $exception,
            );
        }

        if (! $response->ok()) {
            throw new RuntimeException('Layanan login induk sedang bermasalah. Coba lagi sebentar ya.');
        }

        $body = $response->json();
        if (! is_array($body)) {
            throw new RuntimeException('Respons login induk tidak valid. Coba lagi sebentar ya.');
        }

        if ((int) ($body['statusCode'] ?? 0) !== 1) {
            $message = $this->normalizeLoginMessage(
                (string) ($body['message'] ?? 'Nomor HP atau password belum cocok. Coba cek lagi ya.')
            );
            throw ValidationException::withMessages([
                'phone' => [$message !== '' ? $message : 'Nomor HP atau password belum cocok. Coba cek lagi ya.'],
            ]);
        }

        $result = Arr::get($body, 'result');
        if (! is_array($result)) {
            throw new RuntimeException('Data login induk belum lengkap. Coba lagi sebentar ya.');
        }

        return [
            'raw' => $body,
            'result' => $result,
            'token' => (string) ($result['token'] ?? ''),
        ];
    }

    private function normalizeLoginMessage(string $message): string
    {
        $normalized = strtolower(trim($message));

        if ($normalized === '') {
            return 'Nomor HP atau password belum cocok. Coba cek lagi ya.';
        }

        if (str_contains($normalized, 'password') || str_contains($normalized, 'userid')) {
            return 'Nomor HP atau password belum cocok. Coba cek lagi ya.';
        }

        if (str_contains($normalized, 'login')) {
            return 'Login belum berhasil. Coba lagi ya.';
        }

        return trim($message);
    }

    private function normalizeRegisterMessage(string $message): string
    {
        $normalized = strtolower(trim($message));

        if ($normalized === '') {
            return 'Pendaftaran belum berhasil. Coba lagi ya.';
        }

        if (str_contains($normalized, 'refer')) {
            return 'Kode referal belum sesuai. Coba cek lagi ya.';
        }

        if (str_contains($normalized, 'nomor') || str_contains($normalized, 'phone') || str_contains($normalized, 'hp')) {
            if (str_contains($normalized, 'terdaftar') || str_contains($normalized, 'already')) {
                return 'Nomor HP ini sudah terdaftar. Coba login ya.';
            }

            return 'Nomor HP belum valid. Coba cek lagi ya.';
        }

        if (str_contains($normalized, 'nama')) {
            return 'Nama wajib diisi ya.';
        }

        if (str_contains($normalized, 'password') || str_contains($normalized, 'pass')) {
            return 'Password belum sesuai. Coba cek lagi ya.';
        }

        return trim($message);
    }
}
