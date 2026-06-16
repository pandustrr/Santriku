import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:santriku_app/core/core.dart';
import 'package:santriku_app/features/auth/widgets/custom_text_field.dart';
import 'package:santriku_app/features/wali/services/wali_service.dart';

/// Halaman form pengajuan izin santri oleh Wali.
class PengajuanIzinScreen extends StatefulWidget {
  final List<Map<String, dynamic>>? santriList;
  final int? initialSantriId;

  const PengajuanIzinScreen({
    super.key,
    this.santriList,
    this.initialSantriId,
  });

  @override
  State<PengajuanIzinScreen> createState() => _PengajuanIzinScreenState();
}

class _PengajuanIzinScreenState extends State<PengajuanIzinScreen> {
  final _formKey = GlobalKey<FormState>();
  final _alasanController = TextEditingController();
  final _tglMulaiController = TextEditingController();
  final _tglSelesaiController = TextEditingController();
  bool _isLoading = false;

  int? _selectedSantriId;
  String? _selectedJenisIzin = 'Sakit';
  List<Map<String, dynamic>> _santriList = [];

  XFile? _buktiFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.santriList != null) {
      _santriList = widget.santriList!;
    }
    _selectedSantriId = widget.initialSantriId;

    if (_santriList.isEmpty) {
      _loadSantris();
    }
  }

  Future<void> _loadSantris() async {
    setState(() => _isLoading = true);
    final list = await WaliService.getSantris();
    if (mounted) {
      setState(() {
        _santriList = list;
        _isLoading = false;
        if (_selectedSantriId == null && list.isNotEmpty) {
          _selectedSantriId = list.first['id'];
        }
      });
    }
  }

  @override
  void dispose() {
    _alasanController.dispose();
    _tglMulaiController.dispose();
    _tglSelesaiController.dispose();
    super.dispose();
  }

  String _formatDateToYmd(String dateStr) {
    // Convert DD-MM-YYYY to YYYY-MM-DD
    final parts = dateStr.split('-');
    if (parts.length == 3) {
      return "${parts[2]}-${parts[1]}-${parts[0]}";
    }
    return dateStr;
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image != null) {
        setState(() {
          _buktiFile = image;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memilih gambar: $e')),
      );
    }
  }

  void _clearImage() {
    setState(() {
      _buktiFile = null;
    });
  }

  void _submitIzin() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSantriId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih santri terlebih dahulu!'), backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() => _isLoading = true);

    final String tglMulaiYmd = _formatDateToYmd(_tglMulaiController.text);
    final String tglSelesaiYmd = _formatDateToYmd(_tglSelesaiController.text);

    final response = await WaliService.submitPermission(
      santriId: _selectedSantriId!,
      jenisIzin: _selectedJenisIzin ?? 'Sakit',
      tanggalMulai: tglMulaiYmd,
      tanggalSelesai: tglSelesaiYmd,
      alasan: _alasanController.text,
      buktiFile: _buktiFile,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (response['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message'] ?? 'Pengajuan izin berhasil dikirim!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message'] ?? 'Gagal mengirim pengajuan izin!'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryDark,
              onPrimary: Colors.white,
              onSurface: AppColors.primaryDarker,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: AppColors.primaryDark),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        controller.text = "${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}";
      });
    }
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

                  // Pilih Santri
                  DropdownButtonFormField<int>(
                    value: _selectedSantriId,
                    decoration: InputDecoration(
                      labelText: 'PILIH SANTRI',
                      labelStyle: GoogleFonts.poppins(
                        color: AppColors.textSecondary.withValues(alpha: 0.8),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                      ),
                      filled: true,
                      fillColor: AppColors.inputBackground,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.inputBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.inputBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.accent, width: 2),
                      ),
                    ),
                    items: _santriList.map((santri) {
                      return DropdownMenuItem<int>(
                        value: santri['id'] as int,
                        child: Text(
                          santri['name'] ?? '',
                          style: GoogleFonts.poppins(fontSize: 14),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedSantriId = val),
                  ),
                  const SizedBox(height: 16),

                  // Jenis Izin
                  DropdownButtonFormField<String>(
                    value: _selectedJenisIzin,
                    decoration: InputDecoration(
                      labelText: 'JENIS IZIN',
                      labelStyle: GoogleFonts.poppins(
                        color: AppColors.textSecondary.withValues(alpha: 0.8),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                      ),
                      filled: true,
                      fillColor: AppColors.inputBackground,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.inputBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.inputBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.accent, width: 2),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Sakit', child: Text('Sakit')),
                      DropdownMenuItem(value: 'Pulang', child: Text('Pulang / Izin Keluar')),
                      DropdownMenuItem(value: 'Lainnya', child: Text('Lainnya')),
                    ],
                    onChanged: (val) => setState(() => _selectedJenisIzin = val),
                  ),
                  const SizedBox(height: 16),

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
                    readOnly: true,
                    onTap: () => _selectDate(context, _tglMulaiController),
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
                    readOnly: true,
                    onTap: () => _selectDate(context, _tglSelesaiController),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Tanggal selesai harus diisi';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Upload Bukti Pendukung
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
    final bool hasFile = _buktiFile != null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _pickImage,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: hasFile ? const Color(0xFFE8F2EF) : AppColors.inputBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: hasFile ? const Color(0xFF2A8B72) : AppColors.inputBorder,
              style: BorderStyle.solid,
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            children: [
              Icon(
                hasFile ? Icons.check_circle_rounded : Icons.cloud_upload_outlined,
                color: hasFile ? const Color(0xFF2A8B72) : AppColors.accent,
                size: 36,
              ),
              const SizedBox(height: 12),
              Text(
                hasFile
                    ? 'Gambar terpilih: ${_buktiFile!.name}'
                    : 'Upload Bukti Pendukung (Opsional)',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: hasFile ? const Color(0xFF1E2925) : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                hasFile ? 'Klik untuk mengganti gambar' : 'Format JPG atau PNG maks 2MB',
                style: GoogleFonts.poppins(
                  color: AppColors.textHint,
                  fontSize: 11,
                ),
              ),
              if (hasFile) ...[
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: _clearImage,
                  icon: const Icon(Icons.delete_forever, color: AppColors.error, size: 18),
                  label: Text(
                    'Hapus Bukti',
                    style: GoogleFonts.poppins(
                      color: AppColors.error,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
