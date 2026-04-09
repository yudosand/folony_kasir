<?php

namespace App\Services;

use App\Models\User;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;

class AuthService
{
    public function __construct(
        private readonly ExternalIndukAuthService $externalIndukAuthService,
    ) {
    }

    public function register(array $payload): array
    {
        if (filled($payload['phone'] ?? null)) {
            $this->externalIndukAuthService->register($payload);

            return $this->loginViaExternalAuth([
                'phone' => $payload['phone'],
                'password' => $payload['password'],
                'fcm_token' => $payload['fcm_token'] ?? '',
                'id_device' => $payload['id_device'] ?? null,
                'os_version' => $payload['os_version'] ?? null,
            ]);
        }

        $user = User::create($payload);
        $token = $this->issueToken($user);

        return compact('user', 'token');
    }

    public function login(array $payload): array
    {
        if (filled($payload['phone'] ?? null)) {
            try {
                return $this->loginViaExternalAuth($payload);
            } catch (ValidationException $exception) {
                $fallbackUser = $this->attemptLocalPhoneLogin(
                    phone: (string) $payload['phone'],
                    password: (string) $payload['password'],
                );

                if ($fallbackUser) {
                    $token = $this->issueToken($fallbackUser);

                    return [
                        'user' => $fallbackUser,
                        'token' => $token,
                    ];
                }

                throw $exception;
            }
        }

        $user = User::query()->where('email', $payload['email'])->first();

        if (! $user || ! Hash::check($payload['password'], $user->password)) {
            throw ValidationException::withMessages([
                'email' => ['The provided credentials are incorrect.'],
            ]);
        }

        $token = $this->issueToken($user);

        return compact('user', 'token');
    }

    public function logout(User $user): void
    {
        $currentToken = $user->currentAccessToken();

        if ($currentToken) {
            $currentToken->delete();

            return;
        }

        $user->tokens()->delete();
    }

    private function issueToken(User $user): string
    {
        $user->tokens()->delete();

        return $user->createToken('auth_token')->plainTextToken;
    }

    private function loginViaExternalAuth(array $payload): array
    {
        $externalAuth = $this->externalIndukAuthService->authenticate($payload);
        $externalUser = $externalAuth['result'];
        $externalName = trim((string) ($externalUser['name'] ?? ''));
        $externalEmail = trim((string) ($externalUser['email'] ?? ''));
        $externalMemberId = trim((string) ($externalUser['idmember'] ?? ''));
        $externalPhone = trim((string) ($externalUser['hp'] ?? $payload['phone']));

        $user = $this->findUserForExternalAuth($externalUser, (string) $payload['phone']);
        $user->fill([
            'name' => $externalName !== '' ? $externalName : ($user->name ?? $externalPhone),
            'email' => $externalEmail !== '' ? $externalEmail : $user->email,
            'phone' => $externalPhone,
            'external_member_id' => $externalMemberId !== '' ? $externalMemberId : $user->external_member_id,
            'account_type' => $externalUser['accountType'] ?? $user->account_type,
            'default_lat' => data_get($externalUser, 'defaultLocation.lat'),
            'default_long' => data_get($externalUser, 'defaultLocation.long'),
            'external_auth_token' => $externalAuth['token'] !== '' ? $externalAuth['token'] : $user->external_auth_token,
            'external_profile_payload' => $externalAuth['raw'],
            'external_synced_at' => now(),
        ]);

        if (! $user->exists) {
            $user->password = Str::random(40);
        }

        $user->save();

        $token = $this->issueToken($user);

        return compact('user', 'token');
    }

    private function findUserForExternalAuth(array $externalUser, string $phone): User
    {
        $externalMemberId = (string) ($externalUser['idmember'] ?? '');
        $email = trim((string) ($externalUser['email'] ?? ''));
        $query = User::query()->where('phone', $phone);

        if ($externalMemberId !== '') {
            $query->orWhere('external_member_id', $externalMemberId);
        }

        if ($email !== '') {
            $query->orWhere('email', $email);
        }

        return $query->first() ?? new User();
    }

    private function attemptLocalPhoneLogin(string $phone, string $password): ?User
    {
        $user = User::query()->where('phone', $phone)->first();

        if (! $user || ! Hash::check($password, $user->password)) {
            return null;
        }

        return $user;
    }
}
