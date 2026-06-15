import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:santriku_app/core/core.dart';
import 'package:santriku_app/features/auth/services/auth_service.dart';
import 'absensi_result_screen.dart';
import 'package:santriku_app/features/admin/services/admin_service.dart';

/// Halaman Scan QR Code untuk Absensi & Jatah Konsumsi.
/// - Langsung buka kamera tanpa modal "Mode Pemindaian"
/// - GPS wajib untuk absensi (geofence pesantren)
/// - Upload QR dari galeri juga tersedia
class ScanQrScreen extends StatefulWidget {
  final bool isAbsensi;
  const ScanQrScreen({super.key, required this.isAbsensi});

  @override
  State<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends State<ScanQrScreen>
    with WidgetsBindingObserver {
  // ── State kamera ──────────────────────────────────────────
  final MobileScannerController _cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
    torchEnabled: false,
  );
  bool _isTorchOn = false;
  bool _isProcessing = false;

  // ── State GPS ─────────────────────────────────────────────
  bool _isGpsLoading = true;
  Position? _currentPosition;
  String _locationLabel = 'Mendapatkan lokasi GPS...';
  bool _geofenceOk = false;
  String? _gpsError;

  // ── Koordinat pusat pesantren (ganti sesuai lokasi nyata) ─
  static const double _pesantrenLat = -8.12345;
  static const double _pesantrenLon = 113.12345;
  static const double _geofenceRadius = 100.0; // meter

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.isAbsensi) {
      _initGps();
    } else {
      setState(() {
        _isGpsLoading = false;
        _locationLabel = 'GPS tidak diperlukan untuk konsumsi';
        _geofenceOk = true;
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_cameraController.value.isInitialized) return;
    if (state == AppLifecycleState.resumed) {
      _cameraController.start();
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _cameraController.stop();
    }
  }

  // ── GPS ───────────────────────────────────────────────────

  Future<void> _initGps() async {
    if (mounted) {
      setState(() {
        _isGpsLoading = true;
        _gpsError = null;
      });
    }

    try {
      // 1. Cek layanan GPS aktif
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'GPS dinonaktifkan. Aktifkan GPS di pengaturan perangkat.';
      }

      // 2. Cek & minta izin
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Izin GPS ditolak. Scan absensi membutuhkan akses lokasi.';
        }
      }
      if (permission == LocationPermission.deniedForever) {
        throw 'Izin GPS ditolak permanen.\nBuka Pengaturan > Aplikasi > Santriku > Izin Lokasi.';
      }

      // 3. Dapatkan posisi
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      // 4. Hitung jarak ke pesantren
      final distance = Geolocator.distanceBetween(
        _pesantrenLat,
        _pesantrenLon,
        position.latitude,
        position.longitude,
      );
      final isOk = distance <= _geofenceRadius;

      if (mounted) {
        setState(() {
          _currentPosition = position;
          _geofenceOk = isOk;
          _isGpsLoading = false;
          _locationLabel = isOk
              ? '✓ Di dalam area pesantren (${distance.toStringAsFixed(0)}m)'
              : '✗ Di luar area pesantren (${distance.toStringAsFixed(0)}m)';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isGpsLoading = false;
          _gpsError = e.toString();
          _locationLabel = 'Gagal mendapatkan GPS';
          _geofenceOk = false;
        });
      }
    }
  }

  // ── QR Scan via kamera ────────────────────────────────────

  void _onQrDetected(BarcodeCapture capture) {
    if (_isProcessing) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) return;
    _processQrToken(barcode.rawValue!);
  }

  // ── QR via upload gambar ──────────────────────────────────

  Future<void> _pickQrFromGallery() async {
    if (_isProcessing) return;
    try {
      _cameraController.stop();
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image == null) {
        _cameraController.start();
        return;
      }

      final result = await MobileScannerController().analyzeImage(image.path);
      _cameraController.start();

      if (result == null || result.barcodes.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'QR Code tidak terdeteksi pada gambar.',
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      final qrToken = result.barcodes.first.rawValue;
      if (qrToken != null) {
        _processQrToken(qrToken);
      }
    } catch (e) {
      _cameraController.start();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membaca gambar: $e', style: GoogleFonts.poppins()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // ── Proses token QR ke API ────────────────────────────────

  Future<void> _processQrToken(String qrToken) async {
    if (_isProcessing) return;

    // Untuk absensi: wajib ada GPS
    if (widget.isAbsensi) {
      if (_isGpsLoading) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Menunggu GPS... Harap tunggu.',
                  style: GoogleFonts.poppins()),
              backgroundColor: AppColors.warning,
            ),
          );
        }
        return;
      }
      if (_gpsError != null || _currentPosition == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('GPS belum tersedia: $_gpsError',
                  style: GoogleFonts.poppins()),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }
      // Geofence check — beri peringatan tapi tetap lanjut (bisa disesuaikan)
      if (!_geofenceOk) {
        // Tampilkan dialog konfirmasi jika di luar area
        final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Di Luar Area Pesantren',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
            content: Text(
              'Anda berada di luar area pesantren.\nAbsensi tetap akan dicatat dengan lokasi saat ini.',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text('Batal', style: GoogleFonts.poppins()),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.warning),
                child: Text('Lanjutkan',
                    style: GoogleFonts.poppins(color: Colors.white)),
              ),
            ],
          ),
        );
        if (confirm != true) {
          _cameraController.start();
          return;
        }
      }
    }

    if (mounted) setState(() => _isProcessing = true);
    _cameraController.stop();

    try {
      final String urlPath = widget.isAbsensi ? 'attendance' : 'consumption';

      final Map<String, dynamic> requestBody = widget.isAbsensi
          ? {
              'qr_token': qrToken,
              'latitude': _currentPosition!.latitude,
              'longitude': _currentPosition!.longitude,
              'status': 'Hadir',
            }
          : {
              'qr_token': qrToken,
              'jenis_makan': _getJenisMakan(),
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
        setState(() => _isProcessing = false);
        if (response.statusCode == 201) {
          final displayName = widget.isAbsensi
              ? (data['absensi']?['santri_name'] ?? 'Santri')
              : (data['consumption']?['santri_name'] ?? 'Santri');
          final displayStatus = widget.isAbsensi
              ? (data['absensi']?['status'] ?? 'Hadir')
              : 'Konsumsi Berhasil Dicatat';

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => AbsensiResultScreen(
                isAbsensi: widget.isAbsensi,
                santriName: displayName,
                status: displayStatus,
                timestamp: formattedTime,
                isSuccess: true,
              ),
            ),
          );
        } else {
          final errMsg = data['message'] ?? 'Proses gagal.';
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AbsensiResultScreen(
                isAbsensi: widget.isAbsensi,
                santriName: data['santri_name'] ?? '-',
                status: errMsg,
                timestamp: formattedTime,
                isSuccess: false,
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        _cameraController.start();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kesalahan jaringan: $e', style: GoogleFonts.poppins()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  String _getJenisMakan() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 10) return 'Sarapan';
    if (hour >= 10 && hour < 15) return 'Siang';
    return 'Malam';
  }

  // ── BUILD ─────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // ── Kamera fullscreen ─────────────────────────
            _buildCameraView(),

            // ── Overlay UI ────────────────────────────────
            Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      _buildScannerFrame(),
                      if (widget.isAbsensi) _buildGpsIndicator(),
                    ],
                  ),
                ),
                _buildBottomBar(),
              ],
            ),

            // ── Loading overlay ───────────────────────────
            if (_isProcessing)
              Container(
                color: Colors.black54,
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: AppColors.accent),
                      SizedBox(height: 16),
                      Text('Memproses...', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraView() {
    return MobileScanner(
      controller: _cameraController,
      onDetect: _onQrDetected,
      errorBuilder: (context, error, child) {
        return Container(
          color: Colors.black,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.camera_alt_outlined,
                    color: Colors.white54, size: 64),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'Kamera tidak dapat diakses.\n${error.errorDetails?.message ?? 'Periksa izin kamera di pengaturan.'}',
                    style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => _cameraController.start(),
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text('Coba Lagi',
                      style: GoogleFonts.poppins(
                          color: AppColors.primaryDarker,
                          fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    minimumSize: const Size(160, 44),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black.withValues(alpha: 0.8), Colors.transparent],
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.isAbsensi ? 'Scan QR Absensi' : 'Scan QR Konsumsi',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          // Senter
          IconButton(
            onPressed: () {
              _cameraController.toggleTorch();
              setState(() => _isTorchOn = !_isTorchOn);
            },
            icon: Icon(
              _isTorchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
              color: _isTorchOn ? AppColors.accent : Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScannerFrame() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Judul scan
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            widget.isAbsensi
                ? '📋 Arahkan ke QR Absensi Santri'
                : '🍽️ Arahkan ke QR Konsumsi Santri',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Bingkai scan
        Container(
          width: 240,
          height: 240,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.accent, width: 3),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Stack(
            children: [
              Positioned(top: -1.5, left: -1.5, child: _corner(isTop: true, isLeft: true)),
              Positioned(top: -1.5, right: -1.5, child: _corner(isTop: true, isLeft: false)),
              Positioned(bottom: -1.5, left: -1.5, child: _corner(isTop: false, isLeft: true)),
              Positioned(bottom: -1.5, right: -1.5, child: _corner(isTop: false, isLeft: false)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Posisikan QR Code di dalam bingkai',
          style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13),
        ),
      ],
    );
  }

  Widget _corner({required bool isTop, required bool isLeft}) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        border: Border(
          top: isTop ? const BorderSide(color: Colors.white, width: 4) : BorderSide.none,
          bottom: !isTop ? const BorderSide(color: Colors.white, width: 4) : BorderSide.none,
          left: isLeft ? const BorderSide(color: Colors.white, width: 4) : BorderSide.none,
          right: !isLeft ? const BorderSide(color: Colors.white, width: 4) : BorderSide.none,
        ),
        borderRadius: BorderRadius.only(
          topLeft: (isTop && isLeft) ? const Radius.circular(8) : Radius.zero,
          topRight: (isTop && !isLeft) ? const Radius.circular(8) : Radius.zero,
          bottomLeft: (!isTop && isLeft) ? const Radius.circular(8) : Radius.zero,
          bottomRight: (!isTop && !isLeft) ? const Radius.circular(8) : Radius.zero,
        ),
      ),
    );
  }

  Widget _buildGpsIndicator() {
    Color bgColor;
    Color textColor;
    IconData icon;

    if (_isGpsLoading) {
      bgColor = Colors.black54;
      textColor = Colors.white70;
      icon = Icons.gps_not_fixed_rounded;
    } else if (_gpsError != null) {
      bgColor = AppColors.error.withValues(alpha: 0.9);
      textColor = Colors.white;
      icon = Icons.gps_off_rounded;
    } else if (_geofenceOk) {
      bgColor = AppColors.success.withValues(alpha: 0.9);
      textColor = Colors.white;
      icon = Icons.gps_fixed_rounded;
    } else {
      bgColor = AppColors.warning.withValues(alpha: 0.9);
      textColor = Colors.white;
      icon = Icons.location_off_rounded;
    }

    return Positioned(
      top: 20,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _isGpsLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Icon(icon, color: textColor, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _locationLabel,
                style: GoogleFonts.poppins(
                    color: textColor, fontSize: 12, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (_gpsError != null)
              GestureDetector(
                onTap: _initGps,
                child: Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('Coba Lagi',
                      style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.black.withValues(alpha: 0.85), Colors.transparent],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Peringatan geofence
          if (widget.isAbsensi && !_isGpsLoading && !_geofenceOk && _gpsError == null)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.warning.withValues(alpha: 0.6)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: AppColors.warning, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Di luar area pesantren. Tap QR tetap bisa mencatat absensi.',
                      style: GoogleFonts.poppins(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

          // Tombol upload QR dari galeri
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isProcessing ? null : _pickQrFromGallery,
                  icon: const Icon(Icons.image_outlined, color: Colors.white),
                  label: Text(
                    widget.isAbsensi ? 'Upload QR Absensi' : 'Upload QR Konsumsi',
                    style: GoogleFonts.poppins(
                        color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white54),
                    minimumSize: const Size(0, 48),
                    shape:
                        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
