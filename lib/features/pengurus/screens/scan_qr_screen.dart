import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:santriku_app/core/core.dart';
import 'package:santriku_app/features/auth/services/auth_service.dart';
import 'absensi_result_screen.dart';

/// Halaman Scan QR Code untuk Absensi & Jatah Konsumsi.
class ScanQrScreen extends StatefulWidget {
  final bool isAbsensi;

  const ScanQrScreen({super.key, required this.isAbsensi});

  @override
  State<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends State<ScanQrScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _laserController;
  bool _hasScanned = false;
  bool _isLoading = false;

  // Selected Coordinates & Location Info
  double _selectedLat = -8.12345;
  double _selectedLon = 113.12345;
  String _selectedLocationName = 'Simulasi: Di Dalam Pesantren';
  bool _geofenceOk = true;

  @override
  void initState() {
    super.initState();
    _laserController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    if (!_hasScanned) {
      _laserController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _laserController.dispose();
    super.dispose();
  }

  void _showSimulationOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pilih Mode Pemindaian QR',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Gunakan koordinat di bawah untuk menguji geofencing:',
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 20),
              
              // 1. Di Dalam Pesantren
              ListTile(
                leading: const Icon(Icons.check_circle_outline_rounded, color: AppColors.success),
                title: Text('Di Dalam Pesantren (Sukses)', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
                subtitle: Text('Latitude: -8.12345, Longitude: 113.12345', style: GoogleFonts.poppins(fontSize: 11)),
                onTap: () {
                  Navigator.pop(context);
                  _triggerScanSimulation(
                    lat: -8.12345,
                    lon: 113.12345,
                    locName: 'Simulasi: Di Dalam Pesantren',
                    isOk: true,
                  );
                },
              ),
              const Divider(height: 1),

              // 2. Di Luar Pesantren
              ListTile(
                leading: const Icon(Icons.cancel_outlined, color: AppColors.error),
                title: Text('Di Luar Pesantren (Gagal Geofence)', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
                subtitle: Text('Latitude: -8.20000, Longitude: 113.12345', style: GoogleFonts.poppins(fontSize: 11)),
                onTap: () {
                  Navigator.pop(context);
                  _triggerScanSimulation(
                    lat: -8.20000,
                    lon: 113.12345,
                    locName: 'Simulasi: Di Luar Pesantren (Jauh)',
                    isOk: false,
                  );
                },
              ),
              const Divider(height: 1),

              // 3. GPS Asli Perangkat
              ListTile(
                leading: const Icon(Icons.my_location_rounded, color: AppColors.info),
                title: Text('Gunakan GPS Asli Laptop/HP', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
                subtitle: Text('Membaca koordinat riil perangkat secara langsung.', style: GoogleFonts.poppins(fontSize: 11)),
                onTap: () {
                  Navigator.pop(context);
                  _useRealGps();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _triggerScanSimulation({
    required double lat,
    required double lon,
    required String locName,
    required bool isOk,
  }) {
    _laserController.stop();
    setState(() {
      _selectedLat = lat;
      _selectedLon = lon;
      _selectedLocationName = locName;
      _geofenceOk = isOk;
      _hasScanned = true;
    });
  }

  Future<void> _useRealGps() async {
    setState(() => _isLoading = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'GPS/Layanan lokasi dinonaktifkan di perangkat Anda.';
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Izin lokasi ditolak.';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'Izin lokasi ditolak permanen. Silakan aktifkan di pengaturan.';
      }

      Position position = await Geolocator.getCurrentPosition();
      
      // Calculate distance from center (-8.12345, 113.12345)
      double distance = Geolocator.distanceBetween(-8.12345, 113.12345, position.latitude, position.longitude);
      bool isOk = distance <= 100.0;

      _laserController.stop();
      setState(() {
        _selectedLat = position.latitude;
        _selectedLon = position.longitude;
        _selectedLocationName = 'GPS Riil: ${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}';
        _geofenceOk = isOk;
        _hasScanned = true;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengambil GPS: $e'), backgroundColor: AppColors.error),
        );
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _resetScan() {
    _laserController.repeat(reverse: true);
    setState(() {
      _hasScanned = false;
    });
  }

  Future<void> _saveData() async {
    setState(() => _isLoading = true);

    try {
      final String urlPath = widget.isAbsensi ? 'attendance' : 'consumption';
      final Map<String, dynamic> requestBody = widget.isAbsensi
          ? {
              'qr_token': 'santri_ahmad_fauzi_10101',
              'latitude': _selectedLat,
              'longitude': _selectedLon,
              'status': 'Hadir',
            }
          : {
              'qr_token': 'santri_ahmad_fauzi_10101',
              'jenis_makan': 'Malam',
            };

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/pengurus/$urlPath'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${AuthService.token}',
        },
        body: jsonEncode(requestBody),
      );

      final data = jsonDecode(response.body);
      final now = DateTime.now();
      final formattedTime =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} WIB';

      if (mounted) {
        setState(() => _isLoading = false);

        if (response.statusCode == 201) {
          final String displayName = widget.isAbsensi
              ? (data['absensi']['santri_name'] ?? 'Ahmad Fauzi')
              : (data['consumption']['santri_name'] ?? 'Ahmad Fauzi');
          final String displayStatus = widget.isAbsensi
              ? (data['absensi']['status'] ?? 'Hadir')
              : 'Makan Malam Berhasil';

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => AbsensiResultScreen(
                isAbsensi: widget.isAbsensi,
                santriName: displayName,
                status: displayStatus,
                timestamp: formattedTime,
                isSuccess: true,
              ),
            ),
          );
        } else {
          // Failure (e.g. 400 Duplicate, 422 Out of range)
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AbsensiResultScreen(
                isAbsensi: widget.isAbsensi,
                santriName: 'Ahmad Fauzi',
                status: data['message'] ?? 'Proses gagal.',
                timestamp: formattedTime,
                isSuccess: false,
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kesalahan jaringan: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              )
            : Column(
                children: [
                  _buildCustomAppBar(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildScannerBox(),
                          const SizedBox(height: 18),
                          if (!_hasScanned) _buildSimulationTriggerCard(),
                          if (_hasScanned) ...[
                            if (widget.isAbsensi) _buildAbsensiDetails() else _buildKonsumsiDetails(),
                            const SizedBox(height: 80),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
      bottomSheet: (_hasScanned && !_isLoading) ? _buildBottomSheetButtons() : null,
    );
  }

  // ── Custom AppBar ───────────────────────────────────────
  Widget _buildCustomAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Padding(
                padding: EdgeInsets.only(right: 2.0),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Color(0xFF1E2925),
                  size: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.isAbsensi ? 'Absensi Santri' : 'Jatah Konsumsi',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF1E2925),
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                widget.isAbsensi ? 'Scan QR kartu santri' : 'Scan oleh Administrator',
                style: GoogleFonts.poppins(
                  color: Colors.grey[500],
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Scanner Box ────────────────────
  Widget _buildScannerBox() {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        color: const Color(0xFF0F2D26),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          _buildScannerBrackets(),
          if (!_hasScanned)
            AnimatedBuilder(
              animation: _laserController,
              builder: (context, child) {
                return Positioned(
                  top: 24 + (_laserController.value * 132),
                  left: 36,
                  right: 36,
                  child: Container(
                    height: 2,
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withValues(alpha: 0.6),
                          blurRadius: 6,
                          spreadRadius: 1.5,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          Center(
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white24, width: 1),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Text(
              widget.isAbsensi ? 'Arahkan ke QR kartu santri' : 'Arahkan ke QR santri',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScannerBrackets() {
    const double size = 20;
    const double thick = 2.5;
    const Color color = AppColors.accent;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            child: Container(width: size, height: thick, color: color),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: Container(width: thick, height: size, color: color),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Container(width: size, height: thick, color: color),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Container(width: thick, height: size, color: color),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: Container(width: size, height: thick, color: color),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: Container(width: thick, height: size, color: color),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(width: size, height: thick, color: color),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(width: thick, height: size, color: color),
          ),
        ],
      ),
    );
  }

  // ── Trigger Simulation Button Card ─────────────────────
  Widget _buildSimulationTriggerCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 24),
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
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(
            Icons.qr_code_scanner_rounded,
            color: AppColors.accent,
            size: 40,
          ),
          const SizedBox(height: 14),
          Text(
            'Simulasikan Pemindaian',
            style: GoogleFonts.poppins(
              color: const Color(0xFF1E2925),
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Klik tombol di bawah untuk menyimulasikan pembacaan QR Code kartu santri dengan opsi lokasi.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _showSimulationOptions,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF104A3E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Mulai Pindai QR',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Detail Absensi View (Left Screen) ──────────────────
  Widget _buildAbsensiDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Location Card
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _geofenceOk ? const Color(0xFFE8F2EF) : const Color(0xFFFDE8E8),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.location_on_outlined,
                  color: _geofenceOk ? const Color(0xFF2A8B72) : AppColors.error,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedLocationName,
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF1E2925),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Lat: ${_selectedLat.toStringAsFixed(5)} • Lon: ${_selectedLon.toStringAsFixed(5)}',
                      style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[550]),
                    )
                  ],
                ),
              ),
              Text(
                _geofenceOk ? 'GPS OK' : 'GPS OUT',
                style: GoogleFonts.poppins(
                  color: _geofenceOk ? const Color(0xFF2A8B72) : AppColors.error,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        Text(
          'SANTRI TERBACA',
          style: GoogleFonts.poppins(
            color: Colors.grey[500],
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 10),

        _buildSantriProfileCard(),

        const SizedBox(height: 14),

        _buildStatusCheckRow('QR kartu santri terbaca', true),
        const SizedBox(height: 8),
        _buildStatusCheckRow('Lokasi & Geofence sesuai', _geofenceOk),
        const SizedBox(height: 8),
        _buildStatusCheckRow('Waktu absen tercatat', true),
      ],
    );
  }

  // ── Detail Konsumsi View (Right Screen) ────────────────
  Widget _buildKonsumsiDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSantriProfileCard(),
        const SizedBox(height: 24),
        Text(
          'JATAH HARI INI',
          style: GoogleFonts.poppins(
            color: Colors.grey[500],
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildMealItemCard('Sarapan', 'Diambil', Icons.local_cafe_outlined, true),
            const SizedBox(width: 12),
            _buildMealItemCard('Siang', 'Diambil', Icons.wb_sunny_outlined, true),
            const SizedBox(width: 12),
            _buildMealItemCard('Malam', 'Tersedia', Icons.nightlight_round_outlined, false),
          ],
        ),
        const SizedBox(height: 18),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF1A6B5A),
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.all(18),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SISA JATAH',
                    style: GoogleFonts.poppins(
                      color: Colors.white60,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '1',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        ' / 3',
                        style: GoogleFonts.poppins(
                          color: Colors.white60,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Positioned(
                right: 0,
                bottom: 0,
                top: 0,
                child: Icon(
                  Icons.restaurant_rounded,
                  color: Colors.white.withValues(alpha: 0.1),
                  size: 48,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSantriProfileCard() {
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
          const CircleAvatar(
            radius: 20,
            backgroundColor: Color(0xFF1C6B59),
            child: Text(
              'A',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ahmad Fauzi',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF1E2925),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'NIS 10101',
                  style: GoogleFonts.poppins(
                    color: Colors.grey[500],
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: _geofenceOk ? const Color(0xFF2A8B72) : AppColors.error,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _geofenceOk ? Icons.check_rounded : Icons.close_rounded,
              color: Colors.white,
              size: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCheckRow(String label, bool isOk) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.01),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(
            isOk ? Icons.check_circle_outline_rounded : Icons.cancel_outlined,
            color: isOk ? const Color(0xFF2A8B72) : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                color: const Color(0xFF1E2925),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            isOk ? 'OK' : 'ERROR',
            style: GoogleFonts.poppins(
              color: isOk ? const Color(0xFF2A8B72) : Colors.red,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealItemCard(String meal, String status, IconData icon, bool isTaken) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isTaken ? const Color(0xFFE8F2EF) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isTaken ? null : Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isTaken ? const Color(0xFF2A8B72) : Colors.grey[400],
              size: 22,
            ),
            const SizedBox(height: 8),
            Text(
              meal,
              style: GoogleFonts.poppins(
                color: isTaken ? const Color(0xFF1E2925) : Colors.grey[700],
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              status,
              style: GoogleFonts.poppins(
                color: isTaken ? const Color(0xFF2A8B72) : Colors.grey[400],
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSheetButtons() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 20),
      child: Row(
        children: [
          ElevatedButton(
            onPressed: widget.isAbsensi
                ? _resetScan
                : () {
                    final now = DateTime.now();
                    final formattedTime =
                        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} WIB';
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AbsensiResultScreen(
                          isAbsensi: false,
                          santriName: 'Ahmad Fauzi',
                          status: 'Ditolak',
                          timestamp: formattedTime,
                          isSuccess: false,
                        ),
                      ),
                    );
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.isAbsensi ? const Color(0xFFF0F2F1) : const Color(0xFFFDE8E8),
              foregroundColor: widget.isAbsensi ? const Color(0xFF1E2925) : AppColors.error,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.isAbsensi) ...[
                  const Icon(Icons.qr_code_scanner_rounded, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Scan Lain',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                ] else ...[
                  const Icon(Icons.close_rounded, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'Tolak',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                ]
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _saveData,
              icon: const Icon(Icons.check_rounded, color: Colors.white, size: 18),
              label: Text(
                widget.isAbsensi ? 'Simpan Absen' : 'Ambil Jatah Malam',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.isAbsensi ? const Color(0xFF1A6B5A) : const Color(0xFF2A8B72),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
