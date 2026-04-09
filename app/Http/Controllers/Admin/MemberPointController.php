<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Services\AdminDashboardAuthService;
use App\Services\AdminExcelExportService;
use App\Services\AdminMemberPointService;
use Illuminate\Http\Response;
use Illuminate\Http\Request;
use Illuminate\View\View;

class MemberPointController extends Controller
{
    public function __construct(
        private readonly AdminMemberPointService $memberPointService,
        private readonly AdminDashboardAuthService $authService,
        private readonly AdminExcelExportService $excelExportService,
    ) {
    }

    public function index(Request $request): View
    {
        return view('admin.member-points.index', [
            'adminUser' => $this->authService->user($request),
            'mutations' => $this->memberPointService->paginate(
                $request->only('search', 'status', 'date_from', 'date_to')
            ),
            'filters' => $request->only('search', 'status', 'date_from', 'date_to'),
        ]);
    }

    public function export(Request $request): Response
    {
        $filters = $request->only('search', 'status', 'date_from', 'date_to');
        $mutations = $this->memberPointService->exportRows($filters);

        return $this->excelExportService->download(
            'member_points_export_'.now()->format('Ymd_His'),
            'Export Member Points Folony Kasir',
            [
                'Tanggal',
                'Invoice',
                'User Kasir',
                'Member ID',
                'Nama Member',
                'Poin Dipakai',
                'Nilai Rupiah',
                'Status Sinkron',
            ],
            $mutations->map(fn ($mutation) => [
                $mutation->created_at?->format('d/m/Y H:i') ?? '-',
                $mutation->invoice_number,
                $mutation->user?->name ?? $mutation->cashier_name_snapshot,
                $mutation->member_external_id ?: '-',
                $mutation->member_name_snapshot ?: '-',
                number_format((int) $mutation->member_points_used).' poin',
                'Rp '.number_format((float) $mutation->member_points_value_amount, 0, ',', '.'),
                (string) ($mutation->member_point_status ?: 'unknown'),
            ])->all(),
        );
    }
}
