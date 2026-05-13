<?php

namespace Tests\Feature;

use App\Models\StockMovement;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class StockBookkeepingApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_stock_bookkeeping_tracks_opening_sale_restock_and_adjustment(): void
    {
        $user = User::factory()->create();
        $token = $user->createToken('test')->plainTextToken;
        $headers = [
            'Authorization' => 'Bearer '.$token,
            'Accept' => 'application/json',
        ];

        $productCreateResponse = $this->postJson('/api/products', [
            'name' => 'Kopi Susu',
            'stock' => 10,
            'minimum_stock' => 4,
            'cost_price' => 5000,
            'selling_price' => 12000,
        ], $headers)->assertCreated();

        $productId = $productCreateResponse->json('data.product.id');

        $this->assertDatabaseHas('stock_movements', [
            'product_id' => $productId,
            'type' => StockMovement::TYPE_OPENING,
            'quantity' => 10,
            'stock_before' => 0,
            'stock_after' => 10,
        ]);

        $this->postJson('/api/transactions', [
            'items' => [
                [
                    'product_id' => $productId,
                    'quantity' => 2,
                ],
            ],
            'payment_method' => 'cash',
            'cash_amount' => 24000,
        ], $headers)->assertCreated();

        $this->postJson("/api/products/{$productId}/restocks", [
            'quantity' => 5,
            'unit_cost' => 5200,
            'notes' => 'Restock mingguan',
        ], $headers)
            ->assertOk()
            ->assertJsonPath('data.product.stock', 13);

        $this->postJson("/api/products/{$productId}/adjustments", [
            'direction' => 'out',
            'quantity' => 3,
            'notes' => 'Barang rusak',
        ], $headers)
            ->assertOk()
            ->assertJsonPath('data.product.stock', 10);

        $this->getJson("/api/products/{$productId}/stock-card", $headers)
            ->assertOk()
            ->assertJsonPath('data.product.minimum_stock', 4)
            ->assertJsonPath('data.summary.initial_stock', 10)
            ->assertJsonPath('data.summary.stock_in', 5)
            ->assertJsonPath('data.summary.stock_out', 5)
            ->assertJsonCount(4, 'data.movements');

        $this->getJson('/api/stock-bookkeeping/report', $headers)
            ->assertOk()
            ->assertJsonPath('data.summary.product_count', 1)
            ->assertJsonPath('data.rows.0.product_name', 'Kopi Susu')
            ->assertJsonPath('data.rows.0.current_stock', 10)
            ->assertJsonPath('data.rows.0.initial_stock', 10)
            ->assertJsonPath('data.rows.0.stock_in', 5)
            ->assertJsonPath('data.rows.0.stock_out', 5)
            ->assertJsonPath('data.rows.0.stock_status', 'healthy');
    }

    public function test_stock_bookkeeping_report_can_filter_restock_candidates(): void
    {
        $user = User::factory()->create();
        $token = $user->createToken('test')->plainTextToken;
        $headers = [
            'Authorization' => 'Bearer '.$token,
            'Accept' => 'application/json',
        ];

        $this->postJson('/api/products', [
            'name' => 'Gula Aren',
            'stock' => 2,
            'minimum_stock' => 5,
            'cost_price' => 4000,
            'selling_price' => 8000,
        ], $headers)->assertCreated();

        $this->postJson('/api/products', [
            'name' => 'Susu Full Cream',
            'stock' => 0,
            'minimum_stock' => 2,
            'cost_price' => 7000,
            'selling_price' => 11000,
        ], $headers)->assertCreated();

        $this->postJson('/api/products', [
            'name' => 'Cokelat Bubuk',
            'stock' => 12,
            'minimum_stock' => 4,
            'cost_price' => 3000,
            'selling_price' => 9000,
        ], $headers)->assertCreated();

        $this->getJson('/api/stock-bookkeeping/report?status=restock', $headers)
            ->assertOk()
            ->assertJsonPath('data.summary.product_count', 3)
            ->assertJsonPath('data.summary.needs_restock_count', 2)
            ->assertJsonPath('data.summary.out_of_stock_count', 1)
            ->assertJsonPath('data.summary.low_stock_count', 1)
            ->assertJsonCount(2, 'data.rows');
    }

    public function test_stock_adjustment_rejects_outgoing_quantity_above_current_stock(): void
    {
        $user = User::factory()->create();
        $token = $user->createToken('test')->plainTextToken;
        $headers = [
            'Authorization' => 'Bearer '.$token,
            'Accept' => 'application/json',
        ];

        $productId = $this->postJson('/api/products', [
            'name' => 'Es Batu',
            'stock' => 3,
            'minimum_stock' => 1,
            'cost_price' => 500,
            'selling_price' => 2000,
        ], $headers)->json('data.product.id');

        $this->postJson("/api/products/{$productId}/adjustments", [
            'direction' => 'out',
            'quantity' => 4,
        ], $headers)
            ->assertStatus(422)
            ->assertJsonPath('success', false)
            ->assertJsonPath('message', 'Validation error');
    }
}
