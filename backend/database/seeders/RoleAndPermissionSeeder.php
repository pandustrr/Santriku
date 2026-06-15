<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

use Spatie\Permission\Models\Role;
use Spatie\Permission\Models\Permission;
use App\Models\User;
use App\Models\Santri;
use Illuminate\Support\Facades\Hash;

class RoleAndPermissionSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Reset cached roles and permissions
        app()[\Spatie\Permission\PermissionRegistrar::class]->forgetCachedPermissions();

        // Create permissions
        $permissions = [
            'manage-users',
            'export-reports',
            'scan-attendance',
            'scan-consumption',
            'approve-permissions',
            'submit-permissions',
            'view-student-logs',
        ];

        foreach ($permissions as $permission) {
            Permission::create(['name' => $permission]);
        }

        // Create roles and assign permissions
        $adminRole = Role::create(['name' => 'admin']);
        $adminRole->givePermissionTo([
            'manage-users',
            'export-reports',
            'view-student-logs',
        ]);

        $pengurusRole = Role::create(['name' => 'pengurus']);
        $pengurusRole->givePermissionTo([
            'scan-attendance',
            'scan-consumption',
            'approve-permissions',
            'view-student-logs',
        ]);

        $waliRole = Role::create(['name' => 'wali_santri']);
        $waliRole->givePermissionTo([
            'submit-permissions',
            'view-student-logs',
        ]);

        // Create default test users
        $admin = User::create([
            'name' => 'Administrator',
            'email' => 'admin@santriku.com',
            'username' => 'admin',
            'password' => Hash::make('123456'),
        ]);
        $admin->assignRole($adminRole);

        $pengurus = User::create([
            'name' => 'Hakim Abdullah',
            'email' => 'pengurus@santriku.com',
            'username' => 'pengurus',
            'password' => Hash::make('123456'),
        ]);
        $pengurus->assignRole($pengurusRole);

        $wali = User::create([
            'name' => 'Wali Santri Fauzi',
            'email' => 'wali@santriku.com',
            'username' => 'wali',
            'password' => Hash::make('123456'),
        ]);
        $wali->assignRole($waliRole);

        // Seed Santri (Students)
        Santri::create([
            'name' => 'Ahmad Fauzi',
            'nis' => '10101',
            'wali_id' => $wali->id,
            'qr_token' => 'santri_ahmad_fauzi_10101',
        ]);

        Santri::create([
            'name' => 'Muhammad Fatih',
            'nis' => '10102',
            'wali_id' => $wali->id,
            'qr_token' => 'santri_muhammad_fatih_10102',
        ]);

        Santri::create([
            'name' => 'Aisyah',
            'nis' => '10103',
            'wali_id' => null,
            'qr_token' => 'santri_aisyah_10103',
        ]);

        Santri::create([
            'name' => 'Budi Santoso',
            'nis' => '10104',
            'wali_id' => null,
            'qr_token' => 'santri_budi_santoso_10104',
        ]);

        Santri::create([
            'name' => 'Siti Aminah',
            'nis' => '10105',
            'wali_id' => null,
            'qr_token' => 'santri_siti_aminah_10105',
        ]);

        // Seed some Perizinan (Permission Requests)
        $fauzi = Santri::where('name', 'Ahmad Fauzi')->first();
        $fatih = Santri::where('name', 'Muhammad Fatih')->first();
        $aisyah = Santri::where('name', 'Aisyah')->first();
        $budi = Santri::where('name', 'Budi Santoso')->first();

        \App\Models\Perizinan::create([
            'santri_id' => $fauzi->id,
            'wali_id' => $wali->id,
            'jenis_izin' => 'Sakit',
            'tanggal_mulai' => now()->addDays(1)->format('Y-m-d'),
            'tanggal_selesai' => now()->addDays(3)->format('Y-m-d'),
            'alasan' => 'Mengalami demam tinggi dan disarankan istirahat oleh dokter.',
            'status' => 'Pending',
        ]);

        \App\Models\Perizinan::create([
            'santri_id' => $fatih->id,
            'wali_id' => $wali->id,
            'jenis_izin' => 'Pulang',
            'tanggal_mulai' => now()->addDays(2)->format('Y-m-d'),
            'tanggal_selesai' => now()->addDays(5)->format('Y-m-d'),
            'alasan' => 'Ada acara pernikahan kakak kandung di luar kota.',
            'status' => 'Pending',
        ]);

        \App\Models\Perizinan::create([
            'santri_id' => $aisyah->id,
            'wali_id' => $wali->id,
            'jenis_izin' => 'Pulang',
            'tanggal_mulai' => now()->subDays(3)->format('Y-m-d'),
            'tanggal_selesai' => now()->subDays(1)->format('Y-m-d'),
            'alasan' => 'Keperluan keluarga mendesak.',
            'status' => 'Approved',
            'approved_by' => $pengurus->id,
        ]);

        \App\Models\Perizinan::create([
            'santri_id' => $budi->id,
            'wali_id' => $wali->id,
            'jenis_izin' => 'Sakit',
            'tanggal_mulai' => now()->subDays(5)->format('Y-m-d'),
            'tanggal_selesai' => now()->subDays(4)->format('Y-m-d'),
            'alasan' => 'Sakit gigi parah dan harus kontrol ke dokter gigi.',
            'status' => 'Rejected',
            'approved_by' => $pengurus->id,
        ]);

        // Seed some Absensi (Attendance logs) for today
        \App\Models\Absensi::create([
            'santri_id' => $fauzi->id,
            'pengurus_id' => $pengurus->id,
            'status' => 'Hadir',
            'latitude' => -8.12345,
            'longitude' => 113.12345,
            'is_in_range' => true,
            'waktu_absen' => now()->subHours(4),
        ]);

        \App\Models\Absensi::create([
            'santri_id' => $fatih->id,
            'pengurus_id' => $pengurus->id,
            'status' => 'Hadir',
            'latitude' => -8.12345,
            'longitude' => 113.12345,
            'is_in_range' => true,
            'waktu_absen' => now()->subHours(3),
        ]);

        // Seed some Konsumsi (Food consumption claims) for today
        \App\Models\Konsumsi::create([
            'santri_id' => $fauzi->id,
            'pengurus_id' => $pengurus->id,
            'jenis_makan' => 'Sarapan',
            'tanggal' => now()->format('Y-m-d'),
            'waktu_ambil' => now()->subHours(6),
        ]);

        \App\Models\Konsumsi::create([
            'santri_id' => $fatih->id,
            'pengurus_id' => $pengurus->id,
            'jenis_makan' => 'Sarapan',
            'tanggal' => now()->format('Y-m-d'),
            'waktu_ambil' => now()->subHours(5),
        ]);

        \App\Models\Konsumsi::create([
            'santri_id' => $fauzi->id,
            'pengurus_id' => $pengurus->id,
            'jenis_makan' => 'Siang',
            'tanggal' => now()->format('Y-m-d'),
            'waktu_ambil' => now()->subHours(1),
        ]);
    }
}
