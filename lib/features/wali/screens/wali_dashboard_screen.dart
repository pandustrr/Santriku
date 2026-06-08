import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:santriku_app/core/core.dart';
import 'package:santriku_app/features/wali/screens/pengajuan_izin_screen.dart';

/// Halaman Dashboard utama untuk role Wali Santri.
class WaliDashboardScreen extends StatelessWidget {
  const WaliDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Wali'),
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.accent),
            onPressed: () => Navigator.of(context).pop(),
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildSantriProfileCard(),
                const SizedBox(height: 28),
                _buildSectionTitle('Status Hari Ini'),
                const SizedBox(height: 16),
                _buildStatusGrid(),
                const SizedBox(height: 28),
                _buildQuickActions(context),
                const SizedBox(height: 32),
                _buildSectionTitle('Aktivitas Santri'),
                const SizedBox(height: 16),
                _buildSantriActivities(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selamat Datang,',
          style: GoogleFonts.poppins(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        Text(
          'Bapak/Ibu Wali Santri',
          style: GoogleFonts.poppins(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildSantriProfileCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.inputBorder),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.accent,
            child: Icon(Icons.person_rounded, color: AppColors.primaryDarker, size: 36),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Muhammad Fatih',
                  style: GoogleFonts.poppins(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Kelas IX A • Kamar Al-Khawarizmi',
                  style: GoogleFonts.poppins(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusGrid() {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      childAspectRatio: 0.9,
      children: [
        _buildStatusItem('Absensi', 'Hadir', Icons.check_circle_rounded, AppColors.success),
        _buildStatusItem('Makan Pagi', 'Sukses', Icons.restaurant_rounded, AppColors.accent),
        _buildStatusItem('Perizinan', 'Tidak Izin', Icons.verified_user_rounded, AppColors.info),
      ],
    );
  }

  Widget _buildStatusItem(String title, String value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.inputBorder),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.poppins(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const PengajuanIzinScreen(),
          ),
        ),
        icon: const Icon(Icons.add_moderator_rounded, size: 22),
        label: const Text('Ajukan Izin Santri'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.primaryDarker,
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

  Widget _buildSantriActivities() {
    return Column(
      children: [
        _buildActivityRow('Sarapan Pagi', 'Scan konsumsi terverifikasi', '06:45 WIB', Icons.breakfast_dining_rounded),
        const SizedBox(height: 12),
        _buildActivityRow('Absensi Subuh', 'Hadir di masjid utama', '05:15 WIB', Icons.check_circle_outline),
        const SizedBox(height: 12),
        _buildActivityRow('Makan Malam Kemarin', 'Selesai makan malam', '18:22 WIB', Icons.dinner_dining_rounded),
      ],
    );
  }

  Widget _buildActivityRow(String title, String subtitle, String time, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryDark,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.accent, size: 20),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.poppins(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
        trailing: Text(
          time,
          style: GoogleFonts.poppins(
            color: AppColors.textHint,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}
