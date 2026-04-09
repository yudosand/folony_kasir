<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Config;
use Illuminate\Support\Facades\Http;
use Tests\TestCase;

class PosApiFlowTest extends TestCase
{
    use RefreshDatabase;

    public function test_core_pos_api_flow_works_end_to_end(): void
    {
        Config::set('services.foodukm_auth.register_url', 'https://foloni.test/app/api_registrasi_v2');
        Config::set('services.foodukm_auth.login_url', 'https://foloni.test/app/api_login_v2');

        Http::fake([
            'https://foloni.test/app/api_registrasi_v2' => Http::response([
                'statusCode' => 1,
                'message' => 'Register berhasil!',
                'result' => [
                    'idmember' => '999',
                ],
            ], 200),
            'https://foloni.test/app/api_login_v2' => Http::response([
                'statusCode' => 1,
                'message' => 'Login berhasil!',
                'result' => [
                    'token' => 'external-token',
                    'name' => 'Flow User',
                    'idmember' => '999',
                    'hp' => '081234567891',
                    'email' => 'flow@example.com',
                    'accountType' => 'Personal',
                    'defaultLocation' => [
                        'lat' => '-6.1',
                        'long' => '107.0',
                    ],
                ],
            ], 200),
            'https://foloni.test/adm/user/login' => Http::response([
                'status_code' => 1,
                'message' => 'Login berhasil!',
                'result' => [
                    'token' => 'foloni-admin-token',
                ],
            ], 200),
            'https://foloni.test/adm/finance/poin/history*' => Http::response([
                'status_code' => 1,
                'message' => '',
                'result' => [
                    'data' => [],
                    'totalrecords' => 0,
                ],
            ], 200),
            'https://foloni.test/adm/finance/poin/member*' => Http::sequence()
                ->push([
                    'status_code' => 1,
                    'message' => '',
                    'result' => [
                        'data' => [
                            [
                                'id' => 11,
                                'name' => 'Flow Member',
                                'poin' => 20000,
                            ],
                        ],
                        'totalrecords' => 1,
                    ],
                ], 200)
                ->push([
                    'status_code' => 1,
                    'message' => '',
                    'result' => [
                        'data' => [
                            [
                                'id' => 11,
                                'name' => 'Flow Member',
                                'poin' => 19000,
                            ],
                        ],
                        'totalrecords' => 1,
                    ],
                ], 200),
            'https://foloni.test/adm/finance/poin' => Http::response([
                'status_code' => 1,
                'message' => 'Mutasi poin berhasil!',
                'result' => [
                    'updated' => 1,
                ],
            ], 200),
        ]);

        Config::set('services.foloni_app_admin.login_url', 'https://foloni.test/adm/user/login');
        Config::set('services.foloni_app_admin.member_points_url', 'https://foloni.test/adm/finance/poin/member');
        Config::set('services.foloni_app_admin.point_history_url', 'https://foloni.test/adm/finance/poin/history');
        Config::set('services.foloni_app_admin.point_mutation_url', 'https://foloni.test/adm/finance/poin');
        Config::set('services.foloni_app_admin.user', 'admin@example.com');
        Config::set('services.foloni_app_admin.password', 'secret');

        $registerResponse = $this->postJson('/api/auth/register', [
            'name' => 'Flow User',
            'phone' => '081234567891',
            'password' => '123456',
            'password_confirmation' => '123456',
            'referal' => 'FOLONI_ADM01',
        ]);

        $registerResponse
            ->assertCreated()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.user.phone', '081234567891');

        $loginResponse = $this->postJson('/api/auth/login', [
            'phone' => '081234567891',
            'password' => '123456',
        ]);

        $token = $loginResponse->json('data.token');

        $loginResponse
            ->assertOk()
            ->assertJsonPath('success', true);

        $authHeaders = [
            'Authorization' => 'Bearer '.$token,
            'Accept' => 'application/json',
        ];

        $this->getJson('/api/auth/me', $authHeaders)
            ->assertOk()
            ->assertJsonPath('data.user.phone', '081234567891');

        $this->getJson('/api/store-setting', $authHeaders)
            ->assertOk()
            ->assertJsonPath('data.store_setting', null);

        $this->putJson('/api/store-setting', [
            'store_name' => 'Warung Flow',
            'store_address' => 'Jl. Flow No. 1',
            'phone_number' => '081234567890',
            'invoice_footer' => 'Flow footer',
        ], $authHeaders)
            ->assertOk()
            ->assertJsonPath('data.store_setting.store_name', 'Warung Flow');

        $productCreateResponse = $this->postJson('/api/products', [
            'name' => 'Indomie Flow',
            'stock' => 10,
            'cost_price' => 2000,
            'selling_price' => 3500,
        ], $authHeaders);

        $productId = $productCreateResponse->json('data.product.id');

        $productCreateResponse
            ->assertCreated()
            ->assertJsonPath('data.product.stock', 10);

        $this->getJson('/api/products', $authHeaders)
            ->assertOk()
            ->assertJsonCount(1, 'data.products');

        $this->getJson("/api/products/{$productId}", $authHeaders)
            ->assertOk()
            ->assertJsonPath('data.product.name', 'Indomie Flow');

        $this->putJson("/api/products/{$productId}", [
            'stock' => 12,
            'selling_price' => 3600,
        ], $authHeaders)
            ->assertOk()
            ->assertJsonPath('data.product.stock', 12);

        $this->assertEquals(3600, $this->getJson("/api/products/{$productId}", $authHeaders)->json('data.product.selling_price'));

        $transactionCreateResponse = $this->postJson('/api/transactions', [
            'items' => [
                [
                    'product_id' => $productId,
                    'quantity' => 2,
                ],
            ],
            'member_id' => 11,
            'points_used' => 1000,
            'payment_method' => 'cash',
            'cash_amount' => 7000,
        ], $authHeaders);

        $transactionId = $transactionCreateResponse->json('data.transaction.id');

        $transactionCreateResponse
            ->assertCreated()
            ->assertJsonPath('data.transaction.payment_status', 'paid')
            ->assertJsonPath('data.transaction.member_points.points_used', 1000)
            ->assertJsonPath('data.transaction.member_points.value_amount', 1000)
            ->assertJsonPath('data.transaction.items.0.product_name_snapshot', 'Indomie Flow');

        $this->assertEquals(3600, $transactionCreateResponse->json('data.transaction.items.0.selling_price_snapshot'));

        $this->getJson('/api/products', $authHeaders)
            ->assertOk()
            ->assertJsonPath('data.products.0.stock', 10);

        $this->getJson('/api/transactions', $authHeaders)
            ->assertOk()
            ->assertJsonCount(1, 'data.transactions');

        $this->getJson("/api/transactions/{$transactionId}", $authHeaders)
            ->assertOk()
            ->assertJsonPath('data.transaction.invoice_number', 'INV'.now()->format('Ymd').'0001')
            ->assertJsonPath('data.transaction.store.name', 'Warung Flow');

        $this->getJson("/api/transactions/{$transactionId}/invoice", $authHeaders)
            ->assertOk()
            ->assertJsonPath('data.invoice.store.name', 'Warung Flow')
            ->assertJsonPath('data.invoice.totals.item_count', 2)
            ->assertJsonPath('data.invoice.member_points.points_used', 1000)
            ->assertJsonPath('data.invoice.totals.member_points_value_amount', 1000)
            ->assertJsonPath('data.invoice.payment.status', 'paid');

        $this->postJson('/api/auth/logout', [], $authHeaders)
            ->assertOk()
            ->assertJsonPath('success', true);
    }

