<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Product;
use App\Services\AdminDashboardAuthService;
use App\Services\AdminExcelExportService;
use App\Services\AdminStockBookkeepingService;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\View\View;

class StockBookkeepingController extends Controller
{
    public function __construct(
        private readonly AdminStockBookkeepingService $stockBookkeepingService,
        private readonly AdminDashboardAuthService $authService,
        private readonly AdminExcelExportService $excelExportService,
    ) {
    }

    public function index(Request $request): View
    {
        $filters = $request->only('search', 'owner', 'status', 'date_from', 'date_to');

        return view('admin.stock-bookkeeping.index', [
            'adminUser' => $this->authService->user($request),
            'products' => $this->stockBookkeepingService->paginate($filters),
            'filters' => $filters,
        ]);
    }

    public function export(Request $request): Response
    {
        $filters = $request->only('search', 'owner', 'status', 'date_from', 'date_to');
        $rows = $this->stockBookkeepingService->exportRows($filters);

        return $this->excelExportService->download(
            'stock_bookkeeping_export_'.now()->format('Ymd_His'),
            'Export Pembukuan Stok Folony Kasir',
            [
                'Nama Produk',
                'Pemilik',
                'Stok Awal',
                'Stok Awal Periode',
                'Stok Masuk',
                'Stok Keluar',
                'Stok Saat Ini',
                'Minimum Stok',
                'Status',
            ],
            $rows->map(fn (Product $product) => [
                $product->name,
                $product->user?->name ?? '-',
                number_format((int) ($product->initial_stock ?? 0)),
                number_format((int) ($product->stock_at_period_start ?? 0)),
                number_format((int) ($product->stock_in ?? 0)),
                number_format((int) ($product->stock_out ?? 0)),
                number_format((int) $product->stock),
                number_format((int) $product->minimum_stock),
                $product->stock_status_label ?? '-',
            ])->all(),
        );
    }

    public function show(Request $request, Product $product): View
    {
        return view('admin.stock-bookkeeping.show', [
            'adminUser' => $this->authService->user($request),
            'detail' => $this->stockBookkeepingService->detail(
                $product,
                $request->only('date_from', 'date_to'),
            ),
            'filters' => $request->only('date_from', 'date_to'),
        ]);
    }
}
