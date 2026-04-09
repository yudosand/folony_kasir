<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Services\AdminDashboardAuthService;
use App\Services\AdminExcelExportService;
use App\Services\AdminUserService;
use Illuminate\Http\Response;
use Illuminate\Http\Request;
use Illuminate\View\View;

class UserController extends Controller
{
    public function __construct(
        private readonly AdminUserService $userService,
        private readonly AdminDashboardAuthService $authService,
        private readonly AdminExcelExportService $excelExportService,
    ) {
    }

    public function index(Request $request): View
    {
        return view('admin.users.index', [
            'adminUser' => $this->authService->user($request),
            'users' => $this->userService->paginate($request->only('search')),
            'filters' => $request->only('search'),
        ]);
    }

    public function export(Request $request): Response
    {
        $filters = $request->only('search');
        $users = $this->userService->exportRows($filters);

        return $this->excelExportService->download(
            'users_export_'.now()->format('Ymd_His'),
            'Export Users Folony Kasir',
            [
                'Nama',
                'Nomor HP',
                'Email',
                'Tanggal Bergabung',
                'Member ID Foloni App',
                'Total Produk',
                'Total Transaksi',
                'Total Omzet',
            ],
            $users->map(fn ($user) => [
                $user->name,
                $user->phone ?: '-',
                $user->email ?: '-',
                $user->created_at?->format('d/m/Y') ?? '-',
                $user->external_member_id ?: '-',
                number_format($user->products_count),
                number_format($user->transactions_count),
                'Rp '.number_format((float) ($user->total_transaction_value ?? 0), 0, ',', '.'),
            ])->all(),
        );
    }

    public function show(Request $request, User $user): View
    {
        $detail = $this->userService->detail($user);

        return view('admin.users.show', [
            'adminUser' => $this->authService->user($request),
            'userDetail' => $detail['user'],
            'products' => $detail['products'],
            'transactions' => $detail['transactions'],
        ]);
    }
}
