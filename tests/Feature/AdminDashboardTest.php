<?php

namespace Tests\Feature;

use App\Models\Product;
use App\Models\Transaction;
use App\Models\TransactionItem;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\File;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Str;
use Tests\TestCase;

class AdminDashboardTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        config()->set('admin-dashboard.name', 'Folony Kasir Admin');
        config()->set('services.foloni_app_admin.login_url', 'https://foloni.test/adm/user/login');

        $compiledPath = storage_path('framework/views/admin-dashboard-tests-'.Str::random(10));
        File::ensureDirectoryExists($compiledPath);
        config()->set('view.compiled', $compiledPath);

        Http::fake([
            'https://foloni.test/adm/user/login' => function ($request) {
                if (($request['pass'] ?? null) === 'secret-admin') {
                    return Http::response([
                        'status_code' => 1,
                        'message' => 'Login berhasil!',
                        'result' => [
                            'token' => 'dashboard-admin-token',
                            'name' => 'Admin Dashboard',
                        ],
                    ], 200);
                }

                return Http::response([
                    'status_code' => 0,
                    'message' => 'Login admin Foloni App belum berhasil. Coba lagi sebentar ya.',
                    'result' => null,
                ], 401);
            },
        ]);
    }

    public function test_guest_is_redirected_to_admin_login(): void
    {
        $this->get('/admin')
            ->assertRedirect(route('admin.login'));
    }

    public function test_admin_can_login_and_open_dashboard_pages(): void
    {
        $user = User::factory()->create([
            'name' => 'Kasir Satu',
            'phone' => '081234567890',
            'external_member_id' => 77,
        ]);

        Product::query()->create([
            'user_id' => $user->id,
            'name' => 'Produk Demo',
            'stock' => 12,
            'cost_price' => 2000,
            'selling_price' => 3500,
        ]);

        $transaction = Transaction::query()->create([
            'user_id' => $user->id,
            'invoice_number' => 'INVTEST0001',
            'cashier_name_snapshot' => 'Kasir Satu',
            'cashier_email_snapshot' => 'kasir@example.com',
            'member_external_id' => 44,
            'member_name_snapshot' => 'Member Demo',
            'member_points_before' => 1000,
            'member_points_used' => 250,
            'member_points_after' => 750,
            'member_points_value_amount' => 250,
            'member_point_status' => 'verified',
            'item_count' => 2,
            'subtotal' => 7000,
            'grand_total' => 6750,
            'payment_method' => 'cash',
            'payment_status' => 'paid',
            'cash_amount' => 6500,
            'non_cash_amount' => 0,
            'amount_paid' => 6500,
            'change_amount' => 0,
            'due_amount' => 0,
        ]);

        TransactionItem::query()->create([
            'transaction_id' => $transaction->id,
            'product_id' => null,
            'quantity' => 2,
            'product_name_snapshot' => 'Produk Demo',
            'cost_price_snapshot' => 2000,
            'selling_price_snapshot' => 3500,
            'line_subtotal' => 7000,
        ]);

        $this->post('/admin/login', [
            'user' => 'adm.folonykasir@foodcoloni.com',
            'password' => 'secret-admin',
        ])->assertRedirect(route('admin.dashboard'));

        $this->get('/admin')
            ->assertOk()
            ->assertSee('Dashboard')
            ->assertSee('Kasir Satu')
            ->assertSee('INVTEST0001');

        $this->get(route('admin.users.index'))
            ->assertOk()
            ->assertSee('Daftar User')
            ->assertSee('Kasir Satu')
            ->assertSee('081234567890');

        $this->get(route('admin.users.export'))
            ->assertOk()
            ->assertHeader('content-type', 'application/vnd.ms-excel; charset=UTF-8')
            ->assertSee('Kasir Satu');

        $this->get(route('admin.users.show', $user))
            ->assertOk()
            ->assertSee('Produk Milik User')
            ->assertSee('Produk Demo')
            ->assertSee('Member ID Foloni App');

        $this->get(route('admin.invoices.index'))
            ->assertOk()
            ->assertSee('Daftar Invoice')
            ->assertSee('INVTEST0001');

        $this->get(route('admin.invoices.export'))
            ->assertOk()
            ->assertHeader('content-type', 'application/vnd.ms-excel; charset=UTF-8')
            ->assertSee('INVTEST0001');

        $this->get(route('admin.transactions.index'))
            ->assertOk()
            ->assertSee('Daftar Transaksi')
            ->assertSee('INVTEST0001')
            ->assertSee('250 poin');

        $this->get(route('admin.transactions.export'))
            ->assertOk()
            ->assertHeader('content-type', 'application/vnd.ms-excel; charset=UTF-8')
            ->assertSee('INVTEST0001');

        $this->get(route('admin.invoices.show', $transaction))
            ->assertOk()
            ->assertSee('Detail invoice')
            ->assertSee('Produk Demo')
            ->assertSee('Poin Member');

        $this->get(route('admin.products.index'))
            ->assertOk()
            ->assertSee('Daftar Produk')
            ->assertSee('Produk Demo');

        $this->get(route('admin.products.export'))
            ->assertOk()
            ->assertHeader('content-type', 'application/vnd.ms-excel; charset=UTF-8')
            ->assertSee('Produk Demo');

        $product = Product::query()->firstOrFail();

        $this->get(route('admin.products.show', $product))
            ->assertOk()
            ->assertSee('Ringkasan Produk')
            ->assertSee('Riwayat Penjualan Terkait')
            ->assertSee('Produk Demo');

        $this->get(route('admin.member-points.index'))
            ->assertOk()
            ->assertSee('Riwayat Poin Member')
            ->assertSee('Member Demo')
            ->assertSee('verified');

        $this->get(route('admin.member-points.export'))
            ->assertOk()
            ->assertHeader('content-type', 'application/vnd.ms-excel; charset=UTF-8')
            ->assertSee('Member Demo');
    }

    public function test_admin_login_rejects_invalid_credentials(): void
    {
        $this->from('/admin/login')->post('/admin/login', [
            'user' => 'adm.folonykasir@foodcoloni.com',
            'password' => 'wrong-password',
        ])
            ->assertRedirect('/admin/login')
            ->assertSessionHasErrors('user');
    }
}
