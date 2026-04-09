<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('transaction_items', function (Blueprint $table) {
            $table->id();
            $table->foreignId('transaction_id')->constrained()->cascadeOnDelete();
            $table->foreignId('product_id')->nullable()->constrained()->nullOnDelete();
            $table->unsignedInteger('quantity');
            $table->string('product_name_snapshot');
            $table->decimal('cost_price_snapshot', 15, 2);
            $table->decimal('selling_price_snapshot', 15, 2);
            $table->decimal('line_subtotal', 15, 2);
            $table->timestamps();

            $table->index(['transaction_id', 'product_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('transaction_items');
    }
};
