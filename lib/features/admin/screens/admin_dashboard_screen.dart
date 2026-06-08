import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:santriku_app/core/core.dart';

/// Halaman Dashboard utama untuk role Admin.
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Admin'),
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
                const SizedBox(height: 28),
                _buildSummaryGrid(),
                const SizedBox(height: 28),
                _buildSectionTitle('Manajemen Data'),
                const SizedBox(height: 16),
                _buildManagementList(),
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
            fontSize: 16,
          ),
        ),
        Text(
          'Administrator',
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
        _buildSummaryCard('Total Santri', '320', Icons.school_outlined),
        _buildSummaryCard('Pengurus', '12', Icons.people_alt_outlined),
        _buildSummaryCard('Wali Santri', '285', Icons.favorite_outline),
        _buildSummaryCard('Aktif Hari Ini', '98%', Icons.trending_up_rounded),
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

  Widget _buildManagementList() {
    return Column(
      children: [
        _buildMenuItem('Kelola Pengguna', 'Tambah & edit akun santri, wali, & pengurus', Icons.manage_accounts_outlined),
        const SizedBox(height: 12),
        _buildMenuItem('Laporan Absensi', 'Rekapitulasi kehadiran santri per bulan', Icons.analytics_outlined),
        const SizedBox(height: 12),
        _buildMenuItem('Log Aktivitas', 'Riwayat perubahan data & transaksi sistem', Icons.history_toggle_off_rounded),
      ],
    );
  }

  Widget _buildMenuItem(String title, String subtitle, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.inputBorder),
      ),
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
        onTap: () {},
      ),
    );
  }
}
