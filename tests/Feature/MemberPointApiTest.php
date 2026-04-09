<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Config;
use Illuminate\Support\Facades\Http;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class MemberPointApiTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        Cache::flush();
        Config::set('services.foloni_app_admin.login_url', 'https://foloni.test/adm/user/login');
        Config::set('services.foloni_app_admin.member_points_url', 'https://foloni.test/adm/finance/poin/member');
        Config::set('services.foloni_app_admin.point_history_url', 'https://foloni.test/adm/finance/poin/history');
        Config::set('services.foloni_app_admin.point_mutation_url', 'https://foloni.test/adm/finance/poin');
        Config::set('services.foloni_app_admin.user', 'admin@example.com');
        Config::set('services.foloni_app_admin.password', 'secret');
        Config::set('services.foloni_app_admin.token_cache_minutes', 30);
    }

    public function test_authenticated_user_can_lookup_member_points_by_member_id(): void
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
                            'name' => 'yudosand',
                            'poin' => 10982265,
                        ],
                    ],
                    'totalrecords' => 1,
                ],
            ], 200),
        ]);

        Sanctum::actingAs(User::factory()->create([
            'phone' => '081234567890',
        ]));

        $response = $this->getJson('/api/member-points/members?member_id=11');

        $response
            ->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.members.0.id', 11)
            ->assertJsonPath('data.members.0.name', 'yudosand')
            ->assertJsonPath('data.members.0.points', 10982265)
            ->assertJsonPath('data.total_records', 1);

        Http::assertSentCount(2);
        Http::assertSent(fn ($request) => $request->url() === 'https://foloni.test/adm/user/login');
        Http::assertSent(fn ($request) => $request->url() === 'https://foloni.test/adm/finance/poin/member?id=11');
    }

    public function test_member_lookup_returns_service_error_when_foloni_app_admin_login_fails(): void
    {
        Http::fake([
            'https://foloni.test/adm/user/login' => Http::response([
                'status_code' => 0,
                'message' => 'Unauthorized',
                'result' => null,
            ], 200),
        ]);

        Sanctum::actingAs(User::factory()->create([
            'phone' => '081234567890',
        ]));

        $this->getJson('/api/member-points/members?member_id=11')
            ->assertStatus(503)
            ->assertJsonPath('success', false)
            ->assertJsonPath('message', 'Login admin Foloni App belum berhasil. Coba lagi sebentar ya.');
    }

    public function test_authenticated_user_can_mutate_member_points(): void
    {
        Http::fake([
            'https://foloni.test/adm/user/login' => Http::response([
                'status_code' => 1,
                'message' => 'Login berhasil!',
                'result' => [
                    'token' => 'foloni-admin-token',
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

        Sanctum::actingAs(User::factory()->create([
            'phone' => '081234567890',
        ]));

        $response = $this->postJson('/api/member-points/mutations', [
            'member_id' => 11,
            'type' => '2',
            'amount' => 10000,
            'description' => 'Potong poin QA',
        ]);

        $response
            ->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('message', 'Mutasi poin berhasil!')
            ->assertJsonPath('data.mutation.member_id', 11)
            ->assertJsonPath('data.mutation.type', '2')
            ->assertJsonPath('data.mutation.amount', 10000)
            ->assertJsonPath('data.mutation.description', 'Potong poin QA');

        Http::assertSent(fn ($request) =>
            $request->url() === 'https://foloni.test/adm/finance/poin'
            && $request['user_ids'] === [11]
            && $request['type'] === '2'
            && $request['amount'] === '10000'
            && $request['description'] === 'Potong poin QA'
        );
    }

    public function test_service_can_find_matching_point_history_entry(): void
    {
        Http::fake([
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
                    'data' => [
                        [
                            'id' => 11,
                            'name' => 'yudosand',
                            'type' => 'Kurang',
                            'transaction_type' => 'Penyesuaian',
                            'description' => 'Potong poin invoice INV202604060017',
                            'amount' => '25.000',
                            'created_at' => '06-04-2026 14:20:49',
                            'created_by' => 'Folony Kasir',
                        ],
                    ],
                    'totalrecords' => 1,
                ],
            ], 200),
        ]);

        $service = app(\App\Services\FoloniAppMemberPointService::class);

        $entry = $service->findMatchingPointHistory(
            memberId: 11,
            type: 'Kurang',
            amount: 25000,
            description: 'Potong poin invoice INV202604060017',
        );

        $this->assertNotNull($entry);
        $this->assertSame(11, $entry['member_id']);
        $this->assertSame('Kurang', $entry['type']);
        $this->assertSame(25000, $entry['amount']);
    }

    public function test_member_point_mutation_returns_service_error_when_provider_rejects_request(): void
    {
        Http::fake([
            'https://foloni.test/adm/user/login' => Http::response([
                'status_code' => 1,
                'message' => 'Login berhasil!',
                'result' => [
                    'token' => 'foloni-admin-token',
                ],
            ], 200),
            'https://foloni.test/adm/finance/poin' => Http::response([
                'status_code' => 0,
                'message' => 'Saldo poin member tidak cukup',
            ], 200),
        ]);

        Sanctum::actingAs(User::factory()->create([
            'phone' => '081234567890',
        ]));

        $this->postJson('/api/member-points/mutations', [
            'member_id' => 11,
            'type' => '2',
            'amount' => 10000,
            'description' => 'Potong poin QA',
        ])
            ->assertStatus(503)
            ->assertJsonPath('success', false)
            ->assertJsonPath('message', 'Saldo poin member tidak cukup');
    }
}
