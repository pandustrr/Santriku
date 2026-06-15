import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:santriku_app/core/core.dart';
import 'package:santriku_app/features/auth/services/auth_service.dart';

class DetailSantriScreen extends StatelessWidget {
  final Map<String, dynamic> santri;
  const DetailSantriScreen({super.key, required this.santri});

  @override
  Widget build(BuildContext context) {
    final parentName = AuthService.currentUser?['name'] ?? '-';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),
      appBar: AppBar(
        title: Text('Profil Santri', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.accent,
              child: Icon(Icons.person, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              santri['name'] ?? '-',
              style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              'NIS: ${santri['nis'] ?? '-'}',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            Container(
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
                children: [
                  _buildInfoRow('Nama Santri', santri['name'] ?? '-'),
                  const Divider(height: 24),
                  _buildInfoRow('Nomor Induk Santri (NIS)', santri['nis'] ?? '-'),
                  const Divider(height: 24),
                  _buildInfoRow('Wali Santri', parentName),
                  const Divider(height: 24),
                  _buildInfoRow('Token QR', santri['qr_token'] ?? '-'),
                ],
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
          style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 13),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: GoogleFonts.poppins(color: const Color(0xFF1E2925), fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
