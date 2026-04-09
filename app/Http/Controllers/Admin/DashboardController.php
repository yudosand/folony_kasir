<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Services\AdminDashboardAuthService;
use App\Services\AdminDashboardService;
use Illuminate\View\View;

class DashboardController extends Controller
{
    public function __construct(
        private readonly AdminDashboardService $dashboardService,
        private readonly AdminDashboardAuthService $authService,
    ) {
    }

    public function index(): View
    {
        return view('admin.dashboard.index', [
            'adminUser' => $this->authService->user(request()),
            'overview' => $this->dashboardService->overview(),
        ]);
    }
}
