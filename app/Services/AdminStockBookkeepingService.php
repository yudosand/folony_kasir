<?php

namespace App\Services;

use App\Models\Product;
use App\Models\StockMovement;
use App\Support\StockStatusPresenter;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Collection as EloquentCollection;
use Illuminate\Support\Carbon;
use Illuminate\Support\Collection;

class AdminStockBookkeepingService
{
    public function paginate(array $filters = []): LengthAwarePaginator
    {
        $products = $this->baseQuery($filters)
            ->paginate(15)
            ->withQueryString();

        $products->setCollection(
            $this->decorateRows($products->getCollection(), $filters)
        );

        return $products;
    }

    public function exportRows(array $filters = []): Collection
    {
        return $this->decorateRows($this->baseQuery($filters)->get(), $filters);
    }

    public function detail(Product $product, array $filters = []): array
    {
        $product->load([
            'user:id,name,phone,email',
            'stockMovements' => fn ($query) => $query->latest('created_at')->latest('id'),
        ]);

        $summary = $this->buildMetrics($product, $filters);
        $status = StockStatusPresenter::resolve((int) $product->stock, (int) $product->minimum_stock);

        return [
            'product' => $product,
            'status' => $status,
            'summary' => $summary,
            'movements' => $product->stockMovements
                ->filter(fn (StockMovement $movement) => $this->movementMatchesDateFilter($movement, $filters))
                ->values(),
        ];
    }

    private function baseQuery(array $filters = []): Builder
    {
        $search = trim((string) ($filters['search'] ?? ''));
        $owner = trim((string) ($filters['owner'] ?? ''));
        $status = trim((string) ($filters['status'] ?? ''));

        return Product::query()
            ->with(['user:id,name,phone,email', 'stockMovements'])
            ->when($search !== '', fn (Builder $query) => $query->where('name', 'like', "%{$search}%"))
            ->when($owner !== '', function (Builder $query) use ($owner) {
                $query->whereHas('user', function (Builder $userQuery) use ($owner) {
                    $userQuery
                        ->where('name', 'like', "%{$owner}%")
                        ->orWhere('phone', 'like', "%{$owner}%")
                        ->orWhere('email', 'like', "%{$owner}%");
                });
            })
            ->when($status !== '', function (Builder $query) use ($status) {
                return match ($status) {
                    'out' => $query->where('stock', '<=', 0),
                    'low' => $query->where('stock', '>', 0)->whereColumn('stock', '<=', 'minimum_stock'),
                    'restock' => $query->where(function (Builder $builder) {
                        $builder
                            ->where('stock', '<=', 0)
                            ->orWhereColumn('stock', '<=', 'minimum_stock');
                    }),
                    'healthy' => $query->whereColumn('stock', '>', 'minimum_stock'),
                    default => $query,
                };
            })
            ->latest('id');
    }

    private function decorateRows(EloquentCollection $products, array $filters): EloquentCollection
    {
        return $products->map(function (Product $product) use ($filters) {
            $summary = $this->buildMetrics($product, $filters);
            $status = StockStatusPresenter::resolve((int) $product->stock, (int) $product->minimum_stock);

            $product->setAttribute('stock_status', $status['code']);
            $product->setAttribute('stock_status_label', $status['label']);
            $product->setAttribute('needs_restock', $status['needs_restock']);
            $product->setAttribute('initial_stock', $summary['initial_stock']);
            $product->setAttribute('stock_at_period_start', $summary['stock_at_period_start']);
            $product->setAttribute('stock_in', $summary['stock_in']);
            $product->setAttribute('stock_out', $summary['stock_out']);
            $product->setAttribute('movement_count', $summary['movement_count']);

            return $product;
        });
    }

    private function buildMetrics(Product $product, array $filters): array
    {
        $movements = $product->relationLoaded('stockMovements')
            ? $product->stockMovements
            : $product->stockMovements()->get();

        $from = $this->parseDateBoundary($filters['date_from'] ?? null, false);
        $openingMovement = $movements->firstWhere('type', StockMovement::TYPE_OPENING);
        $initialStock = $openingMovement ? (int) $openingMovement->stock_after : (int) $product->stock;

        $periodStartStock = $initialStock;
        if ($from) {
            $latestBefore = $movements
                ->filter(fn (StockMovement $movement) => $movement->created_at !== null && $movement->created_at->lt($from))
                ->sortBy([
                    ['created_at', 'asc'],
                    ['id', 'asc'],
                ])
                ->last();

            $periodStartStock = $latestBefore ? (int) $latestBefore->stock_after : 0;
        }

        $filteredMovements = $movements->filter(fn (StockMovement $movement) => $this->movementMatchesDateFilter($movement, $filters));

        return [
            'initial_stock' => $initialStock,
            'stock_at_period_start' => $periodStartStock,
            'stock_in' => (int) $filteredMovements
                ->filter(fn (StockMovement $movement) => $movement->direction === StockMovement::DIRECTION_IN && $movement->type !== StockMovement::TYPE_OPENING)
                ->sum('quantity'),
            'stock_out' => (int) $filteredMovements
                ->filter(fn (StockMovement $movement) => $movement->direction === StockMovement::DIRECTION_OUT)
                ->sum('quantity'),
            'movement_count' => $filteredMovements->count(),
        ];
    }

    private function movementMatchesDateFilter(StockMovement $movement, array $filters): bool
    {
        $from = $this->parseDateBoundary($filters['date_from'] ?? null, false);
        $to = $this->parseDateBoundary($filters['date_to'] ?? null, true);

        if ($movement->created_at === null) {
            return true;
        }

        if ($from && $movement->created_at->lt($from)) {
            return false;
        }

        if ($to && $movement->created_at->gt($to)) {
            return false;
        }

        return true;
    }

    private function parseDateBoundary(?string $date, bool $endOfDay): ?Carbon
    {
        if (! filled($date)) {
            return null;
        }

        $parsed = Carbon::parse($date);

        return $endOfDay ? $parsed->endOfDay() : $parsed->startOfDay();
    }
}
