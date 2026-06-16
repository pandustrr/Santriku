<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\User;
use App\Models\Santri;
use Illuminate\Support\Facades\Hash;

class AdminController extends Controller
{
    /**
     * Authorize that the logged in user has the admin role.
     */
    private function authorizeAdmin()
    {
        if (!auth()->user() || !auth()->user()->hasRole('admin')) {
            abort(403, 'Forbidden. Admin role required.');
        }
    }

    /**
     * Get summary metrics for the Admin Dashboard.
     */
    public function dashboardStats()
    {
        $this->authorizeAdmin();

        $totalSantri = Santri::count();
        
        // Count users by Spatie role
        $totalPengurus = User::role('pengurus')->count();
        $totalWali = User::role('wali_santri')->count();
        
        $todayAttendanceCount = 0; // Connected in future attendance module

        return response()->json([
            'total_santri' => $totalSantri,
            'total_pengurus' => $totalPengurus,
            'total_wali' => $totalWali,
            'attendance_rate' => $totalSantri > 0 ? ($todayAttendanceCount / $totalSantri) * 100 : 0,
        ]);
    }

    /**
     * Get list of all users along with their roles.
     */
    public function getUsers()
    {
        $this->authorizeAdmin();

        $users = User::with('roles')->get()->map(function($user) {
            return [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'username' => $user->username,
                'roles' => $user->getRoleNames(),
            ];
        });

        return response()->json($users);
    }

