<?php

namespace Tests\Feature;

use App\Models\Transaction;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class SalesProfitApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_authenticated_user_can_view_sales_profit_report_for_owned_transactions_only(): void
    {
        $user = User::factory()->create(['name' => 'Kasir Profit']);
        $otherUser = User::factory()->create(['name' => 'Kasir Lain']);

        $headers = [
            'Authorization' => 'Bearer '.$user->createToken('test')->plainTextToken,
            'Accept' => 'application/json',
        ];

        $ownProductId = $this->postJson('/api/products', [
            'name' => 'Produk Profit',
            'stock' => 10,
            'minimum_stock' => 2,
            'cost_price' => 2000,
            'selling_price' => 3500,
        ], $headers)
            ->assertCreated()
            ->json('data.product.id');

        $this->postJson('/api/transactions', [
            'items' => [
                [
                    'product_id' => $ownProductId,
                    'quantity' => 2,
                ],
                [
                    'product_name' => 'Jasa Manual',
                    'quantity' => 1,
                    'cost_price' => 4000,
                    'unit_price' => 6000,
                ],
            ],
            'payment_method' => 'cash',
            'cash_amount' => 13000,
        ], $headers)->assertCreated();

        $otherTransaction = Transaction::query()->create([
            'user_id' => $otherUser->id,
            'invoice_number' => 'INV-OTHER-0001',
            'cashier_name_snapshot' => $otherUser->name,
            'cashier_email_snapshot' => $otherUser->email,
            'item_count' => 1,
            'subtotal' => 2000,
            'grand_total' => 2000,
            'payment_method' => 'cash',
            'payment_status' => 'paid',
            'cash_amount' => 2000,
            'non_cash_amount' => 0,
            'amount_paid' => 2000,
            'change_amount' => 0,
            'due_amount' => 0,
        ]);

        $otherTransaction->items()->create([
            'product_id' => null,
            'quantity' => 1,
            'product_name_snapshot' => 'Produk Orang Lain',
            'cost_price_snapshot' => 1000,
            'selling_price_snapshot' => 2000,
            'line_subtotal' => 2000,
        ]);

        $response = $this->getJson('/api/sales-profit/report', $headers)
            ->assertOk()
            ->assertJsonPath('data.summary.quantity_sold', 3)
            ->assertJsonPath('data.summary.total_revenue', 13000)
            ->assertJsonPath('data.summary.total_cost', 8000)
            ->assertJsonPath('data.summary.total_profit', 5000)
            ->assertJsonCount(2, 'data.rows');

        $productNames = collect($response->json('data.rows'))->pluck('product_name')->all();

        $this->assertContains('Produk Profit', $productNames);
        $this->assertContains('Jasa Manual', $productNames);
        $this->assertNotContains('Produk Orang Lain', $productNames);
    }
}
