<?php

namespace App\Services;

use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Database\Query\Builder;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\DB;

class SalesProfitReportService
{
    public function paginate(array $filters = []): LengthAwarePaginator
    {
        return $this->rowsQuery($filters)
            ->paginate(20)
            ->withQueryString();
    }

    public function exportRows(array $filters = []): Collection
    {
        return $this->rowsQuery($filters)->get();
    }

    public function summary(array $filters = []): array
    {
        $summary = $this->summaryQuery($filters)->first();

        $totalRevenue = (float) ($summary->total_revenue ?? 0);
        $totalCost = (float) ($summary->total_cost ?? 0);
        $totalProfit = (float) ($summary->total_profit ?? 0);

        return [
            'transaction_count' => (int) ($summary->transaction_count ?? 0),
            'quantity_sold' => (int) ($summary->quantity_sold ?? 0),
            'total_revenue' => round($totalRevenue, 2),
            'total_cost' => round($totalCost, 2),
            'total_profit' => round($totalProfit, 2),
            'profit_margin_percent' => $totalRevenue > 0
                ? round(($totalProfit / $totalRevenue) * 100, 2)
                : 0.0,
        ];
    }

    private function rowsQuery(array $filters = []): Builder
    {
        return $this->filteredQuery($filters)
            ->selectRaw('
                transaction_items.id,
                transactions.id as transaction_id,
                transactions.invoice_number,
                transactions.created_at as transaction_date,
                transactions.payment_method,
                transactions.payment_status,
                COALESCE(users.name, transactions.cashier_name_snapshot) as cashier_name,
                transaction_items.product_name_snapshot,
                transaction_items.quantity,
                transaction_items.cost_price_snapshot,
                transaction_items.selling_price_snapshot,
                transaction_items.line_subtotal as total_selling,
                (transaction_items.quantity * transaction_items.cost_price_snapshot) as total_cost,
                (transaction_items.line_subtotal - (transaction_items.quantity * transaction_items.cost_price_snapshot)) as total_profit
            ')
            ->orderByDesc('transactions.created_at')
            ->orderByDesc('transaction_items.id');
    }

    private function summaryQuery(array $filters = []): Builder
    {
        return $this->filteredQuery($filters)
            ->selectRaw('
                COUNT(DISTINCT transactions.id) as transaction_count,
                COALESCE(SUM(transaction_items.quantity), 0) as quantity_sold,
                COALESCE(SUM(transaction_items.line_subtotal), 0) as total_revenue,
                COALESCE(SUM(transaction_items.quantity * transaction_items.cost_price_snapshot), 0) as total_cost,
                COALESCE(SUM(transaction_items.line_subtotal - (transaction_items.quantity * transaction_items.cost_price_snapshot)), 0) as total_profit
            ');
    }

    private function filteredQuery(array $filters = []): Builder
    {
        $search = trim((string) ($filters['search'] ?? ''));
        $paymentMethod = trim((string) ($filters['payment_method'] ?? ''));
        $dateFrom = trim((string) ($filters['date_from'] ?? ''));
        $dateTo = trim((string) ($filters['date_to'] ?? ''));
        $profitStatus = trim((string) ($filters['profit_status'] ?? ''));

        return DB::table('transaction_items')
            ->join('transactions', 'transactions.id', '=', 'transaction_items.transaction_id')
            ->leftJoin('users', 'users.id', '=', 'transactions.user_id')
            ->when($search !== '', function (Builder $query) use ($search) {
                $query->where(function (Builder $builder) use ($search) {
                    $builder
                        ->where('transactions.invoice_number', 'like', "%{$search}%")
                        ->orWhere('transaction_items.product_name_snapshot', 'like', "%{$search}%")
                        ->orWhere('users.name', 'like', "%{$search}%")
                        ->orWhere('transactions.cashier_name_snapshot', 'like', "%{$search}%");
                });
            })
            ->when($paymentMethod !== '', fn (Builder $query) => $query->where('transactions.payment_method', $paymentMethod))
            ->when($dateFrom !== '', fn (Builder $query) => $query->whereDate('transactions.created_at', '>=', $dateFrom))
            ->when($dateTo !== '', fn (Builder $query) => $query->whereDate('transactions.created_at', '<=', $dateTo))
            ->when($profitStatus !== '', function (Builder $query) use ($profitStatus) {
                return match ($profitStatus) {
                    'profit' => $query->whereRaw('transaction_items.line_subtotal - (transaction_items.quantity * transaction_items.cost_price_snapshot) > 0'),
                    'break_even' => $query->whereRaw('transaction_items.line_subtotal - (transaction_items.quantity * transaction_items.cost_price_snapshot) = 0'),
                    'loss' => $query->whereRaw('transaction_items.line_subtotal - (transaction_items.quantity * transaction_items.cost_price_snapshot) < 0'),
                    default => $query,
                };
            });
    }
}
