<?php

namespace App\Services;

use App\Models\Product;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Support\Collection;

class AdminProductService
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
        $owner = trim((string) ($filters['owner'] ?? ''));

        return Product::query()
            ->with('user:id,name,phone,email')
            ->withCount('transactionItems')
            ->withSum('transactionItems as total_quantity_sold', 'quantity')
            ->when($search !== '', function ($query) use ($search) {
                $query->where(function ($builder) use ($search) {
                    $builder
                        ->where('name', 'like', "%{$search}%")
                        ->orWhereHas('user', function ($userQuery) use ($search) {
                            $userQuery
                                ->where('name', 'like', "%{$search}%")
                                ->orWhere('phone', 'like', "%{$search}%")
                                ->orWhere('email', 'like', "%{$search}%");
                        });
                });
            })
            ->when($owner !== '', function ($query) use ($owner) {
                $query->whereHas('user', function ($userQuery) use ($owner) {
                    $userQuery->where('name', 'like', "%{$owner}%");
                });
            })
            ->latest();
    }

    public function detail(Product $product): Product
    {
        return $product->load([
            'user.storeSetting',
            'transactionItems.transaction',
        ])->loadCount('transactionItems')
            ->loadSum('transactionItems as total_quantity_sold', 'quantity');
    }
}
