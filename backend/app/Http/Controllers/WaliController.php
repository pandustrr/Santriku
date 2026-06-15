<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Santri;
use App\Models\Absensi;
use App\Models\Konsumsi;
use App\Models\Perizinan;
use Illuminate\Support\Facades\Storage;

class WaliController extends Controller
{
    /**
     * Get children (students) linked to this Wali.
     */
    public function getSantris()
    {
        if (!auth()->user()->hasRole('wali_santri')) {
            return response()->json(['message' => 'Forbidden. Wali Santri role required.'], 403);
        }

        $santris = Santri::where('wali_id', auth()->id())->get();
        return response()->json($santris);
    }

    /**
     * Get dashboard summary statistics and recent activities for a specific child.
     */
    public function getDashboardStats($santriId)
    {
        if (!auth()->user()->hasRole('wali_santri')) {
            return response()->json(['message' => 'Forbidden'], 403);
        }

        $santri = Santri::findOrFail($santriId);
        if ($santri->wali_id != auth()->id()) {
            return response()->json(['message' => 'Access Denied. This student is not linked to your account.'], 403);
        }

        $today = date('Y-m-d');

        // 1. Today's attendance
        $absensi = Absensi::where('santri_id', $santriId)
            ->whereDate('waktu_absen', $today)
            ->first();
        $absensiStatus = $absensi ? $absensi->status : 'Belum Absen';

        // 2. Today's consumption claims
        $sarapan = Konsumsi::where('santri_id', $santriId)
            ->where('tanggal', $today)
            ->where('jenis_makan', 'Sarapan')
            ->exists();
        $siang = Konsumsi::where('santri_id', $santriId)
            ->where('tanggal', $today)
            ->where('jenis_makan', 'Siang')
            ->exists();
        $malam = Konsumsi::where('santri_id', $santriId)
            ->where('tanggal', $today)
            ->where('jenis_makan', 'Malam')
            ->exists();

        // 3. Today's permission status
        $perizinan = Perizinan::where('santri_id', $santriId)
            ->whereDate('tanggal_mulai', '<=', $today)
            ->whereDate('tanggal_selesai', '>=', $today)
            ->where('status', 'Approved')
            ->first();
        $izinStatus = $perizinan ? $perizinan->jenis_izin : 'Tidak Izin';

        // 4. Combined recent activity logs for this child today
        $attendanceLogs = Absensi::where('santri_id', $santriId)
            ->whereDate('waktu_absen', $today)
            ->orderBy('waktu_absen', 'desc')
            ->get()
            ->map(function ($item) {
                return [
                    'id' => 'att_' . $item->id,
                    'type' => 'attendance',
                    'title' => 'Absensi Harian',
                    'detail' => 'Presensi ' . $item->status,
                    'time' => date('H:i', strtotime($item->waktu_absen)),
                    'timestamp' => $item->waktu_absen,
                ];
            });

        $consumptionLogs = Konsumsi::where('santri_id', $santriId)
            ->where('tanggal', $today)
            ->orderBy('waktu_ambil', 'desc')
            ->get()
            ->map(function ($item) {
                return [
                    'id' => 'con_' . $item->id,
                    'type' => 'consumption',
                    'title' => 'Konsumsi Makanan',
                    'detail' => 'Klaim Makan ' . $item->jenis_makan . ' Sukses',
                    'time' => date('H:i', strtotime($item->waktu_ambil)),
                    'timestamp' => $item->waktu_ambil,
                ];
            });

        $activities = $attendanceLogs->concat($consumptionLogs)
            ->sortByDesc('timestamp')
            ->values()
            ->all();

        return response()->json([
            'santri' => $santri,
            'absensi_status' => $absensiStatus,
            'consumption' => [
                'sarapan' => $sarapan ? 'Sukses' : 'Belum',
                'siang' => $siang ? 'Sukses' : 'Belum',
                'malam' => $malam ? 'Sukses' : 'Belum',
            ],
            'izin_status' => $izinStatus,
            'activities' => $activities,
        ]);
    }

    /**
     * Get leave permissions list for a specific child.
     */
    public function getPermissions($santriId)
    {
        if (!auth()->user()->hasRole('wali_santri')) {
            return response()->json(['message' => 'Forbidden'], 403);
        }

        $santri = Santri::findOrFail($santriId);
        if ($santri->wali_id != auth()->id()) {
            return response()->json(['message' => 'Access Denied.'], 403);
        }

        $permissions = Perizinan::where('santri_id', $santriId)
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json($permissions);
    }

    /**
     * Store new leave permission request.
     */
    public function storePermission(Request $request, $santriId)
    {
        if (!auth()->user()->hasRole('wali_santri')) {
            return response()->json(['message' => 'Forbidden'], 403);
        }

        $santri = Santri::findOrFail($santriId);
        if ($santri->wali_id != auth()->id()) {
            return response()->json(['message' => 'Access Denied.'], 403);
        }

        $request->validate([
            'jenis_izin' => 'required|string|in:Sakit,Pulang,Lainnya',
            'tanggal_mulai' => 'required|date',
            'tanggal_selesai' => 'required|date|after_or_equal:tanggal_mulai',
            'alasan' => 'required|string',
            'bukti' => 'nullable|image|max:2048', // Max 2MB image
        ]);

        $buktiPath = null;
        if ($request->hasFile('bukti')) {
            $buktiPath = $request->file('bukti')->store('permissions', 'public');
        }

        $perizinan = Perizinan::create([
            'santri_id' => $santriId,
            'wali_id' => auth()->id(),
            'jenis_izin' => $request->jenis_izin,
            'tanggal_mulai' => $request->tanggal_mulai,
            'tanggal_selesai' => $request->tanggal_selesai,
            'alasan' => $request->alasan,
            'bukti_path' => $buktiPath,
            'status' => 'Pending',
        ]);

        return response()->json([
            'message' => 'Pengajuan izin berhasil dikirim',
            'perizinan' => $perizinan
        ], 201);
    }
}
