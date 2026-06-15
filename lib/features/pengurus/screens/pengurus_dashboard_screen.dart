import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:santriku_app/core/core.dart';
import 'package:santriku_app/features/pengurus/screens/scan_qr_screen.dart';
import 'package:santriku_app/features/pengurus/screens/daftar_izin_screen.dart';
import 'package:santriku_app/features/pengurus/screens/detail_izin_screen.dart';
import 'package:santriku_app/features/pengurus/screens/daftar_santri_screen.dart';
import 'package:santriku_app/features/pengurus/screens/stok_konsumsi_screen.dart';
import 'package:santriku_app/features/pengurus/screens/notifikasi_screen.dart';
import 'package:santriku_app/features/auth/screens/login_screen.dart';

/// Halaman Dashboard utama untuk role Pengurus.
///
/// Didesain presisi menyerupai desain mockup figma/gambar.
class PengurusDashboardScreen extends StatelessWidget {
  const PengurusDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6), // Background off-white
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildDarkHeader(context),
            _buildWhiteBody(context),
          ],
        ),
      ),
    );
  }

  // ── Header Dark Teal Section ───────────────────────────
  Widget _buildDarkHeader(BuildContext context) {
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
                    'Hakim Abdullah',
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
            'Santri terverifikasi hari ini',
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
                '412',
                style: GoogleFonts.poppins(
                  color: AppColors.textPrimary,
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '/ 450 santri',
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
            child: const LinearProgressIndicator(
              value: 412 / 450,
              minHeight: 5,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
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
              Text(
                '12 baru',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF2A8B72),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Card Item: Bilal Hasan
          _buildIzinItemCard(context),
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
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const ScanQrScreen(isAbsensi: true),
            ),
          ),
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
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const ScanQrScreen(isAbsensi: false),
            ),
          ),
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
                          '823 / 1.350',
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
                  child: const LinearProgressIndicator(
                    value: 823 / 1350,
                    minHeight: 7,
                    backgroundColor: Color(0xFFE8F2EF),
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2A8B72)),
                  ),
                ),
                const SizedBox(height: 14),
                // Meal Stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildMealStatText('Sarapan', '450'),
                    _buildMealStatText('Siang', '373'),
                    _buildMealStatText('Malam', '—'),
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
      '$label $value',
      style: GoogleFonts.poppins(
        color: Colors.grey[500],
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  // Row of 3 Menu buttons
  Widget _buildMenuGrid(BuildContext context) {
    return Row(
      children: [
        _buildMenuButton(
          icon: Icons.assignment_outlined,
          label: 'Izin',
          iconColor: const Color(0xFFE8A838),
          bgColor: const Color(0xFFFFF7EA),
          badge: '12',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DaftarIzinScreen())),
        ),
        const SizedBox(width: 14),
        _buildMenuButton(
          icon: Icons.people_outline_rounded,
          label: 'Santri',
          iconColor: const Color(0xFF2B88D9),
          bgColor: const Color(0xFFEEF6FC),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DaftarSantriScreen())),
        ),
        const SizedBox(width: 14),
        _buildMenuButton(
          icon: Icons.restaurant_menu_rounded,
          label: 'Stok',
          iconColor: const Color(0xFF2A8B72),
          bgColor: const Color(0xFFE8F2EF),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StokKonsumsiScreen())),
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
                  'Bilal Hasan - Pulang',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF1E2925),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '5 menit lalu',
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
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DetailIzinScreen()),
              );
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
