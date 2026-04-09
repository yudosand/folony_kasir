<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Services\AdminDashboardAuthService;
use App\Services\FoloniAppAdminAuthService;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\View\View;

class AuthController extends Controller
{
    public function __construct(
        private readonly AdminDashboardAuthService $authService,
        private readonly FoloniAppAdminAuthService $foloniAppAdminAuthService,
    ) {
    }

    public function create(): View
    {
        return view('admin.auth.login');
    }

    public function store(Request $request): RedirectResponse
    {
        $credentials = $request->validate([
            'user' => ['required', 'string'],
            'password' => ['required', 'string'],
        ], [
            'user.required' => 'User admin wajib diisi.',
            'password.required' => 'Password admin wajib diisi.',
        ]);

        try {
            $sessionUser = $this->foloniAppAdminAuthService->authenticate(
                $credentials['user'],
                $credentials['password'],
            );
        } catch (\RuntimeException $exception) {
            return back()
                ->withInput($request->except('password'))
                ->withErrors([
                    'user' => $exception->getMessage(),
                ]);
        }

        $this->authService->login($sessionUser, $request);

        return redirect()->route('admin.dashboard');
    }

    public function destroy(Request $request): RedirectResponse
    {
        $this->authService->logout($request);

        return redirect()
            ->route('admin.login')
            ->with('status', 'Sesi admin sudah berakhir.');
    }
}
