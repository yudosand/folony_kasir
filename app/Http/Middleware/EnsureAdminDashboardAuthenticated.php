<?php

namespace App\Http\Middleware;

use App\Services\AdminDashboardAuthService;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureAdminDashboardAuthenticated
{
    public function __construct(
        private readonly AdminDashboardAuthService $authService,
    ) {
    }

    public function handle(Request $request, Closure $next): Response
    {
        if (! $this->authService->isAuthenticated($request)) {
            return redirect()->route('admin.login');
        }

        return $next($request);
    }
}
