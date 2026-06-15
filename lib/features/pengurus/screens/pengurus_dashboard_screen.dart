import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:santriku_app/core/core.dart';
import 'package:santriku_app/features/pengurus/screens/scan_qr_screen.dart';
import 'package:santriku_app/features/pengurus/screens/daftar_izin_screen.dart';
import 'package:santriku_app/features/pengurus/screens/daftar_santri_screen.dart';
import 'package:santriku_app/features/pengurus/screens/stok_konsumsi_screen.dart';
import 'package:santriku_app/features/pengurus/screens/notifikasi_screen.dart';
import 'package:santriku_app/features/auth/screens/login_screen.dart';
import 'package:santriku_app/features/auth/services/auth_service.dart';
import 'package:santriku_app/features/pengurus/services/pengurus_service.dart';

/// Halaman Dashboard utama untuk role Pengurus.
///
/// Didesain presisi menyerupai desain mockup figma/gambar.
class PengurusDashboardScreen extends StatefulWidget {
  const PengurusDashboardScreen({super.key});

  @override
  State<PengurusDashboardScreen> createState() => _PengurusDashboardScreenState();
}

class _PengurusDashboardScreenState extends State<PengurusDashboardScreen> {
  Map<String, dynamic>? _stats;
  List<Map<String, dynamic>> _activityLogs = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final statsResult = await PengurusService.getDashboardStats();
      final logsResult = await PengurusService.getActivityLogs();