    public function test_transaction_with_member_points_is_rejected_when_foloni_app_balance_does_not_change(): void
    {
        Http::fake([
            'https://foloni.test/adm/user/login' => Http::response([
                'status_code' => 1,
                'message' => 'Login berhasil!',
                'result' => [
                    'token' => 'foloni-admin-token',
                ],
            ], 200),
            'https://foloni.test/adm/finance/poin/member*' => Http::response([
                'status_code' => 1,
                'message' => '',
                'result' => [
                    'data' => [
                        [
                            'id' => 11,
                            'name' => 'Flow Member',
                            'poin' => 20000,
                        ],
                    ],
                    'totalrecords' => 1,
                ],
            ], 200),
            'https://foloni.test/adm/finance/poin' => Http::response([
                'status_code' => 1,
                'message' => 'Mutasi poin berhasil!',
                'result' => [
                    'updated' => 1,
                ],
            ], 200),
            'https://foloni.test/adm/finance/poin/history*' => Http::response([
                'status_code' => 1,
                'message' => '',
                'result' => [
                    'data' => [],
                    'totalrecords' => 0,
                ],
            ], 200),
        ]);

        Config::set('services.foloni_app_admin.login_url', 'https://foloni.test/adm/user/login');
        Config::set('services.foloni_app_admin.member_points_url', 'https://foloni.test/adm/finance/poin/member');
        Config::set('services.foloni_app_admin.point_history_url', 'https://foloni.test/adm/finance/poin/history');
        Config::set('services.foloni_app_admin.point_mutation_url', 'https://foloni.test/adm/finance/poin');
        Config::set('services.foloni_app_admin.user', 'admin@example.com');
        Config::set('services.foloni_app_admin.password', 'secret');

        $user = \App\Models\User::factory()->create([
            'phone' => '081234567891',
        ]);

        $user->tokens()->delete();
        $token = $user->createToken('test')->plainTextToken;

        $headers = [
            'Authorization' => 'Bearer '.$token,
            'Accept' => 'application/json',
        ];

        $productCreateResponse = $this->postJson('/api/products', [
            'name' => 'Indomie Flow',
            'stock' => 10,
            'cost_price' => 2000,
            'selling_price' => 3500,
        ], $headers);

        $productId = $productCreateResponse->json('data.product.id');

        $this->postJson('/api/transactions', [
            'items' => [
                [
                    'product_id' => $productId,
                    'quantity' => 2,
                ],
            ],
            'member_id' => 11,
            'points_used' => 1000,
            'payment_method' => 'cash',
            'cash_amount' => 7000,
        ], $headers)
            ->assertStatus(503)
            ->assertJsonPath('success', false)
            ->assertJsonPath('message', 'Potongan poin di Foloni App belum terkonfirmasi. Transaksi dibatalkan agar saldo member tetap aman.');

        $this->assertDatabaseCount('transactions', 0);
    }

