<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;
use Database\Seeders\RoleAndPermissionSeeder;
use App\Models\User;
use App\Models\Santri;
use App\Models\Absensi;

class PengurusTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        // Seed Spatie roles, permissions, default users, and default students
        $this->seed(RoleAndPermissionSeeder::class);
    }

    /**
     * Test role protection gate: only pengurus can access pengurus routes.
     */
    public function test_non_pengurus_cannot_access_pengurus_endpoints(): void
    {
        // Login as admin
        $admin = User::where('username', 'admin')->first();
        $token = $admin->createToken('test_token')->plainTextToken;

        $response = $this->withHeaders([
            'Authorization' => "Bearer $token",
        ])->postJson('/api/pengurus/attendance', [
            'qr_token' => 'santri_ahmad_fauzi_10101',
            'latitude' => -8.12345,
            'longitude' => 113.12345,
        ]);

        $response->assertStatus(403); // Forbidden
    }

    /**
     * Test pengurus can scan attendance successfully within range.
     */
    public function test_pengurus_can_record_attendance_within_range(): void
    {
        // Login as pengurus
        $pengurus = User::where('username', 'pengurus')->first();
        $token = $pengurus->createToken('test_token')->plainTextToken;

        $response = $this->withHeaders([
            'Authorization' => "Bearer $token",
        ])->postJson('/api/pengurus/attendance', [
            'qr_token' => 'santri_ahmad_fauzi_10101',
            'latitude' => -8.12340, // very close to -8.12345
            'longitude' => 113.12345,
            'status' => 'Hadir'
        ]);

        $response->assertStatus(201)
            ->assertJson([
                'message' => 'Absensi berhasil dicatat'
            ])
            ->assertJsonStructure([
                'absensi' => ['id', 'santri_name', 'nis', 'status', 'waktu_absen', 'is_in_range', 'distance_meters']
            ]);

        $this->assertDatabaseHas('absensis', [
            'status' => 'Hadir',
            'is_in_range' => true
        ]);
    }

    /**
     * Test pengurus scan fails when outside the geofence radius.
     */
    public function test_pengurus_cannot_record_attendance_outside_range(): void
    {
        // Login as pengurus
        $pengurus = User::where('username', 'pengurus')->first();
        $token = $pengurus->createToken('test_token')->plainTextToken;

        $response = $this->withHeaders([
            'Authorization' => "Bearer $token",
        ])->postJson('/api/pengurus/attendance', [
            'qr_token' => 'santri_ahmad_fauzi_10101',
            'latitude' => -8.20000, // far away
            'longitude' => 113.12345,
            'status' => 'Hadir'
        ]);

        $response->assertStatus(422)
            ->assertJson([
                'message' => 'Gagal: Lokasi tidak sesuai. Pengurus berada di luar area pondok pesantren (8512m dari pusat).'
            ]);

        $this->assertDatabaseMissing('absensis', [
            'latitude' => -8.20000
        ]);
    }

    /**
     * Test scan fails for invalid student QR token.
     */
    public function test_pengurus_cannot_record_attendance_for_invalid_token(): void
    {
        // Login as pengurus
        $pengurus = User::where('username', 'pengurus')->first();
        $token = $pengurus->createToken('test_token')->plainTextToken;

        $response = $this->withHeaders([
            'Authorization' => "Bearer $token",
        ])->postJson('/api/pengurus/attendance', [
            'qr_token' => 'invalid_token_xyz',
            'latitude' => -8.12345,
            'longitude' => 113.12345,
        ]);

        $response->assertStatus(404)
            ->assertJson([
                'message' => 'Santri tidak ditemukan untuk QR Code ini.'
            ]);
    }

    /**
     * Test pengurus can scan food consumption successfully.
     */
    public function test_pengurus_can_record_consumption_successfully(): void
    {
        $pengurus = User::where('username', 'pengurus')->first();
        $token = $pengurus->createToken('test_token')->plainTextToken;

        $response = $this->withHeaders([
            'Authorization' => "Bearer $token",
        ])->postJson('/api/pengurus/consumption', [
            'qr_token' => 'santri_aisyah_10103',
            'jenis_makan' => 'Siang'
        ]);

        $response->assertStatus(201)
            ->assertJson([
                'message' => 'Jatah makan siang berhasil diambil.'
            ])
            ->assertJsonStructure([
                'consumption' => ['id', 'santri_name', 'nis', 'jenis_makan', 'waktu_ambil']
            ]);

        $this->assertDatabaseHas('konsumsis', [
            'jenis_makan' => 'Siang',
            'tanggal' => date('Y-m-d')
        ]);
    }

    /**
     * Test pengurus cannot record duplicate food consumption for same student today.
     */
    public function test_pengurus_cannot_record_duplicate_consumption(): void
    {
        $pengurus = User::where('username', 'pengurus')->first();
        $token = $pengurus->createToken('test_token')->plainTextToken;

        // First claim
        $this->withHeaders([
            'Authorization' => "Bearer $token",
        ])->postJson('/api/pengurus/consumption', [
            'qr_token' => 'santri_ahmad_fauzi_10101',
            'jenis_makan' => 'Malam'
        ]);

        // Second duplicate claim
        $response = $this->withHeaders([
            'Authorization' => "Bearer $token",
        ])->postJson('/api/pengurus/consumption', [
            'qr_token' => 'santri_ahmad_fauzi_10101',
            'jenis_makan' => 'Malam'
        ]);

        $response->assertStatus(400)
            ->assertJsonFragment([
                'message' => 'Gagal: Jatah makan malam sudah diambil oleh Ahmad Fauzi pada ' . date('H:i') . ' WIB.'
            ]);
     }

    /**
     * Test pengurus can view permission requests list.
     */
    public function test_pengurus_can_view_permissions_list(): void
    {
        $pengurus = User::where('username', 'pengurus')->first();
        $token = $pengurus->createToken('test_token')->plainTextToken;

        $santri = Santri::first();
        $wali = User::where('username', 'wali')->first();
        \App\Models\Perizinan::create([
            'santri_id' => $santri->id,
            'wali_id' => $wali->id,
            'jenis_izin' => 'Sakit',
            'tanggal_mulai' => '2026-06-16',
            'tanggal_selesai' => '2026-06-18',
            'alasan' => 'Demam berdarah',
            'status' => 'Pending',
        ]);

        $response = $this->withHeaders([
            'Authorization' => "Bearer $token",
        ])->getJson('/api/pengurus/permissions');

        $response->assertStatus(200)->assertJsonCount(5);
    }

    /**
     * Test pengurus can approve permission request.
     */
    public function test_pengurus_can_approve_permission(): void
    {
        $pengurus = User::where('username', 'pengurus')->first();
        $token = $pengurus->createToken('test_token')->plainTextToken;

        $santri = Santri::first();
        $wali = User::where('username', 'wali')->first();
        $perizinan = \App\Models\Perizinan::create([
            'santri_id' => $santri->id,
            'wali_id' => $wali->id,
            'jenis_izin' => 'Sakit',
            'tanggal_mulai' => '2026-06-16',
            'tanggal_selesai' => '2026-06-18',
            'alasan' => 'Demam berdarah',
            'status' => 'Pending',
        ]);

        $response = $this->withHeaders([
            'Authorization' => "Bearer $token",
        ])->putJson("/api/pengurus/permissions/{$perizinan->id}", [
            'status' => 'Approved'
        ]);

        $response->assertStatus(200);
        $this->assertEquals('Approved', $perizinan->fresh()->status);
        $this->assertEquals($pengurus->id, $perizinan->fresh()->approved_by);
    }

    /**
     * Test pengurus can reject permission request.
     */
    public function test_pengurus_can_reject_permission(): void
    {
        $pengurus = User::where('username', 'pengurus')->first();
        $token = $pengurus->createToken('test_token')->plainTextToken;

        $santri = Santri::first();
        $wali = User::where('username', 'wali')->first();
        $perizinan = \App\Models\Perizinan::create([
            'santri_id' => $santri->id,
            'wali_id' => $wali->id,
            'jenis_izin' => 'Sakit',
            'tanggal_mulai' => '2026-06-16',
            'tanggal_selesai' => '2026-06-18',
            'alasan' => 'Demam berdarah',
            'status' => 'Pending',
        ]);

        $response = $this->withHeaders([
            'Authorization' => "Bearer $token",
        ])->putJson("/api/pengurus/permissions/{$perizinan->id}", [
            'status' => 'Rejected'
        ]);

        $response->assertStatus(200);
        $this->assertEquals('Rejected', $perizinan->fresh()->status);
        $this->assertEquals($pengurus->id, $perizinan->fresh()->approved_by);
    }

    /**
     * Test pengurus can retrieve consumption statistics.
     */
    public function test_pengurus_can_get_consumption_statistics(): void
    {
        $pengurus = User::where('username', 'pengurus')->first();
        $token = $pengurus->createToken('test_token')->plainTextToken;

        $response = $this->withHeaders([
            'Authorization' => "Bearer $token",
        ])->getJson('/api/pengurus/consumption-stats');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'date_raw',
                'total_santri',
                'stats' => [
                    '*' => ['title', 'time', 'total', 'taken', 'is_done']
                ]
            ]);
    }

    /**
     * Test pengurus can store or update consumption food portion quota.
     */
    public function test_pengurus_can_store_or_update_consumption_stats(): void
    {
        $pengurus = User::where('username', 'pengurus')->first();
        $token = $pengurus->createToken('test_token')->plainTextToken;

        // Store quota of 150 for Siang
        $response = $this->withHeaders([
            'Authorization' => "Bearer $token",
        ])->postJson('/api/pengurus/consumption-stats', [
            'jenis_makan' => 'Siang',
            'porsi_total' => 150
        ]);

        $response->assertStatus(200)
            ->assertJson([
                'message' => 'Kuota porsi makan berhasil diperbarui'
            ])
            ->assertJsonStructure([
                'stok' => ['id', 'tanggal', 'jenis_makan', 'porsi_total']
            ]);

        $this->assertDatabaseHas('stok_makanans', [
            'jenis_makan' => 'Siang',
            'porsi_total' => 150
        ]);

        // Get stats and assert total portions is now 150 for Siang
        $getStatsResponse = $this->withHeaders([
            'Authorization' => "Bearer $token",
        ])->getJson('/api/pengurus/consumption-stats');

        $getStatsResponse->assertStatus(200);
        $stats = $getStatsResponse->json('stats');
        
        $siangStat = collect($stats)->firstWhere('title', 'Makan Siang');
        $this->assertEquals(150, $siangStat['total']);
    }

    /**
     * Test pengurus can retrieve dashboard stats.
     */
    public function test_pengurus_can_get_dashboard_stats(): void
    {
        $pengurus = User::where('username', 'pengurus')->first();
        $token = $pengurus->createToken('test_token')->plainTextToken;

        $response = $this->withHeaders([
            'Authorization' => "Bearer $token",
        ])->getJson('/api/pengurus/dashboard-stats');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'total_santri',
                'verified_attendance_count',
                'consumption' => ['taken', 'total', 'sarapan', 'siang', 'malam'],
                'pending_permissions_count'
            ]);
    }

    /**
     * Test pengurus can retrieve activity logs.
     */
    public function test_pengurus_can_get_activity_logs(): void
    {
        $pengurus = User::where('username', 'pengurus')->first();
        $token = $pengurus->createToken('test_token')->plainTextToken;

        $response = $this->withHeaders([
            'Authorization' => "Bearer $token",
        ])->getJson('/api/pengurus/activity-logs');

        $response->assertStatus(200)
            ->assertJsonStructure([
                '*' => ['id', 'type', 'title', 'student_name', 'detail', 'time', 'timestamp']
            ]);
    }
}
