<?php

namespace App\Services;

use App\Models\User;
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

    public function reportForUser(User $user, array $filters = []): array
    {
        $rows = $this->rowsForUser($user, $filters);

        $totalRevenue = (float) $rows->sum('total_selling');
        $totalCost = (float) $rows->sum('total_cost');
        $totalProfit = (float) $rows->sum('total_profit');
        $summary = [
            'transaction_count' => $rows->pluck('transaction_id')->unique()->count(),
            'quantity_sold' => (int) $rows->sum('quantity'),
            'total_revenue' => round($totalRevenue, 2),
            'total_cost' => round($totalCost, 2),
            'total_profit' => round($totalProfit, 2),
            'profit_margin_percent' => $totalRevenue > 0
                ? round(($totalProfit / $totalRevenue) * 100, 2)
                : 0.0,
        ];

        return [
            'summary' => $summary,
            'rows' => $rows->map(function (object $row): array {
                return [
                    'id' => (int) $row->id,
                    'transaction_id' => (int) $row->transaction_id,
                    'invoice_number' => $row->invoice_number,
                    'transaction_date' => optional($row->transaction_date)?->toISOString()
                        ?? $row->transaction_date,
                    'payment_method' => $row->payment_method,
                    'payment_status' => $row->payment_status,
                    'cashier_name' => $row->cashier_name,
                    'product_name' => $row->product_name_snapshot,
                    'quantity' => (int) $row->quantity,
                    'cost_price' => round((float) $row->cost_price_snapshot, 2),
                    'selling_price' => round((float) $row->selling_price_snapshot, 2),
                    'total_cost' => round((float) $row->total_cost, 2),
                    'total_selling' => round((float) $row->total_selling, 2),
                    'total_profit' => round((float) $row->total_profit, 2),
                ];
            })->values(),
        ];
    }

    private function rowsQuery(array $filters = [], ?User $user = null): Builder
    {
        return $this->filteredQuery($filters, $user)
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

    private function summaryQuery(array $filters = [], ?User $user = null): Builder
    {
        return $this->filteredQuery($filters, $user)
            ->selectRaw('
                COUNT(DISTINCT transactions.id) as transaction_count,
                COALESCE(SUM(transaction_items.quantity), 0) as quantity_sold,
                COALESCE(SUM(transaction_items.line_subtotal), 0) as total_revenue,
                COALESCE(SUM(transaction_items.quantity * transaction_items.cost_price_snapshot), 0) as total_cost,
                COALESCE(SUM(transaction_items.line_subtotal - (transaction_items.quantity * transaction_items.cost_price_snapshot)), 0) as total_profit
            ');
    }

    private function rowsForUser(User $user, array $filters = []): Collection
    {
        return $this->rowsQuery($filters, $user)->get();
    }

    private function filteredQuery(array $filters = [], ?User $user = null): Builder
    {
        $search = trim((string) ($filters['search'] ?? ''));
        $paymentMethod = trim((string) ($filters['payment_method'] ?? ''));
        $dateFrom = trim((string) ($filters['date_from'] ?? ''));
        $dateTo = trim((string) ($filters['date_to'] ?? ''));
        $profitStatus = trim((string) ($filters['profit_status'] ?? ''));

        return DB::table('transaction_items')
            ->join('transactions', 'transactions.id', '=', 'transaction_items.transaction_id')
            ->leftJoin('users', 'users.id', '=', 'transactions.user_id')
            ->when($user !== null, fn (Builder $query) => $query->where('transactions.user_id', $user->id))
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
