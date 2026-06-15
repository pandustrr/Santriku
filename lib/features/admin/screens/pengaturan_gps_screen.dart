import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:santriku_app/core/core.dart';
import 'package:santriku_app/features/admin/services/admin_service.dart';

/// Halaman Pengaturan GPS & Geofencing untuk Admin.
/// Admin bisa mengubah lokasi koordinat pusat pesantren secara dinamis.
class PengaturanGpsScreen extends StatefulWidget {
  const PengaturanGpsScreen({super.key});

  @override
  State<PengaturanGpsScreen> createState() => _PengaturanGpsScreenState();
}

class _PengaturanGpsScreenState extends State<PengaturanGpsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _latController = TextEditingController();
  final _lonController = TextEditingController();
  final _radiusController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isLocating = false;

  @override
  void initState() {
    super.initState();
    _fetchSettings();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _latController.dispose();
    _lonController.dispose();
    _radiusController.dispose();
    super.dispose();
  }

  Future<void> _fetchSettings() async {
    setState(() => _isLoading = true);
    final settings = await AdminService.getSettings();
    if (mounted && settings.isNotEmpty) {
      setState(() {
        _nameController.text = settings['name']?.toString() ?? '';
        _latController.text = settings['latitude']?.toString() ?? '';
        _lonController.text = settings['longitude']?.toString() ?? '';
        _radiusController.text = settings['radius']?.toString() ?? '100';
        _isLoading = false;
      });
    } else {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLocating = true);
    try {
      // Cek layanan lokasi
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Layanan lokasi (GPS) dinonaktifkan di perangkat Anda.';
      }

      // Cek izin
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Izin lokasi ditolak.';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'Izin lokasi ditolak permanen. Buka pengaturan perangkat untuk mengaktifkan.';
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _latController.text = position.latitude.toString();
        _lonController.text = position.longitude.toString();
        _isLocating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Lokasi saat ini berhasil disematkan!'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      setState(() => _isLocating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mendapatkan lokasi: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _applyPresetFasilkomUnej() {
    setState(() {
      _nameController.text = 'Fasilkom Universitas Jember';
      _latController.text = '-8.164667';
      _lonController.text = '113.717056';
      _radiusController.text = '100';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✓ Preset Fasilkom UNEJ berhasil diterapkan!'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final data = {
      'name': _nameController.text.trim(),
      'latitude': double.parse(_latController.text.trim()),
      'longitude': double.parse(_lonController.text.trim()),
      'radius': double.parse(_radiusController.text.trim()),
    };

    final result = await AdminService.updateSettings(data);
    if (mounted) {
      setState(() => _isSaving = false);
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Pengaturan berhasil disimpan!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Gagal menyimpan pengaturan.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),
      appBar: AppBar(
        title: Text('Pengaturan Lokasi & GPS',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info Panel
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primaryDark.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.primaryDark.withValues(alpha: 0.15)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded, color: AppColors.primaryDark, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Verifikasi Absensi Berbasis GPS',
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primaryDark,
                                      fontSize: 14),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Pengurus hanya bisa melakukan absensi jika berada di dalam radius geofence lokasi yang diatur di bawah ini.',
                                  style: GoogleFonts.poppins(
                                      color: Colors.grey[700], fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Preset buttons
                    Text(
                      'PRESET LOKASI CEPAT',
                      style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark.withValues(alpha: 0.6),
                          letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ActionChip(
                          avatar: const Icon(Icons.school, size: 16, color: Color(0xFFD49520)),
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: AppColors.accent),
                          label: Text(
                            'Fasilkom UNEJ',
                            style: GoogleFonts.poppins(
                                color: AppColors.primaryDark,
                                fontSize: 12,
                                fontWeight: FontWeight.w600),
                          ),
                          onPressed: _applyPresetFasilkomUnej,
                        ),
                        ActionChip(
                          avatar: _isLocating
                              ? const SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blue),
                                )
                              : const Icon(Icons.my_location, size: 16, color: Colors.blue),
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: Colors.blue),
                          label: Text(
                            'Gunakan GPS HP Saya',
                            style: GoogleFonts.poppins(
                                color: AppColors.primaryDark,
                                fontSize: 12,
                                fontWeight: FontWeight.w600),
                          ),
                          onPressed: _isLocating ? null : _getCurrentLocation,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Inputs card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Name Field
                          TextFormField(
                            controller: _nameController,
                            style: GoogleFonts.poppins(fontSize: 14, color: AppColors.primaryDark),
                            decoration: InputDecoration(
                              labelText: 'NAMA LOKASI',
                              hintText: 'Contoh: Pondok Pesantren Santriku',
                              labelStyle: GoogleFonts.poppins(
                                  fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primaryDark),
                              prefixIcon: const Icon(Icons.pin_drop_outlined, color: AppColors.primaryDark),
                              filled: true,
                              fillColor: const Color(0xFFF5F7F6),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            validator: (v) => v == null || v.isEmpty ? 'Nama lokasi tidak boleh kosong' : null,
                          ),
                          const SizedBox(height: 16),

                          // Latitude Field
                          TextFormField(
                            controller: _latController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                            style: GoogleFonts.poppins(fontSize: 14, color: AppColors.primaryDark),
                            decoration: InputDecoration(
                              labelText: 'LATITUDE (GARIS LINTANG)',
                              hintText: 'Contoh: -8.164667',
                              labelStyle: GoogleFonts.poppins(
                                  fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primaryDark),
                              prefixIcon: const Icon(Icons.map_outlined, color: AppColors.primaryDark),
                              filled: true,
                              fillColor: const Color(0xFFF5F7F6),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Latitude tidak boleh kosong';
                              if (double.tryParse(v) == null) return 'Format angka tidak valid';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Longitude Field
                          TextFormField(
                            controller: _lonController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                            style: GoogleFonts.poppins(fontSize: 14, color: AppColors.primaryDark),
                            decoration: InputDecoration(
                              labelText: 'LONGITUDE (GARIS BUJUR)',
                              hintText: 'Contoh: 113.717056',
                              labelStyle: GoogleFonts.poppins(
                                  fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primaryDark),
                              prefixIcon: const Icon(Icons.explore_outlined, color: AppColors.primaryDark),
                              filled: true,
                              fillColor: const Color(0xFFF5F7F6),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Longitude tidak boleh kosong';
                              if (double.tryParse(v) == null) return 'Format angka tidak valid';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Radius Field
                          TextFormField(
                            controller: _radiusController,
                            keyboardType: TextInputType.number,
                            style: GoogleFonts.poppins(fontSize: 14, color: AppColors.primaryDark),
                            decoration: InputDecoration(
                              labelText: 'RADIUS GEOFENCE (METER)',
                              hintText: 'Contoh: 100',
                              labelStyle: GoogleFonts.poppins(
                                  fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primaryDark),
                              prefixIcon: const Icon(Icons.circle_outlined, color: AppColors.primaryDark),
                              filled: true,
                              fillColor: const Color(0xFFF5F7F6),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Radius tidak boleh kosong';
                              final r = double.tryParse(v);
                              if (r == null) return 'Format angka tidak valid';
                              if (r < 10) return 'Radius minimal adalah 10 meter';
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: _isSaving ? null : _saveSettings,
                        icon: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.save_rounded, color: Colors.white),
                        label: Text(
                          _isSaving ? 'Menyimpan...' : 'Simpan Pengaturan',
                          style: GoogleFonts.poppins(
                              color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
