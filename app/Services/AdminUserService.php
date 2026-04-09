<?php

namespace App\Services;

use App\Models\Product;
use App\Models\Transaction;
use App\Models\User;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Support\Collection;

class AdminUserService
{
    public function paginate(array $filters = []): LengthAwarePaginator
    {
        return $this->baseQuery($filters)
            ->paginate(12)
            ->withQueryString();
    }

    public function exportRows(array $filters = []): Collection
    {
        return $this->baseQuery($filters)->get();
    }

    private function baseQuery(array $filters = []): Builder
    {
        $search = trim((string) ($filters['search'] ?? ''));

        return User::query()
            ->with('storeSetting')
            ->withCount(['products', 'transactions'])
            ->withSum('transactions as total_transaction_value', 'grand_total')
            ->when($search !== '', function ($query) use ($search) {
                $query->where(function ($builder) use ($search) {
                    $builder
                        ->where('name', 'like', "%{$search}%")
                        ->orWhere('phone', 'like', "%{$search}%")
                        ->orWhere('email', 'like', "%{$search}%")
                        ->orWhere('external_member_id', 'like', "%{$search}%");
                });
            })
            ->latest();
    }

    public function detail(User $user): array
    {
        $user->load('storeSetting')
            ->loadCount(['products', 'transactions'])
            ->loadSum('transactions as total_transaction_value', 'grand_total')
            ->loadSum('transactions as total_due_value', 'due_amount');

        return [
            'user' => $user,
            'products' => Product::query()
                ->ownedBy($user)
                ->latest()
                ->paginate(10, ['*'], 'products_page')
                ->withQueryString(),
            'transactions' => Transaction::query()
                ->ownedBy($user)
                ->latest()
                ->paginate(10, ['*'], 'transactions_page')
                ->withQueryString(),
        ];
    }
}
