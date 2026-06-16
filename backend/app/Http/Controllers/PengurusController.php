<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Santri;
use App\Models\Absensi;

class PengurusController extends Controller
{


    /**
     * Helper to calculate distance between two coordinates in meters (Haversine formula).
     */
    private function calculateDistance($lat1, $lon1, $lat2, $lon2)
    {
        $earthRadius = 6371000; // in meters
        
        $dLat = deg2rad($lat2 - $lat1);
        $dLon = deg2rad($lon2 - $lon1);
        
        $a = sin($dLat / 2) * sin($dLat / 2) +
             cos(deg2rad($lat1)) * cos(deg2rad($lat2)) *
             sin($dLon / 2) * sin($dLon / 2);
             
        $c = 2 * atan2(sqrt($a), sqrt(1 - $a));
        
        return $earthRadius * $c; // distance in meters
    }

    /**
     * Record student attendance via QR code scan with GPS validation.
     */
    public function storeAttendance(Request $request)
    {
        // 1. Authorize that the user is indeed a pengurus
        if (!auth()->user()->hasRole('pengurus')) {
            return response()->json([
                'message' => 'Forbidden. Pengurus role required.'
            ], 403);
        }

        // 2. Validate input parameters
        $request->validate([
            'qr_token' => 'required|string',
            'latitude' => 'required|numeric',
            'longitude' => 'required|numeric',
            'status' => 'nullable|string|in:Hadir,Sakit,Izin,Alpa',
        ]);

        // 3. Find Santri by token
        $santri = Santri::where('qr_token', $request->qr_token)->first();
        if (!$santri) {
            return response()->json([
                'message' => 'Santri tidak ditemukan untuk QR Code ini.'
            ], 404);
        }

        // Check for double attendance today
        $today = date('Y-m-d');
        $existingAttendance = Absensi::where('santri_id', $santri->id)
            ->whereDate('waktu_absen', $today)
            ->first();

        if ($existingAttendance) {
            $formattedTime = date('H:i', strtotime($existingAttendance->waktu_absen));
            return response()->json([
                'santri_name' => $santri->name,
                'message' => 'Gagal: Santri ' . $santri->name . ' sudah melakukan absensi hari ini pada ' . $formattedTime . ' WIB.'
            ], 400);
        }

        // 4. Geofencing check (Dynamic settings)
        $filePath = storage_path('app/settings.json');
        if (file_exists($filePath)) {
            $settings = json_decode(file_get_contents($filePath), true);
        } else {
            // Default: Fasilkom UNEJ
            $settings = [
                'latitude' => -8.164667,
                'longitude' => 113.717056,
                'radius' => 100.0,
            ];
        }

        $pesantrenLat = $settings['latitude'] ?? -8.164667;
        $pesantrenLon = $settings['longitude'] ?? 113.717056;
        $maxRadius = $settings['radius'] ?? 100.0;

        $distance = $this->calculateDistance(
            $pesantrenLat,
            $pesantrenLon,
            $request->latitude,
            $request->longitude
        );

        $isInRange = $distance <= $maxRadius;

        if (!$isInRange) {
            return response()->json([
                'message' => 'Gagal: Lokasi tidak sesuai. Pengurus berada di luar area pondok pesantren (' . round($distance) . 'm dari pusat).'
            ], 422);
        }

        // 5. Save absensi record
        $absensi = Absensi::create([
            'santri_id' => $santri->id,
            'pengurus_id' => auth()->id(),
            'status' => $request->input('status', 'Hadir'),
            'latitude' => $request->latitude,
            'longitude' => $request->longitude,
            'is_in_range' => true,
        ]);

        return response()->json([
            'message' => 'Absensi berhasil dicatat',
            'absensi' => [
                'id' => $absensi->id,
                'santri_name' => $santri->name,
                'nis' => $santri->nis,
                'status' => $absensi->status,
                'waktu_absen' => $absensi->waktu_absen,
                'is_in_range' => $absensi->is_in_range,
                'distance_meters' => round($distance, 2)
            ]
        ], 201);
    }

