import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:santriku_app/core/core.dart';

/// Halaman hasil scan absensi / konsumsi santri.
class AbsensiResultScreen extends StatelessWidget {
  final bool isAbsensi;
  final String santriName;
  final String status;
  final String timestamp;
  final bool isSuccess;

  const AbsensiResultScreen({
    super.key,
    required this.isAbsensi,
    required this.santriName,
    required this.status,
    required this.timestamp,
    required this.isSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),

                // Ikon Status
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: (isSuccess ? AppColors.success : AppColors.error).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSuccess ? AppColors.success : AppColors.error,
                      width: 3,
                    ),
                  ),
                  child: Icon(
                    isSuccess ? Icons.check_rounded : Icons.close_rounded,
                    color: isSuccess ? AppColors.success : AppColors.error,
                    size: 56,
                  ),
                ),

                const SizedBox(height: 32),

                // Judul Result
                Text(
                  isSuccess ? 'Pemindaian Berhasil' : 'Pemindaian Gagal',
                  style: GoogleFonts.poppins(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isAbsensi ? 'Data Kehadiran Santri' : 'Validasi Konsumsi Santri',
                  style: GoogleFonts.poppins(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 48),

                // Card Info Detail
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.inputBorder),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _buildDetailRow('Nama Santri', santriName),
                      const Divider(color: AppColors.inputBorder, height: 24),
                      _buildDetailRow('Status', status, isStatus: true),
                      const Divider(color: AppColors.inputBorder, height: 24),
                      _buildDetailRow('Waktu', timestamp),
                    ],
                  ),
                ),

                const Spacer(),

                // Tombol Selesai
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSuccess ? AppColors.accent : AppColors.primaryLight,
                      foregroundColor: AppColors.primaryDarker,
                    ),
                    child: Text(
                      'Selesai',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isStatus = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: GoogleFonts.poppins(
              color: isStatus
                  ? (isSuccess ? AppColors.success : AppColors.error)
                  : AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
