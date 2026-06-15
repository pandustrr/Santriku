<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;
use Database\Seeders\RoleAndPermissionSeeder;
use App\Models\User;

class AuthTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        // Seed roles, permissions, and test users
        $this->seed(RoleAndPermissionSeeder::class);
    }

    /**
     * Test login with valid credentials (email or username).
     */
    public function test_user_can_login_with_email(): void
    {
        $response = $this->postJson('/api/auth/login', [
            'email' => 'admin@santriku.com',
            'password' => '123456',
        ]);

        $response->assertStatus(200)
            ->assertJsonStructure([
                'access_token',
                'token_type',
                'user' => [
                    'id',
                    'name',
                    'email',
                    'username',
                    'roles',
                    'permissions',
                ]
            ]);
    }

    public function test_user_can_login_with_username(): void
    {
        $response = $this->postJson('/api/auth/login', [
            'email' => 'pengurus',
            'password' => '123456',
        ]);

        $response->assertStatus(200)
            ->assertJsonPath('user.username', 'pengurus')
            ->assertJsonPath('user.name', 'Hakim Abdullah');
    }

    public function test_login_fails_with_invalid_credentials(): void
    {
        $response = $this->postJson('/api/auth/login', [
            'email' => 'admin',
            'password' => 'wrongpassword',
        ]);

        $response->assertStatus(401)
            ->assertJson(['message' => 'Kredensial tidak valid']);
    }

    /**
     * Test retrieving active profile.
     */
    public function test_user_can_get_active_profile(): void
    {
        $user = User::where('username', 'pengurus')->first();
        $token = $user->createToken('test_token')->plainTextToken;

        $response = $this->withHeaders([
            'Authorization' => "Bearer $token",
        ])->getJson('/api/auth/me');

        $response->assertStatus(200)
            ->assertJsonPath('user.username', 'pengurus');
    }

    /**
     * Test logout.
     */
    public function test_user_can_logout(): void
    {
        $user = User::where('username', 'admin')->first();
        $token = $user->createToken('test_token')->plainTextToken;

        $response = $this->withHeaders([
            'Authorization' => "Bearer $token",
        ])->postJson('/api/auth/logout');

        $response->assertStatus(200)
            ->assertJson(['message' => 'Berhasil logout']);

        // Assert token is deleted
        $this->assertEquals(0, $user->tokens()->count());
    }

    /**
     * Test token refreshing.
     */
    public function test_user_can_refresh_token(): void
    {
        $user = User::where('username', 'admin')->first();
        $token = $user->createToken('test_token')->plainTextToken;

        $response = $this->withHeaders([
            'Authorization' => "Bearer $token",
        ])->postJson('/api/auth/refresh');

        $response->assertStatus(200)
            ->assertJsonStructure(['access_token', 'token_type']);
    }

    /**
     * Test storing and destroying device tokens.
     */
    public function test_user_can_manage_device_tokens(): void
    {
        $user = User::where('username', 'wali')->first();
        $token = $user->createToken('test_token')->plainTextToken;

        // Store token
        $response = $this->withHeaders([
            'Authorization' => "Bearer $token",
        ])->postJson('/api/auth/device-token', [
            'token' => 'fcm-device-token-xyz',
            'device_type' => 'android',
        ]);

        $response->assertStatus(200)
            ->assertJson(['message' => 'Device token berhasil disimpan']);

        $this->assertDatabaseHas('device_tokens', [
            'user_id' => $user->id,
            'token' => 'fcm-device-token-xyz',
        ]);

        // Destroy token
        $response = $this->withHeaders([
            'Authorization' => "Bearer $token",
        ])->deleteJson('/api/auth/device-token', [
            'token' => 'fcm-device-token-xyz',
        ]);

        $response->assertStatus(200)
            ->assertJson(['message' => 'Device token berhasil dihapus']);

        $this->assertDatabaseMissing('device_tokens', [
            'token' => 'fcm-device-token-xyz',
        ]);
    }
}
