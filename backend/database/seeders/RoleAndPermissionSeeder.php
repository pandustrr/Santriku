<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

use Spatie\Permission\Models\Role;
use Spatie\Permission\Models\Permission;
use App\Models\User;
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
    }
}
