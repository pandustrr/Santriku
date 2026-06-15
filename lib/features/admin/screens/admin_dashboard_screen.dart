import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:santriku_app/core/core.dart';
import 'package:santriku_app/features/admin/admin.dart';
import 'package:santriku_app/features/admin/screens/kelola_pengguna_screen.dart';
import 'package:santriku_app/features/admin/screens/laporan_absensi_screen.dart';
import 'package:santriku_app/features/admin/screens/log_aktivitas_screen.dart';
import 'package:santriku_app/features/auth/screens/login_screen.dart';
import 'package:santriku_app/features/auth/services/auth_service.dart';

/// Halaman Dashboard utama untuk role Admin.
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool _isLoading = true;
  int _totalSantri = 0;
  int _totalPengurus = 0;
  int _totalWali = 0;
  double _attendanceRate = 0.0;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final response = await AdminService.getDashboardStats();

    if (mounted) {
      if (response['success']) {
        final data = response['data'];
        setState(() {
          _totalSantri = data['total_santri'] ?? 0;
          _totalPengurus = data['total_pengurus'] ?? 0;
          _totalWali = data['total_wali'] ?? 0;
          _attendanceRate = (data['attendance_rate'] as num?)?.toDouble() ?? 0.0;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Gagal memuat data statistik';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final adminName = AuthService.currentUser?['name'] ?? 'Administrator';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Admin'),
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.accent),
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadStats,
            color: AppColors.accent,
            backgroundColor: AppColors.primaryDark,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(adminName),
                  const SizedBox(height: 28),
                  if (_errorMessage.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.error),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: AppColors.error),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _errorMessage,
                              style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.refresh, color: Colors.white),
                            onPressed: _loadStats,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  _buildSummaryGrid(),
                  const SizedBox(height: 28),
                  _buildSectionTitle('Manajemen Data'),
                  const SizedBox(height: 16),
                  _buildManagementList(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String name) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selamat Datang,',
          style: GoogleFonts.poppins(
            color: AppColors.textSecondary,
            fontSize: 16,
          ),
        ),
        Text(
          name,
          style: GoogleFonts.poppins(
            color: AppColors.textPrimary,
            fontSize: 26,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: [
        _buildSummaryCard('Total Santri', _isLoading ? '...' : '$_totalSantri', Icons.school_outlined),
        _buildSummaryCard('Pengurus', _isLoading ? '...' : '$_totalPengurus', Icons.people_alt_outlined),
        _buildSummaryCard('Wali Santri', _isLoading ? '...' : '$_totalWali', Icons.favorite_outline),
        _buildSummaryCard('Kehadiran Hari Ini', _isLoading ? '...' : '${_attendanceRate.toStringAsFixed(0)}%', Icons.trending_up_rounded),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(icon, color: AppColors.accent, size: 24),
                    const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textHint, size: 12),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: GoogleFonts.poppins(
                        color: AppColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        color: AppColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildManagementList(BuildContext context) {
    return Column(
      children: [
        _buildMenuItem(
          'Kelola Pengguna', 
          'Tambah & edit akun santri, wali, & pengurus', 
          Icons.manage_accounts_outlined,
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KelolaPenggunaScreen())).then((_) => _loadStats()),
        ),
        const SizedBox(height: 12),
        _buildMenuItem(
          'Laporan Absensi', 
          'Rekapitulasi kehadiran santri per bulan', 
          Icons.analytics_outlined,
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LaporanAbsensiScreen())),
        ),
        const SizedBox(height: 12),
        _buildMenuItem(
          'Log Aktivitas', 
          'Riwayat perubahan data & transaksi sistem', 
          Icons.history_toggle_off_rounded,
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LogAktivitasScreen())),
        ),
      ],
    );
  }

  Widget _buildMenuItem(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primaryDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.accent),
            ),
            title: Text(
              title,
              style: GoogleFonts.poppins(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              subtitle,
              style: GoogleFonts.poppins(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
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
              AuthService.logout();
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
