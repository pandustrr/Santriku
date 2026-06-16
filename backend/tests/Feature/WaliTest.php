<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;
use Database\Seeders\RoleAndPermissionSeeder;
use App\Models\User;
use App\Models\Santri;
use App\Models\Perizinan;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;

class WaliTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        // Seed database roles, permissions, users, and santri
        $this->seed(RoleAndPermissionSeeder::class);
    }

    /**
     * Test role protection: only wali can access wali routes.
     */
    public function test_non_wali_cannot_access_wali_endpoints(): void
    {
        $pengurus = User::where('username', 'pengurus')->first();
        $token = $pengurus->createToken('test_token')->plainTextToken;

        $response = $this->withHeaders([
            'Authorization' => "Bearer $token",
        ])->getJson('/api/wali/santri');

        $response->assertStatus(403);
    }

    /**
     * Test wali can retrieve their linked children list.
     */
    public function test_wali_can_get_children_list(): void
    {
        $wali = User::where('username', 'wali')->first();
        $token = $wali->createToken('test_token')->plainTextToken;

        $response = $this->withHeaders([
            'Authorization' => "Bearer $token",
        ])->getJson('/api/wali/santri');

        $response->assertStatus(200)
            ->assertJsonCount(2); // Wali Fauzi has 2 seeded children: Ahmad Fauzi & Muhammad Fatih
    }

    /**
     * Test wali can retrieve child dashboard stats.
     */
    public function test_wali_can_get_child_dashboard_stats(): void
    {
        $wali = User::where('username', 'wali')->first();
        $token = $wali->createToken('test_token')->plainTextToken;
        $santri = Santri::where('name', 'Ahmad Fauzi')->first();

        $response = $this->withHeaders([
            'Authorization' => "Bearer $token",
        ])->getJson("/api/wali/santri/{$santri->id}/dashboard");

        $response->assertStatus(200)
            ->assertJsonStructure([
                'santri',
                'absensi_status',
                'consumption' => ['sarapan', 'siang', 'malam'],
                'izin_status',
                'activities'
            ]);
    }

    /**
     * Test wali cannot access statistics for a student not linked to them.
     */
    public function test_wali_cannot_access_other_wali_child_stats(): void
    {
        $wali = User::where('username', 'wali')->first();
        $token = $wali->createToken('test_token')->plainTextToken;

        // Aisyah is seeded with no wali (wali_id = null)
        $aisyah = Santri::where('name', 'Aisyah')->first();

        $response = $this->withHeaders([
            'Authorization' => "Bearer $token",
        ])->getJson("/api/wali/santri/{$aisyah->id}/dashboard");

        $response->assertStatus(403);
    }

    /**
     * Test wali can view permissions history of their child.
     */
    public function test_wali_can_get_child_permissions_history(): void
    {
        $wali = User::where('username', 'wali')->first();
        $token = $wali->createToken('test_token')->plainTextToken;
        $santri = Santri::where('name', 'Ahmad Fauzi')->first();

        $response = $this->withHeaders([
            'Authorization' => "Bearer $token",
        ])->getJson("/api/wali/santri/{$santri->id}/permissions");

        $response->assertStatus(200)
            ->assertJsonCount(1); // Ahmad Fauzi has 1 seeded pending permit
    }

    /**
     * Test wali can submit a new leave permission request with file upload.
     */
    public function test_wali_can_submit_leave_permission(): void
    {
        Storage::fake('public');

        $wali = User::where('username', 'wali')->first();
        $token = $wali->createToken('test_token')->plainTextToken;
        $santri = Santri::where('name', 'Ahmad Fauzi')->first();

        $file = UploadedFile::fake()->image('dokter_note.jpg');

        $response = $this->withHeaders([
            'Authorization' => "Bearer $token",
        ])->postJson("/api/wali/santri/{$santri->id}/permissions", [
            'jenis_izin' => 'Sakit',
            'tanggal_mulai' => '2026-06-20',
            'tanggal_selesai' => '2026-06-22',
            'alasan' => 'Operasi amandel',
            'bukti' => $file,
        ]);

        $response->assertStatus(201)
            ->assertJsonStructure([
                'message',
                'perizinan' => ['id', 'santri_id', 'wali_id', 'jenis_izin', 'tanggal_mulai', 'tanggal_selesai', 'alasan', 'bukti_path', 'status']
            ]);

        $this->assertDatabaseHas('perizinans', [
            'jenis_izin' => 'Sakit',
            'alasan' => 'Operasi amandel',
            'status' => 'Pending'
        ]);

        $path = $response->json('perizinan.bukti_path');
        Storage::disk('public')->assertExists($path);
    }
}