    /**
     * Record student food consumption claim (Sarapan, Siang, Malam).
     * Automatically prevents double claims on the same day.
     */
    public function storeConsumption(Request $request)
    {
        // 1. Authorize that the user is indeed a pengurus
        if (!auth()->user()->hasRole('pengurus')) {
            return response()->json([
                'message' => 'Forbidden. Pengurus role required.'
            ], 403);
        }

        // 2. Validate input
        $request->validate([
            'qr_token' => 'required|string',
            'jenis_makan' => 'required|string|in:Sarapan,Siang,Malam',
        ]);

        // 3. Find Santri by token
        $santri = Santri::where('qr_token', $request->qr_token)->first();
        if (!$santri) {
            return response()->json([
                'message' => 'Santri tidak ditemukan untuk QR Code ini.'
            ], 404);
        }

        $today = date('Y-m-d');
        $jenisMakan = $request->jenis_makan;

        // 4. Check for double claim today
        $existingClaim = \App\Models\Konsumsi::where('santri_id', $santri->id)
            ->where('jenis_makan', $jenisMakan)
            ->where('tanggal', $today)
            ->first();

        if ($existingClaim) {
            $formattedTime = date('H:i', strtotime($existingClaim->waktu_ambil));
            return response()->json([
                'santri_name' => $santri->name,
                'message' => 'Gagal: Jatah makan ' . strtolower($jenisMakan) . ' sudah diambil oleh ' . $santri->name . ' pada ' . $formattedTime . ' WIB.'
            ], 400);
        }

        // 5. Save consumption record
        $konsumsi = \App\Models\Konsumsi::create([
            'santri_id' => $santri->id,
            'pengurus_id' => auth()->id(),
            'jenis_makan' => $jenisMakan,
            'tanggal' => $today,
            'waktu_ambil' => now(),
        ]);

        return response()->json([
            'message' => 'Jatah makan ' . strtolower($jenisMakan) . ' berhasil diambil.',
            'consumption' => [
                'id' => $konsumsi->id,
                'santri_name' => $santri->name,
                'nis' => $santri->nis,
                'jenis_makan' => $konsumsi->jenis_makan,
                'waktu_ambil' => $konsumsi->waktu_ambil,
            ]
        ], 201);
    }

    /**
     * Get list of all permission requests.
     */
    public function getPermissions()
    {
        if (!auth()->user()->hasRole('pengurus')) {
            return response()->json(['message' => 'Forbidden'], 403);
        }

        $permissions = \App\Models\Perizinan::with(['santri', 'wali'])->orderBy('created_at', 'desc')->get();
        return response()->json($permissions);
    }

    /**
     * Approve or reject a permission request.
     */
    public function updatePermissionStatus(Request $request, $id)
    {
        if (!auth()->user()->hasRole('pengurus')) {
            return response()->json(['message' => 'Forbidden'], 403);
        }

        $request->validate([
            'status' => 'required|string|in:Approved,Rejected',
        ]);

        $perizinan = \App\Models\Perizinan::findOrFail($id);
        $perizinan->update([
            'status' => $request->status,
            'approved_by' => auth()->id(),
        ]);

        return response()->json([
            'message' => 'Status perizinan berhasil diperbarui',
            'perizinan' => $perizinan
        ]);
    }

    /**
     * Get consumption statistics for today.
     */
    public function getConsumptionStats()
    {
        if (!auth()->user()->hasRole('pengurus')) {
            return response()->json(['message' => 'Forbidden'], 403);
        }

        $today = date('Y-m-d');
        $totalSantri = Santri::count();

        // Fetch custom quotas for today
        $quotas = \App\Models\StokMakanan::where('tanggal', $today)
            ->get()
            ->keyBy('jenis_makan');

        $sarapanTotal = isset($quotas['Sarapan']) ? $quotas['Sarapan']->porsi_total : $totalSantri;
        $siangTotal = isset($quotas['Siang']) ? $quotas['Siang']->porsi_total : $totalSantri;
        $malamTotal = isset($quotas['Malam']) ? $quotas['Malam']->porsi_total : $totalSantri;

        $sarapanCount = \App\Models\Konsumsi::where('tanggal', $today)->where('jenis_makan', 'Sarapan')->count();
        $siangCount = \App\Models\Konsumsi::where('tanggal', $today)->where('jenis_makan', 'Siang')->count();
        $malamCount = \App\Models\Konsumsi::where('tanggal', $today)->where('jenis_makan', 'Malam')->count();

        $currentHour = (int)date('H');
        
        return response()->json([
            'date_raw' => $today,
            'total_santri' => $totalSantri,
            'stats' => [
                [
                    'title' => 'Sarapan',
                    'time' => '06:00 - 08:00',
                    'total' => $sarapanTotal,
                    'taken' => $sarapanCount,
                    'is_done' => $currentHour >= 8,
                ],
                [
                    'title' => 'Makan Siang',
                    'time' => '12:00 - 14:00',
                    'total' => $siangTotal,
                    'taken' => $siangCount,
                    'is_done' => $currentHour >= 14,
                ],
                [
                    'title' => 'Makan Malam',
                    'time' => '18:00 - 20:00',
                    'total' => $malamTotal,
                    'taken' => $malamCount,
                    'is_done' => $currentHour >= 20,
                ],
            ]
        ]);
    }

