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
    }
}
