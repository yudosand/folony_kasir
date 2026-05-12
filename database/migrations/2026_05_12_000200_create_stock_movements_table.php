<?php

use App\Models\StockMovement;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('stock_movements', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->foreignId('product_id')->nullable()->constrained()->nullOnDelete();
            $table->string('product_name_snapshot');
            $table->string('type', 30);
            $table->string('direction', 10);
            $table->unsignedInteger('quantity')->default(0);
            $table->unsignedInteger('stock_before')->default(0);
            $table->unsignedInteger('stock_after')->default(0);
            $table->decimal('unit_cost_snapshot', 15, 2)->nullable();
            $table->string('reference_type', 30)->nullable();
            $table->unsignedBigInteger('reference_id')->nullable();
            $table->string('notes')->nullable();
            $table->json('metadata')->nullable();
            $table->timestamps();

            $table->index(['user_id', 'product_id', 'created_at']);
            $table->index(['type', 'direction']);
        });

        $products = DB::table('products')
            ->select('id', 'user_id', 'name', 'stock', 'cost_price', 'minimum_stock', 'created_at')
            ->orderBy('id')
            ->get();

        if ($products->isEmpty()) {
            return;
        }

        $rows = $products->map(function ($product) {
            $createdAt = $product->created_at ?? now();

            return [
                'user_id' => $product->user_id,
                'product_id' => $product->id,
                'product_name_snapshot' => $product->name,
                'type' => StockMovement::TYPE_OPENING,
                'direction' => StockMovement::DIRECTION_IN,
                'quantity' => (int) $product->stock,
                'stock_before' => 0,
                'stock_after' => (int) $product->stock,
                'unit_cost_snapshot' => $product->cost_price,
                'reference_type' => 'product',
                'reference_id' => $product->id,
                'notes' => 'Stok awal produk dicatat saat migrasi pembukuan stok.',
                'metadata' => json_encode([
                    'minimum_stock' => (int) ($product->minimum_stock ?? 0),
                    'source' => 'migration_backfill',
                ], JSON_THROW_ON_ERROR),
                'created_at' => $createdAt,
                'updated_at' => $createdAt,
            ];
        })->all();

        DB::table('stock_movements')->insert($rows);
    }

    public function down(): void
    {
        Schema::dropIfExists('stock_movements');
    }
};
