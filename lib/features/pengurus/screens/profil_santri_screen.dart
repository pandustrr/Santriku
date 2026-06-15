import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Halaman detail profil santri — diakses dari Daftar Santri oleh Pengurus.
class ProfilSantriScreen extends StatelessWidget {
  final String nama;
  final String nis;
  final String kelas;

  const ProfilSantriScreen({
    super.key,
    required this.nama,
    required this.nis,
    required this.kelas,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF104A3E),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Profil Santri',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Avatar & Name
            const CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFF1C6B59),
              child: Icon(Icons.person_rounded, size: 56, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              nama,
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E2925),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'NIS: $nis',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),

            // Info Card
            _buildInfoCard(),

            const SizedBox(height: 20),

            // Statistik Kehadiran
            _buildStatistikCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informasi Santri',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E2925),
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Kelas', kelas),
          const Divider(height: 24),
          _buildInfoRow('Kamar', 'Al-Khawarizmi'),
          const Divider(height: 24),
          _buildInfoRow('Wali Kelas', 'Ust. Ahmad Dahlan'),
          const Divider(height: 24),
          _buildInfoRow('Tahun Masuk', '2023'),
          const Divider(height: 24),
          _buildInfoRow('Status', 'Aktif'),
        ],
      ),
    );
  }

  Widget _buildStatistikCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Statistik Bulan Ini',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E2925),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatItem('Hadir', '28', const Color(0xFF2A8B72)),
              const SizedBox(width: 12),
              _buildStatItem('Sakit', '1', const Color(0xFFE8A838)),
              const SizedBox(width: 12),
              _buildStatItem('Izin', '1', const Color(0xFF2B88D9)),
              const SizedBox(width: 12),
              _buildStatItem('Alpha', '0', Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 14),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            color: const Color(0xFF1E2925),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
