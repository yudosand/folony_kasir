<?php

namespace App\Services;

use App\Models\Transaction;
use App\Models\User;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\DB;

class AdminDashboardService
{
    public function overview(): array
    {
        return [
            'total_users' => User::count(),
            'total_products' => DB::table('products')->count(),
            'total_transactions' => Transaction::count(),
            'total_revenue' => (float) Transaction::sum('grand_total'),
            'outstanding_due' => (float) Transaction::sum('due_amount'),
            'points_value_redeemed' => (float) Transaction::sum('member_points_value_amount'),
            'recent_invoices' => Transaction::query()
                ->with('user:id,name,phone')
                ->latest()
                ->take(6)
                ->get(),
            'recent_users' => User::query()
                ->latest()
                ->take(6)
                ->get(),
            'daily_transactions' => $this->dailyTransactions(),
        ];
    }

    public function dailyTransactions(int $days = 7): Collection
    {
        $startDate = now()->subDays($days - 1)->startOfDay();

        return Transaction::query()
            ->selectRaw('DATE(created_at) as transaction_date')
            ->selectRaw('COUNT(*) as total_transactions')
            ->selectRaw('COALESCE(SUM(grand_total), 0) as total_revenue')
            ->where('created_at', '>=', $startDate)
            ->groupBy('transaction_date')
            ->orderBy('transaction_date')
            ->get();
    }
}