    /**
     * Add a new user (admin, pengurus, or wali_santri).
     */
    public function storeUser(Request $request)
    {
        $this->authorizeAdmin();

        $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'username' => 'required|string|max:255|unique:users',
            'password' => 'required|string|min:6',
            'role' => 'required|string|in:admin,pengurus,wali_santri',
        ]);

        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'username' => $request->username,
            'password' => Hash::make($request->password),
        ]);

        $user->assignRole($request->role);

        return response()->json([
            'message' => 'User berhasil ditambahkan',
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'username' => $user->username,
                'roles' => $user->getRoleNames(),
            ]
        ], 201);
    }

    /**
     * Update existing user profile or role.
     */
    public function updateUser(Request $request, $id)
    {
        $this->authorizeAdmin();

        $user = User::findOrFail($id);

        $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users,email,' . $user->id,
            'username' => 'required|string|max:255|unique:users,username,' . $user->id,
            'password' => 'nullable|string|min:6',
            'role' => 'required|string|in:admin,pengurus,wali_santri',
        ]);

        $user->name = $request->name;
        $user->email = $request->email;
        $user->username = $request->username;
        
        if ($request->filled('password')) {
            $user->password = Hash::make($request->password);
        }

        $user->save();

        $user->syncRoles([$request->role]);

        return response()->json([
            'message' => 'User berhasil diperbarui',
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'username' => $user->username,
                'roles' => $user->getRoleNames(),
            ]
        ]);
    }

    /**
     * Delete user from the database.
     */
    public function destroyUser($id)
    {
        $this->authorizeAdmin();

        $user = User::findOrFail($id);
        $user->delete();

        return response()->json([
            'message' => 'User berhasil dihapus'
        ]);
    }

    /**
     * Retrieve list of all students.
     */
    public function getSantris()
    {
        $this->authorizeAdmin();

        $santris = Santri::with('wali')->get();
        return response()->json($santris);
    }

    /**
     * Create a new student profile.
     */
    public function storeSantri(Request $request)
    {
        $this->authorizeAdmin();

        $request->validate([
            'name' => 'required|string|max:255',
            'nis' => 'required|string|max:255|unique:santris',
            'wali_id' => 'nullable|exists:users,id',
            'qr_token' => 'required|string|max:255|unique:santris',
        ]);

        $santri = Santri::create($request->all());

        return response()->json([
            'message' => 'Santri berhasil ditambahkan',
            'santri' => $santri
        ], 201);
    }

    /**
     * Edit a student profile.
     */
    public function updateSantri(Request $request, $id)
    {
        $this->authorizeAdmin();

        $santri = Santri::findOrFail($id);

        $request->validate([
            'name' => 'required|string|max:255',
            'nis' => 'required|string|max:255|unique:santris,nis,' . $santri->id,
            'wali_id' => 'nullable|exists:users,id',
            'qr_token' => 'required|string|max:255|unique:santris,qr_token,' . $santri->id,
        ]);

        $santri->update($request->all());

        return response()->json([
            'message' => 'Santri berhasil diperbarui',
            'santri' => $santri
        ]);
    }

    /**
     * Remove student profile.
     */
    public function destroySantri($id)
    {
        $this->authorizeAdmin();

        $santri = Santri::findOrFail($id);
        $santri->delete();

        return response()->json([
            'message' => 'Santri berhasil dihapus'
        ]);
    }

    /**
     * Calculate active days in a month up to today (excluding Sundays).
     */
    private function calculateActiveDays($month, $year)
    {
        $currentMonth = (int)date('m');
        $currentYear = (int)date('Y');
        
        if ($year < $currentYear || ($year == $currentYear && $month < $currentMonth)) {
            $lastDay = (int)date('t', strtotime("$year-$month-01"));
        } elseif ($year == $currentYear && $month == $currentMonth) {
            $lastDay = (int)date('d');
        } else {
            return 0; // Future month
        }

        $activeDays = 0;
        for ($day = 1; $day <= $lastDay; $day++) {
            $timestamp = strtotime("$year-$month-$day");
            $dayOfWeek = date('N', $timestamp);
            if ($dayOfWeek != 7) { // 7 is Sunday
                $activeDays++;
            }
        }

        return $activeDays;
    }

    /**
     * Get monthly attendance report for all students.
     */
    public function getAttendanceReport(Request $request)
    {
        $this->authorizeAdmin();

        $month = $request->query('month', date('m'));
        $year = $request->query('year', date('Y'));

        $santris = Santri::all();
        $report = [];
        $activeDays = $this->calculateActiveDays($month, $year);

        foreach ($santris as $santri) {
            // Count Hadir
            $hadir = \App\Models\Absensi::where('santri_id', $santri->id)
                ->whereMonth('waktu_absen', $month)
                ->whereYear('waktu_absen', $year)
                ->where('status', 'Hadir')
                ->count();

            // Count Sakit (Approved Sick Leaves)
            $sakit = \App\Models\Perizinan::where('santri_id', $santri->id)
                ->where('status', 'Approved')
                ->where('jenis_izin', 'Sakit')
                ->where(function ($q) use ($month, $year) {
                    $q->whereMonth('tanggal_mulai', $month)->whereYear('tanggal_mulai', $year)
                      ->orWhereMonth('tanggal_selesai', $month)->whereYear('tanggal_selesai', $year);
                })
                ->count();

            // Count Izin (Approved Other Leaves)
            $izin = \App\Models\Perizinan::where('santri_id', $santri->id)
                ->where('status', 'Approved')
                ->whereIn('jenis_izin', ['Pulang', 'Lainnya'])
                ->where(function ($q) use ($month, $year) {
                    $q->whereMonth('tanggal_mulai', $month)->whereYear('tanggal_mulai', $year)
                      ->orWhereMonth('tanggal_selesai', $month)->whereYear('tanggal_selesai', $year);
                })
                ->count();

            // Alpha = max(0, activeDays - hadir - sakit - izin)
            $alpha = max(0, $activeDays - $hadir - $sakit - $izin);

            $report[] = [
                'nama' => $santri->name,
                'hadir' => $hadir,
                'sakit' => $sakit,
                'izin' => $izin,
                'alpha' => $alpha,
            ];
        }

        return response()->json($report);
    }

    /**
     * Get target pesantren GPS coordinates/settings.
     */
    public function getSettings()
    {
        $filePath = storage_path('app/settings.json');
        if (file_exists($filePath)) {
            $data = json_decode(file_get_contents($filePath), true);
        } else {
            // Default: Fasilkom UNEJ
            $data = [
                'name' => 'Fasilkom Universitas Jember',
                'latitude' => -8.164667,
                'longitude' => 113.717056,
                'radius' => 100.0,
            ];
            if (!is_dir(dirname($filePath))) {
                mkdir(dirname($filePath), 0755, true);
            }
            file_put_contents($filePath, json_encode($data, JSON_PRETTY_PRINT));
        }

        return response()->json($data);
    }

    /**
     * Update target pesantren GPS coordinates/settings.
     */
    public function updateSettings(Request $request)
    {
        $this->authorizeAdmin();

        $request->validate([
            'name' => 'required|string|max:255',
            'latitude' => 'required|numeric',
            'longitude' => 'required|numeric',
            'radius' => 'required|numeric|min:10',
        ]);

        $data = [
            'name' => $request->name,
            'latitude' => (float)$request->latitude,
            'longitude' => (float)$request->longitude,
            'radius' => (float)$request->radius,
        ];

        $filePath = storage_path('app/settings.json');
        if (!is_dir(dirname($filePath))) {
            mkdir(dirname($filePath), 0755, true);
        }
        file_put_contents($filePath, json_encode($data, JSON_PRETTY_PRINT));

        return response()->json([
            'message' => 'Pengaturan GPS berhasil diperbarui',
            'settings' => $data
        ]);
    }

    /**
     * Get monthly consumption report for all students.
     */
    public function getConsumptionReport(Request $request)
    {
        $this->authorizeAdmin();

        $month = $request->query('month', date('m'));
        $year = $request->query('year', date('Y'));

        $santris = Santri::all();
        $data = [];
        $totalSarapan = 0;
        $totalSiang = 0;
        $totalMalam = 0;

        foreach ($santris as $santri) {
            $sarapan = \App\Models\Konsumsi::where('santri_id', $santri->id)
                ->where('jenis_makan', 'Sarapan')
                ->whereMonth('tanggal', $month)
                ->whereYear('tanggal', $year)
                ->count();

            $siang = \App\Models\Konsumsi::where('santri_id', $santri->id)
                ->where('jenis_makan', 'Siang')
                ->whereMonth('tanggal', $month)
                ->whereYear('tanggal', $year)
                ->count();

            $malam = \App\Models\Konsumsi::where('santri_id', $santri->id)
                ->where('jenis_makan', 'Malam')
                ->whereMonth('tanggal', $month)
                ->whereYear('tanggal', $year)
                ->count();

            $data[] = [
                'nama' => $santri->name,
                'sarapan' => $sarapan,
                'siang' => $siang,
                'malam' => $malam,
            ];

            $totalSarapan += $sarapan;
            $totalSiang += $siang;
            $totalMalam += $malam;
        }

        return response()->json([
            'data' => $data,
            'summary' => [
                'total_sarapan' => $totalSarapan,
                'total_siang' => $totalSiang,
                'total_malam' => $totalMalam,
            ]
        ]);
    }

    /**
     * Get system activity logs.
     */
    public function getActivityLogs(Request $request)
    {
        $this->authorizeAdmin();

        $date = $request->query('date');

        if ($date) {
            $attendanceQuery = \App\Models\Absensi::with(['santri', 'pengurus'])->whereDate('waktu_absen', $date);
            $consumptionQuery = \App\Models\Konsumsi::with(['santri', 'pengurus'])->whereDate('tanggal', $date);
            $perizinanQuery = \App\Models\Perizinan::with(['santri', 'wali', 'approver'])->whereDate('created_at', $date);
            $userQuery = User::with('roles')->whereDate('created_at', $date);
        } else {
            $attendanceQuery = \App\Models\Absensi::with(['santri', 'pengurus'])->orderBy('waktu_absen', 'desc')->limit(30);
            $consumptionQuery = \App\Models\Konsumsi::with(['santri', 'pengurus'])->orderBy('waktu_ambil', 'desc')->limit(30);
            $perizinanQuery = \App\Models\Perizinan::with(['santri', 'wali', 'approver'])->orderBy('created_at', 'desc')->limit(30);
            $userQuery = User::with('roles')->orderBy('created_at', 'desc')->limit(15);
        }

        $logs = collect();

        $attendanceQuery->get()->each(function ($item) use ($logs) {
            $logs->push([
                'type' => 'attendance',
                'user' => $item->pengurus->name ?? 'Pengurus',
                'description' => "Mencatat absensi " . ($item->santri->name ?? 'Santri') . " (" . $item->status . ")",
                'created_at' => $item->waktu_absen,
            ]);
        });

        $consumptionQuery->get()->each(function ($item) use ($logs) {
            $logs->push([
                'type' => 'consumption',
                'user' => $item->pengurus->name ?? 'Pengurus',
                'description' => "Mencatat klaim konsumsi " . ($item->santri->name ?? 'Santri') . ": " . $item->jenis_makan,
                'created_at' => $item->waktu_ambil,
            ]);
        });

        $perizinanQuery->get()->each(function ($item) use ($logs) {
            $actorName = $item->approver ? $item->approver->name : ($item->wali->name ?? 'Wali Santri');
            $statusText = $item->status === 'Pending' 
                ? "Mengajukan izin " . $item->jenis_izin . " untuk " . ($item->santri->name ?? 'Santri')
                : "Memperbarui status izin " . $item->jenis_izin . " untuk " . ($item->santri->name ?? 'Santri') . " menjadi " . $item->status;
            $logs->push([
                'type' => 'permission',
                'user' => $actorName,
                'description' => $statusText,
                'created_at' => $item->updated_at ? $item->updated_at->toIso8601String() : $item->created_at->toIso8601String(),
            ]);
        });

        $userQuery->get()->each(function ($item) use ($logs) {
            $roleName = $item->getRoleNames()->first() ?? 'User';
            $logs->push([
                'type' => 'user_create',
                'user' => 'Admin',
                'description' => "Membuat pengguna baru: " . $item->name . " sebagai " . $roleName,
                'created_at' => $item->created_at->toIso8601String(),
            ]);
        });

        $sortedLogs = $logs->sortByDesc('created_at')->values();
        if (!$date) {
            $sortedLogs = $sortedLogs->take(50);
        }

        return response()->json($sortedLogs);
    }
}