    public function test_transaction_with_member_points_succeeds_when_history_confirms_deduction(): void
    {
        Http::fake([
            'https://foloni.test/app/api_login_v2' => Http::response([
                'statusCode' => 1,
                'message' => 'Login berhasil!',
                'result' => [
                    'token' => 'external-token',
                    'name' => 'Flow User',
                    'idmember' => '999',
                    'hp' => '081234567891',
                    'email' => 'flow@example.com',
                    'accountType' => 'Personal',
                    'defaultLocation' => [
                        'lat' => '-6.1',
                        'long' => '107.0',
                    ],
                ],
            ], 200),
            'https://foloni.test/adm/user/login' => Http::response([
                'status_code' => 1,
                'message' => 'Login berhasil!',
                'result' => [
                    'token' => 'foloni-admin-token',
                ],
            ], 200),
            'https://foloni.test/adm/finance/poin/member*' => Http::response([
                'status_code' => 1,
                'message' => '',
                'result' => [
                    'data' => [
                        [
                            'id' => 11,
                            'name' => 'Flow Member',
                            'poin' => 20000,
                        ],
                    ],
                    'totalrecords' => 1,
                ],
            ], 200),
            'https://foloni.test/adm/finance/poin' => Http::response([
                'status_code' => 1,
                'message' => 'Mutasi poin berhasil!',
                'result' => [
                    'updated' => 1,
                ],
            ], 200),
            'https://foloni.test/adm/finance/poin/history*' => Http::response([
                'status_code' => 1,
                'message' => '',
                'result' => [
                    'data' => [
                        [
                            'id' => 11,
                            'name' => 'Flow Member',
                            'type' => 'Kurang',
                            'transaction_type' => 'Penyesuaian',
                            'description' => 'Potong poin invoice INV'.now()->format('Ymd').'0001',
                            'amount' => '1.000',
                            'created_at' => now()->format('d-m-Y H:i:s'),
                            'created_by' => 'Folony Kasir',
                        ],
                    ],
                    'totalrecords' => 1,
                ],
            ], 200),
        ]);

        Config::set('services.foloni_app_admin.login_url', 'https://foloni.test/adm/user/login');
        Config::set('services.foloni_app_admin.member_points_url', 'https://foloni.test/adm/finance/poin/member');
        Config::set('services.foloni_app_admin.point_history_url', 'https://foloni.test/adm/finance/poin/history');
        Config::set('services.foloni_app_admin.point_mutation_url', 'https://foloni.test/adm/finance/poin');
        Config::set('services.foloni_app_admin.user', 'admin@example.com');
        Config::set('services.foloni_app_admin.password', 'secret');

        $user = \App\Models\User::factory()->create([
            'phone' => '081234567891',
        ]);

        $user->tokens()->delete();
        $token = $user->createToken('test')->plainTextToken;

        $headers = [
            'Authorization' => 'Bearer '.$token,
            'Accept' => 'application/json',
        ];

        $productCreateResponse = $this->postJson('/api/products', [
            'name' => 'Indomie Flow',
            'stock' => 10,
            'cost_price' => 2000,
            'selling_price' => 3500,
        ], $headers);

        $productId = $productCreateResponse->json('data.product.id');

        $this->postJson('/api/transactions', [
            'items' => [
                [
                    'product_id' => $productId,
                    'quantity' => 2,
                ],
            ],
            'member_id' => 11,
            'points_used' => 1000,
            'payment_method' => 'cash',
            'cash_amount' => 7000,
        ], $headers)
            ->assertCreated()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.transaction.member_points.points_used', 1000)
            ->assertJsonPath('data.transaction.member_points.status', 'deducted');

        $this->assertDatabaseCount('transactions', 1);
    }
}
