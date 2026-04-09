<?php

namespace App\Services;

use App\Models\Transaction;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Support\Collection;

class AdminInvoiceService
{
    public function paginate(array $filters = []): LengthAwarePaginator
    {
        return $this->baseQuery($filters)
            ->paginate(15)
            ->withQueryString();
    }

    public function exportRows(array $filters = []): Collection
    {
        return $this->baseQuery($filters)->get();
    }

    private function baseQuery(array $filters = []): Builder
    {
        $search = trim((string) ($filters['search'] ?? ''));
        $paymentMethod = trim((string) ($filters['payment_method'] ?? ''));
        $paymentStatus = trim((string) ($filters['payment_status'] ?? ''));
        $dateFrom = trim((string) ($filters['date_from'] ?? ''));
        $dateTo = trim((string) ($filters['date_to'] ?? ''));

        return Transaction::query()
            ->with('user:id,name,phone,email')
            ->when($search !== '', function ($query) use ($search) {
                $query->where(function ($builder) use ($search) {
                    $builder
                        ->where('invoice_number', 'like', "%{$search}%")
                        ->orWhere('cashier_name_snapshot', 'like', "%{$search}%")
                        ->orWhere('member_name_snapshot', 'like', "%{$search}%")
                        ->orWhereHas('user', function ($userQuery) use ($search) {
                            $userQuery
                                ->where('name', 'like', "%{$search}%")
                                ->orWhere('phone', 'like', "%{$search}%")
                                ->orWhere('email', 'like', "%{$search}%");
                        });
                });
            })
            ->when($paymentMethod !== '', fn ($query) => $query->where('payment_method', $paymentMethod))
            ->when($paymentStatus !== '', fn ($query) => $query->where('payment_status', $paymentStatus))
            ->when($dateFrom !== '', fn ($query) => $query->whereDate('created_at', '>=', $dateFrom))
            ->when($dateTo !== '', fn ($query) => $query->whereDate('created_at', '<=', $dateTo))
            ->latest();
    }

    public function detail(Transaction $transaction): Transaction
    {
        return $transaction->load([
            'user.storeSetting',
            'items.product',
        ]);
    }
}