      if (mounted) {
        if (statsResult['success']) {
          setState(() {
            _stats = statsResult['data'];
            _activityLogs = logsResult;
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = statsResult['message'];
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Gagal memuat data dashboard: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6), // Background off-white
      body: _isLoading && _stats == null
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF104A3E),
              ),
            )
          : _errorMessage != null && _stats == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, color: Colors.red[300], size: 48),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(color: Colors.grey[700]),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadData,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF104A3E),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  color: const Color(0xFF104A3E),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        _buildDarkHeader(context),
                        _buildWhiteBody(context),
                      ],
                    ),
                  ),
                ),
    );
  }

  // ── Header Dark Teal Section ───────────────────────────
  Widget _buildDarkHeader(BuildContext context) {
    final int verified = _stats?['verified_attendance_count'] ?? 0;
    final int total = _stats?['total_santri'] ?? 0;
    final double progress = total > 0 ? (verified / total) : 0.0;
    final String operatorName = AuthService.currentUser?['name'] ?? 'Hakim Abdullah';

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF104A3E), // Deep Teal color
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.only(top: 56, left: 24, right: 24, bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile & Bell Notification Row
          Row(
            children: [
              // Avatar with custom gold border
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.accent, width: 2),
                ),
                padding: const EdgeInsets.all(3),
                child: const CircleAvatar(
                  radius: 20,
                  backgroundColor: Color(0xFF0D3D33),
                  child: Icon(Icons.people_outline_rounded, color: AppColors.accent, size: 22),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pengurus • Operator',
                    style: GoogleFonts.poppins(
                      color: AppColors.textSecondary.withValues(alpha: 0.8),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    operatorName,
                    style: GoogleFonts.poppins(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Logout button
              GestureDetector(
                onTap: () => _showLogoutDialog(context),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: AppColors.accent,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Bell Notification Icon with Gold Badge
              _buildBellNotification(context),
            ],
          ),

          const SizedBox(height: 32),

          // Verified Santri Stats Section
          Text(
            'Santri terverifikasi hadir hari ini',
            style: GoogleFonts.poppins(
              color: AppColors.textSecondary.withValues(alpha: 0.8),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$verified',
                style: GoogleFonts.poppins(
                  color: AppColors.textPrimary,
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '/ $total santri',
                style: GoogleFonts.poppins(
                  color: AppColors.textSecondary.withValues(alpha: 0.7),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Gold Progress Indicator
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              backgroundColor: Colors.white10,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
            ),
          ),
        ],
      ),
    );
  }

  // Helper Bell Notification
  Widget _buildBellNotification(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotifikasiScreen())),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              color: AppColors.textPrimary,
              size: 22,
            ),
          ),
        ),
        Positioned(
          top: 2,
          right: 2,
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.accent,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  // ── White/Off-White Body Section ───────────────────────
  Widget _buildWhiteBody(BuildContext context) {
    final int pendingIzinCount = _stats?['pending_permissions_count'] ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card 1: Scan QR Santri Card
          _buildScanCard(context),

          const SizedBox(height: 18),

          // Card 2: Konsumsi Hari Ini
          _buildKonsumsiCard(context),

          const SizedBox(height: 18),

          // Row: Menu Izin, Santri, Stok
          _buildMenuGrid(context),

          const SizedBox(height: 28),

          // Header: Izin Menunggu
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Izin Menunggu',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF1E2925),
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (pendingIzinCount > 0)
                Text(
                  '$pendingIzinCount baru',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF2A8B72),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Card Item: Bilal Hasan or empty state
          pendingIzinCount > 0
              ? _buildIzinItemCard(context)
              : _buildNoPendingIzinCard(),

          const SizedBox(height: 28),

          // Section: Log Aktivitas Terbaru
          Text(
            'Log Aktivitas Terbaru',
            style: GoogleFonts.poppins(
              color: const Color(0xFF1E2925),
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 12),

          _activityLogs.isEmpty
              ? _buildNoActivityCard()
              : Column(
                  children: _activityLogs.map((log) => _buildActivityLogItem(log)).toList(),
                ),
        ],
      ),
    );
  }

  // Scan QR Card Builder
  Widget _buildScanCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const ScanQrScreen(isAbsensi: true),
              ),
            );
            _loadData();
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Gold Icon Box
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.qr_code_scanner_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Scan QR Santri',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF1E2925),
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Absensi • Konsumsi harian',
                        style: GoogleFonts.poppins(
                          color: Colors.grey[600],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.grey,
                  size: 14,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Konsumsi Card Builder
  Widget _buildKonsumsiCard(BuildContext context) {
    final int taken = _stats?['consumption']?['taken'] ?? 0;
    final int total = _stats?['consumption']?['total'] ?? 0;
    final double progress = total > 0 ? (taken / total) : 0.0;
    final int sarapan = _stats?['consumption']?['sarapan'] ?? 0;
    final int siang = _stats?['consumption']?['siang'] ?? 0;
    final int malam = _stats?['consumption']?['malam'] ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const ScanQrScreen(isAbsensi: false),
              ),
            );
            _loadData();
          },
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.restaurant_rounded,
                          color: Color(0xFF2A8B72),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Konsumsi Hari Ini',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF1E2925),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          '$taken / $total',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF2A8B72),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.grey,
                          size: 12,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Green Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 7,
                    backgroundColor: const Color(0xFFE8F2EF),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2A8B72)),
                  ),
                ),
                const SizedBox(height: 14),
                // Meal Stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildMealStatText('Sarapan', '$sarapan'),
                    _buildMealStatText('Siang', '$siang'),
                    _buildMealStatText('Malam', '$malam'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMealStatText(String label, String value) {
    return Text(
      '$label: $value',
      style: GoogleFonts.poppins(
        color: Colors.grey[500],
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  // Row of 3 Menu buttons
  Widget _buildMenuGrid(BuildContext context) {
    final int pendingCount = _stats?['pending_permissions_count'] ?? 0;
    return Row(
      children: [
        _buildMenuButton(
          icon: Icons.assignment_outlined,
          label: 'Izin',
          iconColor: const Color(0xFFE8A838),
          bgColor: const Color(0xFFFFF7EA),
          badge: pendingCount > 0 ? '$pendingCount' : null,
          onTap: () async {
            await Navigator.push(context, MaterialPageRoute(builder: (_) => const DaftarIzinScreen()));
            _loadData();
          },
        ),
        const SizedBox(width: 14),
        _buildMenuButton(
          icon: Icons.people_outline_rounded,
          label: 'Santri',
          iconColor: const Color(0xFF2B88D9),
          bgColor: const Color(0xFFEEF6FC),
          onTap: () async {
            await Navigator.push(context, MaterialPageRoute(builder: (_) => const DaftarSantriScreen()));
            _loadData();
          },
        ),
        const SizedBox(width: 14),
        _buildMenuButton(
          icon: Icons.restaurant_menu_rounded,
          label: 'Stok',
          iconColor: const Color(0xFF2A8B72),
          bgColor: const Color(0xFFE8F2EF),
          onTap: () async {
            await Navigator.push(context, MaterialPageRoute(builder: (_) => const StokKonsumsiScreen()));
            _loadData();
          },
        ),
      ],
    );
  }

  Widget _buildMenuButton({
    required IconData icon,
    required String label,
    required Color iconColor,
    required Color bgColor,
    String? badge,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: bgColor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(icon, color: iconColor, size: 22),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          label,
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF1E2925),
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (badge != null)
            Positioned(
              top: -6,
              right: 12,
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Pending Izin Item Card Builder
  Widget _buildIzinItemCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          // Avatar B
          const CircleAvatar(
            radius: 20,
            backgroundColor: Color(0xFF1C6B59),
            child: Text(
              'B',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Info Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pengajuan Izin Santri',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF1E2925),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Menunggu verifikasi pengurus',
                  style: GoogleFonts.poppins(
                    color: Colors.grey[500],
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Green Pill Tinjau Button
          ElevatedButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DaftarIzinScreen()),
              );
              _loadData();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF104A3E),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              minimumSize: const Size(60, 32),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              'Tinjau',
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoPendingIzinCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withValues(alpha: 0.03)),
      ),
      child: Center(
        child: Text(
          'Tidak ada pengajuan izin menunggu',
          style: GoogleFonts.poppins(color: Colors.grey[500], fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildNoActivityCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withValues(alpha: 0.03)),
      ),
      child: Center(
        child: Text(
          'Belum ada aktivitas tercatat hari ini',
          style: GoogleFonts.poppins(color: Colors.grey[500], fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildActivityLogItem(Map<String, dynamic> log) {
    final isAttendance = log['type'] == 'attendance';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.black.withValues(alpha: 0.03)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isAttendance ? const Color(0xFFE8F2EF) : const Color(0xFFEEF6FC),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isAttendance ? Icons.check_circle_outline_rounded : Icons.restaurant_rounded,
            color: isAttendance ? const Color(0xFF2A8B72) : const Color(0xFF2B88D9),
            size: 22,
          ),
        ),
        title: Text(
          log['student_name'] ?? '-',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: const Color(0xFF1E2925),
          ),
        ),
        subtitle: Text(
          '${log['title']}: ${log['detail']}',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        trailing: Text(
          '${log['time']} WIB',
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.grey[400],
          ),
        ),
      ),
    );
  }

  // ── Logout Dialog ──────────────────────────────────────
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Logout', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        content: Text(
          'Apakah Anda yakin ingin keluar dari akun ini?',
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal', style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              AuthService.logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Logout', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
