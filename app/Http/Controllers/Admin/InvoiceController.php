<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Transaction;
use App\Services\AdminDashboardAuthService;
use App\Services\AdminExcelExportService;
use App\Services\AdminInvoiceService;
use Illuminate\Http\Response;
use Illuminate\Http\Request;
use Illuminate\View\View;

class InvoiceController extends Controller
{
    public function __construct(
        private readonly AdminInvoiceService $invoiceService,
        private readonly AdminDashboardAuthService $authService,
        private readonly AdminExcelExportService $excelExportService,
    ) {
    }

    public function index(Request $request): View
    {
        return view('admin.invoices.index', [
            'adminUser' => $this->authService->user($request),
            'invoices' => $this->invoiceService->paginate(
                $request->only('search', 'payment_method', 'payment_status', 'date_from', 'date_to')
            ),
            'filters' => $request->only('search', 'payment_method', 'payment_status', 'date_from', 'date_to'),
        ]);
    }

    public function export(Request $request): Response
    {
        $filters = $request->only('search', 'payment_method', 'payment_status', 'date_from', 'date_to');
        $invoices = $this->invoiceService->exportRows($filters);

        return $this->excelExportService->download(
            'invoices_export_'.now()->format('Ymd_His'),
            'Export Invoices Folony Kasir',
            [
                'Tanggal',
                'Nomor Invoice',
                'Nama User',
                'Total Item',
                'Subtotal',
                'Grand Total',
                'Metode Pembayaran',
                'Status',
            ],
            $invoices->map(fn ($invoice) => [
                $invoice->created_at?->format('d/m/Y H:i') ?? '-',
                $invoice->invoice_number,
                $invoice->user?->name ?? $invoice->cashier_name_snapshot,
                number_format($invoice->item_count).' item',
                'Rp '.number_format((float) $invoice->subtotal, 0, ',', '.'),
                'Rp '.number_format((float) $invoice->grand_total, 0, ',', '.'),
                ucfirst((string) ($invoice->payment_method?->value ?? $invoice->payment_method)),
                ((string) ($invoice->payment_status?->value ?? $invoice->payment_status)) === 'paid' ? 'Lunas' : 'Belum Lunas',
            ])->all(),
        );
    }

    public function show(Request $request, Transaction $transaction): View
    {
        return view('admin.invoices.show', [
            'adminUser' => $this->authService->user($request),
            'invoice' => $this->invoiceService->detail($transaction),
        ]);
    }
}
