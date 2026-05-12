<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Services\AdminDashboardAuthService;
use App\Services\AdminExcelExportService;
use App\Services\SalesProfitReportService;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\View\View;

class SalesProfitReportController extends Controller
{
    public function __construct(
        private readonly SalesProfitReportService $salesProfitReportService,
        private readonly AdminDashboardAuthService $authService,
        private readonly AdminExcelExportService $excelExportService,
    ) {
    }

    public function index(Request $request): View
    {
        $filters = $request->only('search', 'payment_method', 'profit_status', 'date_from', 'date_to');

        return view('admin.sales-profit.index', [
            'adminUser' => $this->authService->user($request),
            'filters' => $filters,
            'summary' => $this->salesProfitReportService->summary($filters),
            'rows' => $this->salesProfitReportService->paginate($filters),
        ]);
    }

    public function export(Request $request): Response
    {
        $filters = $request->only('search', 'payment_method', 'profit_status', 'date_from', 'date_to');
        $rows = $this->salesProfitReportService->exportRows($filters);

        return $this->excelExportService->download(
            'sales_profit_report_'.now()->format('Ymd_His'),
            'Laporan Penjualan & Profit Folony Kasir',
            [
                'Tanggal',
                'Invoice',
                'Kasir',
                'Produk',
                'Qty',
                'Metode Pembayaran',
                'Harga Modal',
                'Harga Jual',
                'Total Modal',
                'Total Jual',
                'Profit',
            ],
            $rows->map(fn ($row) => [
                $row->transaction_date ? date('d/m/Y H:i', strtotime((string) $row->transaction_date)) : '-',
                $row->invoice_number,
                $row->cashier_name,
                $row->product_name_snapshot,
                number_format((int) $row->quantity),
                ucfirst((string) $row->payment_method),
                'Rp '.number_format((float) $row->cost_price_snapshot, 0, ',', '.'),
                'Rp '.number_format((float) $row->selling_price_snapshot, 0, ',', '.'),
                'Rp '.number_format((float) $row->total_cost, 0, ',', '.'),
                'Rp '.number_format((float) $row->total_selling, 0, ',', '.'),
                'Rp '.number_format((float) $row->total_profit, 0, ',', '.'),
            ])->all(),
        );
    }
}