    /**
     * Store or update food portion quota.
     */
    public function storeConsumptionStats(Request $request)
    {
        if (!auth()->user()->hasRole('pengurus')) {
            return response()->json(['message' => 'Forbidden'], 403);
        }

        $request->validate([
            'jenis_makan' => 'required|string|in:Sarapan,Siang,Malam',
            'porsi_total' => 'required|integer|min:1',
            'tanggal' => 'nullable|date',
        ]);

        $tanggal = $request->input('tanggal', date('Y-m-d'));
        $jenisMakan = $request->jenis_makan;
        $porsiTotal = $request->porsi_total;

        $stok = \App\Models\StokMakanan::updateOrCreate(
            ['tanggal' => $tanggal, 'jenis_makan' => $jenisMakan],
            ['porsi_total' => $porsiTotal]
        );

        return response()->json([
            'message' => 'Kuota porsi makan berhasil diperbarui',
            'stok' => $stok
        ]);
    }

    /**
     * Get dashboard summary statistics.
     */
    public function getDashboardStats()
    {
        if (!auth()->user()->hasRole('pengurus')) {
            return response()->json(['message' => 'Forbidden'], 403);
        }

        $today = date('Y-m-d');
        $totalSantri = Santri::count();

        // 1. Attendance statistics (verified today)
        $verifiedCount = Absensi::whereDate('waktu_absen', $today)
            ->distinct('santri_id')
            ->count('santri_id');

        // 2. Consumption statistics
        $sarapanCount = \App\Models\Konsumsi::where('tanggal', $today)->where('jenis_makan', 'Sarapan')->count();
        $siangCount = \App\Models\Konsumsi::where('tanggal', $today)->where('jenis_makan', 'Siang')->count();
        $malamCount = \App\Models\Konsumsi::where('tanggal', $today)->where('jenis_makan', 'Malam')->count();
        
        $totalClaims = $sarapanCount + $siangCount + $malamCount;
        $totalExpected = $totalSantri * 3;

        // 3. Pending permissions count
        $pendingPermissionsCount = \App\Models\Perizinan::where('status', 'Pending')->count();

        return response()->json([
            'total_santri' => $totalSantri,
            'verified_attendance_count' => $verifiedCount,
            'consumption' => [
                'taken' => $totalClaims,
                'total' => $totalExpected,
                'sarapan' => $sarapanCount,
                'siang' => $siangCount,
                'malam' => $malamCount,
            ],
            'pending_permissions_count' => $pendingPermissionsCount,
        ]);
    }

    /**
     * Get recent activity logs for today (attendance & consumption).
     */
    public function getActivityLogs()
    {
        if (!auth()->user()->hasRole('pengurus')) {
            return response()->json(['message' => 'Forbidden'], 403);
        }

        $today = date('Y-m-d');

        // Fetch today's attendance
        $attendance = Absensi::with('santri')
            ->whereDate('waktu_absen', $today)
            ->orderBy('waktu_absen', 'desc')
            ->limit(10)
            ->get()
            ->map(function ($item) {
                return [
                    'id' => 'att_' . $item->id,
                    'type' => 'attendance',
                    'title' => 'Presensi Santri',
                    'student_name' => $item->santri->name ?? 'Santri',
                    'detail' => $item->status,
                    'time' => date('H:i', strtotime($item->waktu_absen)),
                    'timestamp' => $item->waktu_absen,
                ];
            });

        // Fetch today's consumption
        $consumption = \App\Models\Konsumsi::with('santri')
            ->where('tanggal', $today)
            ->orderBy('waktu_ambil', 'desc')
            ->limit(10)
            ->get()
            ->map(function ($item) {
                return [
                    'id' => 'con_' . $item->id,
                    'type' => 'consumption',
                    'title' => 'Klaim Konsumsi',
                    'student_name' => $item->santri->name ?? 'Santri',
                    'detail' => 'Makan ' . $item->jenis_makan,
                    'time' => date('H:i', strtotime($item->waktu_ambil)),
                    'timestamp' => $item->waktu_ambil,
                ];
            });

        // Combine and sort by timestamp desc
        $logs = $attendance->concat($consumption)
            ->sortByDesc('timestamp')
            ->values()
            ->take(10);

        return response()->json($logs);
    }
}
