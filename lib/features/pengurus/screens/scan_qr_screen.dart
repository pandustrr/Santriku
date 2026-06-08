import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:santriku_app/core/core.dart';

/// Halaman Scan QR Code untuk Absensi & Jatah Konsumsi.
///
/// Didesain interaktif dan presisi mengikuti Gambar 4.3 (Proses Scan QR Code).
class ScanQrScreen extends StatefulWidget {
  final bool isAbsensi;

  const ScanQrScreen({super.key, required this.isAbsensi});

  @override
  State<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends State<ScanQrScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _laserController;
  bool _hasScanned = true; // Menandakan apakah QR code sudah disimulasikan terbaca

  @override
  void initState() {
    super.initState();
    _laserController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _laserController.dispose();
    super.dispose();
  }

  void _triggerScanSimulation() {
    setState(() {
      _hasScanned = true;
    });
  }

  void _resetScan() {
    setState(() {
      _hasScanned = false;
    });
  }

  void _saveData() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.isAbsensi 
              ? 'Absensi Ahmad Fauzi berhasil disimpan!' 
              : 'Jatah makan malam Ahmad Fauzi berhasil diambil!',
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6), // Background off-white
      body: SafeArea(
        child: Column(
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
                      const SizedBox(height: 80), // Spacer untuk menghindari overlap button
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomSheet: _hasScanned ? _buildBottomSheetButtons() : null,
    );
  }

  // ── Custom AppBar ───────────────────────────────────────
  Widget _buildCustomAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Back button
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
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Color(0xFF1E2925),
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Title & Subtitle
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

  // ── Scanner Box with Laser Animation ────────────────────
  Widget _buildScannerBox() {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        color: const Color(0xFF0F2D26), // Dark green background
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          // Yellow Brackets (Bidik)
          _buildScannerBrackets(),

          // Laser Scanner line
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

          // Center Bidik Overlay
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

          // Text Instruction inside Scanner Box
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
          // Top Left
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

          // Top Right
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

          // Bottom Left
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

          // Bottom Right
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
            'Klik tombol di bawah untuk menyimulasikan pembacaan QR Code kartu santri.',
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
              onPressed: _triggerScanSimulation,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF104A3E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Simulasi Scan QR',
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
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F2EF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_on_outlined,
                  color: Color(0xFF2A8B72),
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Gerbang Utama Pesantren',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF1E2925),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                'GPS OK',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF2A8B72),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Section Title: SANTRI TERBACA
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

        // Santri Profile Card
        _buildSantriProfileCard(),

        const SizedBox(height: 14),

        // Checklist Status Items
        _buildStatusCheckRow('QR kartu santri terbaca', true),
        const SizedBox(height: 8),
        _buildStatusCheckRow('Lokasi & Geofence sesuai', true),
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
        // Santri Profile Card
        _buildSantriProfileCard(),

        const SizedBox(height: 24),

        // Section Title: JATAH HARI INI
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

        // Meal Row
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

        // Card Sisa Jatah
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
              // Fork & Spoon background icon on the right
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

  // Helper Santri Profile Card
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
                  'NIS 23.0142 • XI-A',
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
            decoration: const BoxDecoration(
              color: Color(0xFF2A8B72),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 14,
            ),
          ),
        ],
      ),
    );
  }

  // Helper Checklist Row
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

  // Helper Meal Item Card Builder
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

  // ── Bottom Sheet Action Buttons ─────────────────────────
  Widget _buildBottomSheetButtons() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 20),
      child: Row(
        children: [
          // Left Small Button
          ElevatedButton(
            onPressed: _resetScan,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF0F2F1),
              foregroundColor: const Color(0xFF1E2925),
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
                  Text(
                    'Tolak',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                ]
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Right Large Expanded Button
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
