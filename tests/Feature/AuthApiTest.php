<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Support\Facades\File;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Config;
use Illuminate\Support\Facades\Http;
use Laravel\Sanctum\PersonalAccessToken;
use Illuminate\Support\Str;
use Tests\TestCase;

class AuthApiTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        Config::set('services.foodukm_auth.login_url', 'https://foloni.test/app/api_login_v2');
        Config::set('services.foodukm_auth.register_url', 'https://foloni.test/app/api_registrasi_v2');
        Config::set('services.foloni_app_admin.login_url', 'https://foloni.test/adm/user/login');
        Config::set('admin-dashboard.name', 'Folony Kasir Admin');

        $compiledPath = storage_path('framework/views/auth-api-tests-'.Str::random(10));
        File::ensureDirectoryExists($compiledPath);
        Config::set('view.compiled', $compiledPath);
    }

    public function test_login_via_external_auth_syncs_local_user_and_returns_local_token(): void
    {
        Http::fake([
            'https://foloni.test/app/api_login_v2' => Http::response([
                'statusCode' => 1,
                'message' => 'Login berhasil!',
                'result' => [
                    'token' => 'external-token',
                    'name' => 'Yudosand',
                    'idmember' => '11',
                    'hp' => '085891585422',
                    'email' => 'yudosand@gmail.com',
                    'accountType' => 'Personal',
                    'defaultLocation' => [
                        'lat' => '-6.200',
                        'long' => '106.816',
                    ],
                ],
            ], 200),
        ]);

        $response = $this->postJson('/api/auth/login', [
            'phone' => '085891585422',
            'password' => '123456',
            'id_device' => 'qa-device',
            'os_version' => 'android',
        ]);

        $response
            ->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('message', 'Login successful.')
            ->assertJsonPath('data.user.phone', '085891585422')
            ->assertJsonPath('data.user.external_member_id', '11');

        $this->assertDatabaseHas('users', [
            'phone' => '085891585422',
            'email' => 'yudosand@gmail.com',
            'external_member_id' => '11',
            'account_type' => 'Personal',
        ]);

        $user = User::query()->where('phone', '085891585422')->firstOrFail();

        $this->assertNotNull($user->external_synced_at);
        $this->assertSame('external-token', $user->external_auth_token);
        $this->assertCount(1, $user->tokens);
    }

    public function test_login_returns_validation_error_for_invalid_external_credentials(): void
    {
        Http::fake([
            'https://foloni.test/app/api_login_v2' => Http::response([
                'statusCode' => 0,
                'message' => 'Userid / Password salah',
            ], 200),
        ]);

        $this->postJson('/api/auth/login', [
            'phone' => '085891585422',
            'password' => 'wrong-password',
        ])
            ->assertStatus(422)
            ->assertJsonPath('success', false)
            ->assertJsonPath('message', 'Validation error')
            ->assertJsonPath('errors.phone.0', 'Nomor HP atau password belum cocok. Coba cek lagi ya.');
    }

    public function test_login_revokes_previous_local_token_for_same_user(): void
    {
        $user = User::factory()->create([
            'phone' => '085891585422',
            'password' => '123456',
        ]);

        $oldToken = $user->createToken('old-device')->plainTextToken;

        Http::fake([
            'https://foloni.test/app/api_login_v2' => Http::response([
                'statusCode' => 0,
                'message' => 'Userid / Password salah',
            ], 200),
        ]);

        $response = $this->postJson('/api/auth/login', [
            'phone' => '085891585422',
            'password' => '123456',
        ]);

        $response
            ->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.user.phone', '085891585422');

        $user->refresh();

        $this->assertCount(1, $user->tokens);
        $this->assertDatabaseMissing('personal_access_tokens', [
            'tokenable_id' => $user->id,
            'name' => 'old-device',
        ]);

        $issuedToken = $response->json('data.token');
        $plainTextToken = explode('|', (string) $issuedToken, 2)[1] ?? '';
        $tokenHash = hash('sha256', $plainTextToken);

        $this->assertDatabaseHas('personal_access_tokens', [
            'tokenable_id' => $user->id,
            'token' => $tokenHash,
        ]);

        $this->assertNull(PersonalAccessToken::findToken($oldToken));
        $this->assertNotNull(PersonalAccessToken::findToken((string) $issuedToken));
    }

    public function test_user_synced_from_api_login_is_visible_in_admin_dashboard(): void
    {
        Http::fake([
            'https://foloni.test/app/api_login_v2' => Http::response([
                'statusCode' => 1,
                'message' => 'Login berhasil!',
                'result' => [
                    'token' => 'external-token',
                    'name' => 'Yudosand',
                    'idmember' => '11',
                    'hp' => '085891585422',
                    'email' => 'yudosand@gmail.com',
                    'accountType' => 'Personal',
                ],
            ], 200),
            'https://foloni.test/adm/user/login' => Http::response([
                'status_code' => 1,
                'message' => 'Login berhasil!',
                'result' => [
                    'token' => 'dashboard-admin-token',
                    'name' => 'Admin Dashboard',
                ],
            ], 200),
        ]);

        $this->postJson('/api/auth/login', [
            'phone' => '085891585422',
            'password' => '123456',
            'id_device' => 'qa-device',
            'os_version' => 'android',
        ])->assertOk();

        $this->post('/admin/login', [
            'user' => 'adm.folonykasir@foodcoloni.com',
            'password' => 'secret-admin',
        ])->assertRedirect(route('admin.dashboard'));

        $this->get(route('admin.users.index'))
            ->assertOk()
            ->assertSee('Daftar User')
            ->assertSee('Yudosand')
            ->assertSee('085891585422')
            ->assertSee('11');
    }
}
