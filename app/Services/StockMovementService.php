<?php

namespace App\Services;

use App\Models\Product;
use App\Models\StockMovement;
use App\Models\Transaction;
use InvalidArgumentException;

class StockMovementService
{
    public function recordOpening(Product $product, ?string $notes = null): StockMovement
    {
        return $this->createMovement(
            product: $product,
            type: StockMovement::TYPE_OPENING,
            direction: StockMovement::DIRECTION_IN,
            quantity: (int) $product->stock,
            stockBefore: 0,
            stockAfter: (int) $product->stock,
            unitCost: (float) $product->cost_price,
            referenceType: 'product',
            referenceId: $product->id,
            notes: $notes ?? 'Stok awal produk dicatat.',
            metadata: [
                'minimum_stock' => (int) $product->minimum_stock,
            ],
        );
    }

    public function recordEditAdjustment(Product $product, int $newStock, ?string $notes = null): ?StockMovement
    {
        $currentStock = (int) $product->stock;
        $delta = $newStock - $currentStock;

        if ($delta === 0) {
            return null;
        }

        $direction = $delta > 0
            ? StockMovement::DIRECTION_IN
            : StockMovement::DIRECTION_OUT;

        $quantity = abs($delta);

        $product->stock = $newStock;
        $product->save();

        return $this->createMovement(
            product: $product,
            type: StockMovement::TYPE_ADJUSTMENT,
            direction: $direction,
            quantity: $quantity,
            stockBefore: $currentStock,
            stockAfter: $newStock,
            unitCost: (float) $product->cost_price,
            referenceType: 'product',
            referenceId: $product->id,
            notes: $notes ?? 'Stok disesuaikan dari form produk.',
            metadata: [
                'adjustment_source' => 'product_form',
                'minimum_stock' => (int) $product->minimum_stock,
            ],
        );
    }

    public function recordSale(Product $product, int $quantity, Transaction $transaction): StockMovement
    {
        $currentStock = (int) $product->stock;
        $afterStock = $currentStock - $quantity;

        if ($afterStock < 0) {
            throw new InvalidArgumentException('Stock after sale cannot be negative.');
        }

        $product->stock = $afterStock;
        $product->save();

        return $this->createMovement(
            product: $product,
            type: StockMovement::TYPE_SALE,
            direction: StockMovement::DIRECTION_OUT,
            quantity: $quantity,
            stockBefore: $currentStock,
            stockAfter: $afterStock,
            unitCost: (float) $product->cost_price,
            referenceType: 'transaction',
            referenceId: $transaction->id,
            notes: sprintf('Stok keluar dari invoice %s.', $transaction->invoice_number),
            metadata: [
                'invoice_number' => $transaction->invoice_number,
                'minimum_stock' => (int) $product->minimum_stock,
            ],
        );
    }

    public function recordRestock(Product $product, int $quantity, ?float $unitCost = null, ?string $notes = null): StockMovement
    {
        $currentStock = (int) $product->stock;
        $afterStock = $currentStock + $quantity;

        $product->stock = $afterStock;
        $product->save();

        return $this->createMovement(
            product: $product,
            type: StockMovement::TYPE_RESTOCK,
            direction: StockMovement::DIRECTION_IN,
            quantity: $quantity,
            stockBefore: $currentStock,
            stockAfter: $afterStock,
            unitCost: $unitCost ?? (float) $product->cost_price,
            referenceType: 'product',
            referenceId: $product->id,
            notes: $notes ?? 'Stok masuk dari restock manual.',
            metadata: [
                'minimum_stock' => (int) $product->minimum_stock,
            ],
        );
    }

    public function recordManualAdjustment(Product $product, int $quantity, string $direction, ?string $notes = null): StockMovement
    {
        $currentStock = (int) $product->stock;

        if ($direction === StockMovement::DIRECTION_IN) {
            $afterStock = $currentStock + $quantity;
        } else {
            $afterStock = $currentStock - $quantity;
        }

        if ($afterStock < 0) {
            throw new InvalidArgumentException('Stock after adjustment cannot be negative.');
        }

        $product->stock = $afterStock;
        $product->save();

        return $this->createMovement(
            product: $product,
            type: StockMovement::TYPE_ADJUSTMENT,
            direction: $direction,
            quantity: $quantity,
            stockBefore: $currentStock,
            stockAfter: $afterStock,
            unitCost: (float) $product->cost_price,
            referenceType: 'product',
            referenceId: $product->id,
            notes: $notes ?? 'Penyesuaian stok manual.',
            metadata: [
                'minimum_stock' => (int) $product->minimum_stock,
            ],
        );
    }

    private function createMovement(
        Product $product,
        string $type,
        string $direction,
        int $quantity,
        int $stockBefore,
        int $stockAfter,
        ?float $unitCost,
        ?string $referenceType,
        ?int $referenceId,
        ?string $notes,
        array $metadata = [],
    ): StockMovement {
        return $product->stockMovements()->create([
            'user_id' => $product->user_id,
            'product_name_snapshot' => $product->name,
            'type' => $type,
            'direction' => $direction,
            'quantity' => $quantity,
            'stock_before' => $stockBefore,
            'stock_after' => $stockAfter,
            'unit_cost_snapshot' => $unitCost,
            'reference_type' => $referenceType,
            'reference_id' => $referenceId,
            'notes' => $notes,
            'metadata' => $metadata,
        ]);
    }
}
