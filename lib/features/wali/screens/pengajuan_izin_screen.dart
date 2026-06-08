import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:santriku_app/core/core.dart';
import 'package:santriku_app/features/auth/widgets/custom_text_field.dart';

/// Halaman form pengajuan izin santri oleh Wali.
class PengajuanIzinScreen extends StatefulWidget {
  const PengajuanIzinScreen({super.key});

  @override
  State<PengajuanIzinScreen> createState() => _PengajuanIzinScreenState();
}

class _PengajuanIzinScreenState extends State<PengajuanIzinScreen> {
  final _formKey = GlobalKey<FormState>();
  final _alasanController = TextEditingController();
  final _tglMulaiController = TextEditingController();
  final _tglSelesaiController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _alasanController.dispose();
    _tglMulaiController.dispose();
    _tglSelesaiController.dispose();
    super.dispose();
  }

  void _submitIzin() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Pengajuan izin berhasil dikirim!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengajuan Izin'),
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Form Pengajuan Izin',
                    style: GoogleFonts.poppins(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Mohon isi data perizinan santri dengan benar. Pengajuan akan diperiksa oleh pengurus.',
                    style: GoogleFonts.poppins(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Alasan Izin
                  CustomTextField(
                    label: 'ALASAN PERIZINAN',
                    hintText: 'Misal: Sakit, Acara Keluarga, dll.',
                    controller: _alasanController,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Alasan harus diisi';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Tanggal Mulai
                  CustomTextField(
                    label: 'TANGGAL MULAI',
                    hintText: 'DD-MM-YYYY',
                    controller: _tglMulaiController,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Tanggal mulai harus diisi';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Tanggal Selesai
                  CustomTextField(
                    label: 'TANGGAL SELESAI',
                    hintText: 'DD-MM-YYYY',
                    controller: _tglSelesaiController,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Tanggal selesai harus diisi';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Upload Surat Dokter / Berkas Pendukung Mock
                  _buildUploadSection(),
                  const SizedBox(height: 40),

                  // Button Submit
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitIzin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: AppColors.primaryDarker,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: AppColors.primaryDarker,
                              ),
                            )
                          : Text(
                              'Kirim Pengajuan',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUploadSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.inputBorder, style: BorderStyle.solid),
      ),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        children: [
          const Icon(Icons.cloud_upload_outlined, color: AppColors.accent, size: 36),
          const SizedBox(height: 12),
          Text(
            'Upload Bukti Pendukung (Opsional)',
            style: GoogleFonts.poppins(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Format PDF, JPG, atau PNG maks 2MB',
            style: GoogleFonts.poppins(
              color: AppColors.textHint,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
