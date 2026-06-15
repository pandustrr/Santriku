<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;
use Database\Seeders\RoleAndPermissionSeeder;
use App\Models\User;
use App\Models\Santri;

class AdminTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        // Seed Spatie roles, permissions, default users, and default students
        $this->seed(RoleAndPermissionSeeder::class);
    }

    /**
     * Test role protection gate: only admin can access admin routes.
     */
    public function test_non_admin_cannot_access_admin_endpoints(): void
    {
        // Login as pengurus
        $pengurus = User::where('username', 'pengurus')->first();
        $token = $pengurus->createToken('test_token')->plainTextToken;

        $response = $this->withHeaders([
            'Authorization' => "Bearer $token",
        ])->getJson('/api/admin/dashboard-stats');

        $response->assertStatus(403); // Forbidden
    }

    public function test_admin_can_access_dashboard_stats(): void
    {
        $admin = User::where('username', 'admin')->first();
        $token = $admin->createToken('test_token')->plainTextToken;

        $response = $this->withHeaders([
            'Authorization' => "Bearer $token",
        ])->getJson('/api/admin/dashboard-stats');

        $response->assertStatus(200)
            ->assertJson([
                'total_santri' => 5,
                'total_pengurus' => 1,
                'total_wali' => 1,
            ]);
    }

    /**
     * User management CRUD tests.
     */
    public function test_admin_can_crud_users(): void
    {
        $admin = User::where('username', 'admin')->first();
        $token = $admin->createToken('test_token')->plainTextToken;

        // 1. List users
        $response = $this->withHeaders([
            'Authorization' => "Bearer $token",
        ])->getJson('/api/admin/users');

        $response->assertStatus(200)->assertJsonCount(3); // admin, pengurus, wali

        // 2. Store new user
        $response = $this->withHeaders([
            'Authorization' => "Bearer $token",
        ])->postJson('/api/admin/users', [
            'name' => 'Pengurus Baru',
            'email' => 'pengurusbaru@santriku.com',
            'username' => 'pengurusbaru',
            'password' => '123456',
            'role' => 'pengurus',
        ]);

        $response->assertStatus(201);
        $this->assertDatabaseHas('users', ['username' => 'pengurusbaru']);

        $newUser = User::where('username', 'pengurusbaru')->first();
        $this->assertTrue($newUser->hasRole('pengurus'));

        // 3. Update user
        $response = $this->withHeaders([
            'Authorization' => "Bearer $token",
        ])->putJson("/api/admin/users/{$newUser->id}", [
            'name' => 'Pengurus Baru Diperbarui',
            'email' => 'pengurusbaru@santriku.com',
            'username' => 'pengurusbaru',
            'role' => 'admin', // Upgrade to admin
        ]);

        $response->assertStatus(200);
        $this->assertTrue($newUser->fresh()->hasRole('admin'));

        // 4. Delete user
        $response = $this->withHeaders([
            'Authorization' => "Bearer $token",
        ])->deleteJson("/api/admin/users/{$newUser->id}");

        $response->assertStatus(200);
        $this->assertDatabaseMissing('users', ['id' => $newUser->id]);
    }

    /**
     * Student management CRUD tests.
     */
    public function test_admin_can_crud_santri(): void
    {
        $admin = User::where('username', 'admin')->first();
        $token = $admin->createToken('test_token')->plainTextToken;

        // 1. List santri
        $response = $this->withHeaders([
            'Authorization' => "Bearer $token",
        ])->getJson('/api/admin/santri');

        $response->assertStatus(200)->assertJsonCount(5);

        $response = $this->withHeaders([
            'Authorization' => "Bearer $token",
        ])->postJson('/api/admin/santri', [
            'name' => 'Santri Baru',
            'nis' => '10106',
            'wali_id' => null,
            'qr_token' => 'santri_baru_10106',
        ]);

        $response->assertStatus(201);
        $this->assertDatabaseHas('santris', ['nis' => '10106']);
        $newSantri = Santri::where('nis', '10106')->first();

        // 3. Update santri
        $response = $this->withHeaders([
            'Authorization' => "Bearer $token",
        ])->putJson("/api/admin/santri/{$newSantri->id}", [
            'name' => 'Santri Baru Diperbarui',
            'nis' => '10106',
            'wali_id' => null,
            'qr_token' => 'santri_baru_10106',
        ]);

        $response->assertStatus(200);
        $this->assertEquals('Santri Baru Diperbarui', $newSantri->fresh()->name);

        // 4. Delete santri
        $response = $this->withHeaders([
            'Authorization' => "Bearer $token",
        ])->deleteJson("/api/admin/santri/{$newSantri->id}");

        $response->assertStatus(200);
        $this->assertDatabaseMissing('santris', ['id' => $newSantri->id]);
    }
}
