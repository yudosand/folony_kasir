<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Services\AdminDashboardAuthService;
use App\Services\AdminExcelExportService;
use App\Services\AdminTransactionService;
use Illuminate\Http\Response;
use Illuminate\Http\Request;
use Illuminate\View\View;

class TransactionController extends Controller
{
    public function __construct(
        private readonly AdminTransactionService $transactionService,
        private readonly AdminDashboardAuthService $authService,
        private readonly AdminExcelExportService $excelExportService,
    ) {
    }

    public function index(Request $request): View
    {
        return view('admin.transactions.index', [
            'adminUser' => $this->authService->user($request),
            'transactions' => $this->transactionService->paginate(
                $request->only('search', 'payment_method', 'payment_status', 'date_from', 'date_to')
            ),
            'filters' => $request->only('search', 'payment_method', 'payment_status', 'date_from', 'date_to'),
        ]);
    }

    public function export(Request $request): Response
    {
        $filters = $request->only('search', 'payment_method', 'payment_status', 'date_from', 'date_to');
        $transactions = $this->transactionService->exportRows($filters);

        return $this->excelExportService->download(
            'transactions_export_'.now()->format('Ymd_His'),
            'Export Transactions Folony Kasir',
            [
                'Tanggal',
                'Invoice',
                'User',
                'Metode Pembayaran',
                'Status',
                'Total Item',
                'Grand Total',
                'Total Dibayar',
                'Kurang Bayar',
                'Poin Dipakai',
                'Nilai Poin',
            ],
            $transactions->map(fn ($transaction) => [
                $transaction->created_at?->format('d/m/Y H:i') ?? '-',
                $transaction->invoice_number,
                $transaction->user?->name ?? $transaction->cashier_name_snapshot,
                ucfirst((string) ($transaction->payment_method?->value ?? $transaction->payment_method)),
                ((string) ($transaction->payment_status?->value ?? $transaction->payment_status)) === 'paid' ? 'Lunas' : 'Belum Lunas',
                number_format($transaction->item_count).' item',
                'Rp '.number_format((float) $transaction->grand_total, 0, ',', '.'),
                'Rp '.number_format((float) $transaction->amount_paid + (float) $transaction->member_points_value_amount, 0, ',', '.'),
                'Rp '.number_format((float) $transaction->due_amount, 0, ',', '.'),
                number_format((int) $transaction->member_points_used).' poin',
                'Rp '.number_format((float) $transaction->member_points_value_amount, 0, ',', '.'),
            ])->all(),
        );
    }
}
