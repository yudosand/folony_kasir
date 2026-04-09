<?php

namespace App\Services;

use Illuminate\Http\Request;
use RuntimeException;

class AdminDashboardAuthService
{
    public function __construct(
        private readonly FoloniAppAdminAuthService $foloniAppAdminAuthService,
    ) {
    }

    public function attempt(string $user, string $password, Request $request): bool
    {
        try {
            $sessionUser = $this->foloniAppAdminAuthService->authenticate($user, $password);
        } catch (RuntimeException) {
            return false;
        }

        return $this->login($sessionUser, $request);
    }

    public function login(array $sessionUser, Request $request): bool
    {
        $request->session()->put($this->sessionKey(), [
            'email' => (string) ($sessionUser['user'] ?? ''),
            'name' => (string) ($sessionUser['name'] ?? config('admin-dashboard.name')),
            'token' => (string) ($sessionUser['token'] ?? ''),
            'payload' => $sessionUser['payload'] ?? [],
            'logged_in_at' => now()->toIso8601String(),
        ]);
        $request->session()->regenerate();

        return true;
    }

    public function isAuthenticated(Request $request): bool
    {
        return $request->session()->has($this->sessionKey());
    }

    public function user(Request $request): array
    {
        return $request->session()->get($this->sessionKey(), []);
    }

    public function logout(Request $request): void
    {
        $request->session()->forget($this->sessionKey());
        $request->session()->invalidate();
        $request->session()->regenerateToken();
    }

    private function sessionKey(): string
    {
        return (string) config('admin-dashboard.session_key');
    }
}
