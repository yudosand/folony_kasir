<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('transactions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('invoice_number')->unique();
            $table->string('store_name_snapshot')->nullable();
            $table->text('store_address_snapshot')->nullable();
            $table->string('store_phone_snapshot', 50)->nullable();
            $table->string('store_logo_path_snapshot')->nullable();
            $table->text('invoice_footer_snapshot')->nullable();
            $table->string('cashier_name_snapshot');
            $table->string('cashier_email_snapshot');
            $table->unsignedInteger('item_count')->default(0);
            $table->decimal('subtotal', 15, 2);
            $table->decimal('grand_total', 15, 2);
            $table->string('payment_method', 20);
            $table->string('payment_status', 20);
            $table->decimal('cash_amount', 15, 2)->default(0);
            $table->decimal('non_cash_amount', 15, 2)->default(0);
            $table->decimal('amount_paid', 15, 2)->default(0);
            $table->decimal('change_amount', 15, 2)->default(0);
            $table->decimal('due_amount', 15, 2)->default(0);
            $table->timestamps();

            $table->index(['user_id', 'created_at']);
            $table->index(['user_id', 'payment_status']);
            $table->index(['user_id', 'payment_method']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('transactions');
    }
};
