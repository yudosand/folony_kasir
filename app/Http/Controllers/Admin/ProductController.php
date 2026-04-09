<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Product;
use App\Services\AdminDashboardAuthService;
use App\Services\AdminExcelExportService;
use App\Services\AdminProductService;
use Illuminate\Http\Response;
use Illuminate\Http\Request;
use Illuminate\View\View;

class ProductController extends Controller
{
    public function __construct(
        private readonly AdminProductService $productService,
        private readonly AdminDashboardAuthService $authService,
        private readonly AdminExcelExportService $excelExportService,
    ) {
    }

    public function index(Request $request): View
    {
        return view('admin.products.index', [
            'adminUser' => $this->authService->user($request),
            'products' => $this->productService->paginate(
                $request->only('search', 'owner')
            ),
            'filters' => $request->only('search', 'owner'),
        ]);
    }

    public function export(Request $request): Response
    {
        $filters = $request->only('search', 'owner');
        $products = $this->productService->exportRows($filters);

        return $this->excelExportService->download(
            'products_export_'.now()->format('Ymd_His'),
            'Export Products Folony Kasir',
            [
                'Nama Produk',
                'Pemilik',
                'Nomor HP Pemilik',
                'Stok',
                'Harga Modal',
                'Harga Jual',
                'Total Qty Terjual',
                'Tanggal Dibuat',
            ],
            $products->map(fn ($product) => [
                $product->name,
                $product->user?->name ?? '-',
                $product->user?->phone ?: ($product->user?->email ?: '-'),
                number_format($product->stock),
                'Rp '.number_format((float) $product->cost_price, 0, ',', '.'),
                'Rp '.number_format((float) $product->selling_price, 0, ',', '.'),
                number_format((int) ($product->total_quantity_sold ?? 0)),
                $product->created_at?->format('d/m/Y') ?? '-',
            ])->all(),
        );
    }

    public function show(Request $request, Product $product): View
    {
        return view('admin.products.show', [
            'adminUser' => $this->authService->user($request),
            'product' => $this->productService->detail($product),
        ]);
    }
}
