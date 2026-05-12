<?php

namespace App\Services;

use App\Models\Product;
use App\Models\StockMovement;
use App\Models\User;
use App\Support\StockStatusPresenter;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Collection as EloquentCollection;
use Illuminate\Pagination\LengthAwarePaginator as Paginator;
use Illuminate\Support\Carbon;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class StockBookkeepingService
{
    public function __construct(
        private readonly StockMovementService $stockMovementService,
    ) {
    }

    public function paginateForUser(User $user, array $filters): LengthAwarePaginator
    {
        $perPage = max(1, min((int) ($filters['per_page'] ?? 15), 100));

        $paginator = $this->productBaseQuery($user, $filters)
            ->paginate($perPage)
            ->withQueryString();

        $rows = $this->buildRows($paginator->getCollection(), $filters);

        return new Paginator(
            items: $rows,
            total: $paginator->total(),
            perPage: $paginator->perPage(),
            currentPage: $paginator->currentPage(),
            options: [
                'path' => request()->url(),
                'query' => request()->query(),
            ],
        );
    }

    public function reportForUser(User $user, array $filters): array
    {
        $products = $this->productBaseQuery($user, $filters)->get();
        $rows = $this->buildRows($products, $filters)->values();

        return [
            'summary' => [
                'product_count' => $rows->count(),
                'needs_restock_count' => $rows->where('needs_restock', true)->count(),
                'out_of_stock_count' => $rows->where('stock_status', 'out')->count(),
                'low_stock_count' => $rows->where('stock_status', 'low')->count(),
            ],
            'rows' => $rows,
        ];
    }

    public function stockCardForUser(Product $product, array $filters = []): array
    {
        $product->load([
            'stockMovements' => fn ($query) => $query->latest('created_at')->latest('id'),
        ]);

        $status = StockStatusPresenter::resolve((int) $product->stock, (int) $product->minimum_stock);
        $metrics = $this->buildMetrics($product, $filters);

        $movements = $product->stockMovements
            ->filter(fn (StockMovement $movement) => $this->movementMatchesDateFilter($movement, $filters))
            ->values()
            ->map(fn (StockMovement $movement) => [
                'id' => $movement->id,
                'type' => $movement->type,
                'direction' => $movement->direction,
                'quantity' => (int) $movement->quantity,
                'stock_before' => (int) $movement->stock_before,
                'stock_after' => (int) $movement->stock_after,
                'unit_cost_snapshot' => $movement->unit_cost_snapshot !== null ? (float) $movement->unit_cost_snapshot : null,
                'reference_type' => $movement->reference_type,
                'reference_id' => $movement->reference_id,
                'notes' => $movement->notes,
                'created_at' => $movement->created_at?->toISOString(),
            ]);

        return [
            'product' => [
                'id' => $product->id,
                'name' => $product->name,
                'stock' => (int) $product->stock,
                'minimum_stock' => (int) $product->minimum_stock,
                'stock_status' => $status['code'],
                'stock_status_label' => $status['label'],
                'needs_restock' => $status['needs_restock'],
                'cost_price' => (float) $product->cost_price,
                'selling_price' => (float) $product->selling_price,
            ],
            'summary' => $metrics,
            'movements' => $movements,
        ];
    }

    public function restock(Product $product, array $payload): Product
    {
        return DB::transaction(function () use ($product, $payload) {
            $lockedProduct = Product::query()->lockForUpdate()->findOrFail($product->id);

            $this->stockMovementService->recordRestock(
                product: $lockedProduct,
                quantity: (int) $payload['quantity'],
                unitCost: isset($payload['unit_cost']) ? (float) $payload['unit_cost'] : null,
                notes: $payload['notes'] ?? null,
            );

            return $lockedProduct->refresh();
        });
    }

    public function adjust(Product $product, array $payload): Product
    {
        return DB::transaction(function () use ($product, $payload) {
            $lockedProduct = Product::query()->lockForUpdate()->findOrFail($product->id);
            $direction = (string) $payload['direction'];
            $quantity = (int) $payload['quantity'];

            if ($direction === StockMovement::DIRECTION_OUT && $quantity > (int) $lockedProduct->stock) {
                throw ValidationException::withMessages([
                    'quantity' => ['Penyesuaian keluar tidak boleh melebihi stok saat ini.'],
                ]);
            }

            $this->stockMovementService->recordManualAdjustment(
                product: $lockedProduct,
                quantity: $quantity,
                direction: $direction,
                notes: $payload['notes'] ?? null,
            );

            return $lockedProduct->refresh();
        });
    }

    private function productBaseQuery(User $user, array $filters): Builder
    {
        $search = trim((string) ($filters['search'] ?? ''));
        $status = trim((string) ($filters['status'] ?? ''));

        return Product::query()
            ->ownedBy($user)
            ->with('stockMovements')
            ->when($search !== '', fn (Builder $query) => $query->where('name', 'like', "%{$search}%"))
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

    private function buildRows(EloquentCollection|Collection $products, array $filters): Collection
    {
        return collect($products)->map(function (Product $product) use ($filters) {
            $metrics = $this->buildMetrics($product, $filters);
            $status = StockStatusPresenter::resolve((int) $product->stock, (int) $product->minimum_stock);

            return [
                'product_id' => $product->id,
                'product_name' => $product->name,
                'current_stock' => (int) $product->stock,
                'minimum_stock' => (int) $product->minimum_stock,
                'initial_stock' => $metrics['initial_stock'],
                'stock_at_period_start' => $metrics['stock_at_period_start'],
                'stock_in' => $metrics['stock_in'],
                'stock_out' => $metrics['stock_out'],
                'movement_count' => $metrics['movement_count'],
                'stock_status' => $status['code'],
                'stock_status_label' => $status['label'],
                'needs_restock' => $status['needs_restock'],
                'cost_price' => (float) $product->cost_price,
                'selling_price' => (float) $product->selling_price,
                'created_at' => $product->created_at?->toISOString(),
                'updated_at' => $product->updated_at?->toISOString(),
            ];
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

        $stockIn = (int) $filteredMovements
            ->filter(fn (StockMovement $movement) => $movement->direction === StockMovement::DIRECTION_IN && $movement->type !== StockMovement::TYPE_OPENING)
            ->sum('quantity');

        $stockOut = (int) $filteredMovements
            ->filter(fn (StockMovement $movement) => $movement->direction === StockMovement::DIRECTION_OUT)
            ->sum('quantity');

        return [
            'initial_stock' => $initialStock,
            'stock_at_period_start' => $periodStartStock,
            'stock_in' => $stockIn,
            'stock_out' => $stockOut,
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
