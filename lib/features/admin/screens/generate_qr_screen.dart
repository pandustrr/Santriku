import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:santriku_app/core/core.dart';
import 'package:santriku_app/features/admin/services/admin_service.dart';

/// Layar Generate QR untuk Admin
/// Admin bisa generate QR Absensi dan QR Konsumsi untuk setiap santri
/// yang nantinya bisa di-scan oleh pengurus.
class GenerateQrScreen extends StatefulWidget {
  const GenerateQrScreen({super.key});

  @override
  State<GenerateQrScreen> createState() => _GenerateQrScreenState();
}

class _GenerateQrScreenState extends State<GenerateQrScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<Map<String, dynamic>> _santriList = [];
  Map<String, dynamic>? _selectedSantri;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchSantri();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchSantri() async {
    setState(() => _isLoading = true);
    final data = await AdminService.getSantris();
    if (mounted) {
      setState(() {
        _santriList = data;
        _isLoading = false;
        if (data.isNotEmpty) _selectedSantri = data.first;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),
      appBar: AppBar(
        title: Text('Generate QR Code',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.accent,
          labelColor: AppColors.accent,
          unselectedLabelColor: Colors.white70,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
          tabs: const [
            Tab(text: 'QR Absensi'),
            Tab(text: 'QR Konsumsi'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
          : Column(
              children: [
                // Selector santri
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pilih Santri',
                        style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<Map<String, dynamic>>(
                        value: _selectedSantri,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFF5F7F6),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                        hint: Text('Pilih santri...',
                            style: GoogleFonts.poppins(color: Colors.grey)),
                        items: _santriList
                            .map((s) => DropdownMenuItem(
                                  value: s,
                                  child: Text(
                                    '${s['name']} (${s['nis'] ?? '-'})',
                                    style: GoogleFonts.poppins(fontSize: 14),
                                  ),
                                ))
                            .toList(),
                        onChanged: (val) =>
                            setState(() => _selectedSantri = val),
                      ),
                    ],
                  ),
                ),

                // TabBarView
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildQrView(isAbsensi: true),
                      _buildQrView(isAbsensi: false),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildQrView({required bool isAbsensi}) {
    if (_selectedSantri == null) {
      return Center(
        child: Text(
          'Tidak ada data santri',
          style: GoogleFonts.poppins(color: Colors.grey),
        ),
      );
    }

    final qrToken = _selectedSantri!['qr_token'] ?? '';
    final santriName = _selectedSantri!['name'] ?? '';
    final nis = _selectedSantri!['nis'] ?? '';

    // QR content: untuk absensi dan konsumsi sama-sama pakai qr_token
    // Backend yang membedakan endpoint-nya
    final qrData = qrToken;

    final color = isAbsensi ? AppColors.primaryDark : const Color(0xFF2A8B72);
    final title = isAbsensi ? 'QR Absensi' : 'QR Konsumsi';
    final subtitle = isAbsensi
        ? 'Scan untuk mencatat kehadiran santri'
        : 'Scan untuk mencatat konsumsi santri';
    final icon = isAbsensi
        ? Icons.qr_code_scanner_rounded
        : Icons.restaurant_rounded;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Info header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: GoogleFonts.poppins(
                              color: color,
                              fontSize: 15,
                              fontWeight: FontWeight.w700)),
                      Text(subtitle,
                          style: GoogleFonts.poppins(
                              color: Colors.grey[600], fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // QR Code card
          if (qrToken.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Icon(Icons.qr_code_2, size: 64, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(
                    'Santri ini belum memiliki QR Token',
                    style: GoogleFonts.poppins(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            _QrCard(
              qrData: qrData,
              santriName: santriName,
              nis: nis,
              isAbsensi: isAbsensi,
              color: color,
            ),

          const SizedBox(height: 20),

          // Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.amber, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isAbsensi
                        ? 'QR Absensi ini digunakan pengurus untuk scan kehadiran. Pastikan santri membawa QR ini saat absensi berlangsung dan berada dalam area pesantren.'
                        : 'QR Konsumsi ini digunakan pengurus untuk mencatat santri yang mengambil jatah makan.',
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: Colors.amber[900]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QrCard extends StatelessWidget {
  final String qrData;
  final String santriName;
  final String nis;
  final bool isAbsensi;
  final Color color;

  const _QrCard({
    required this.qrData,
    required this.santriName,
    required this.nis,
    required this.isAbsensi,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header dengan nama
          Text(
            santriName,
            style: GoogleFonts.poppins(
                fontSize: 18, fontWeight: FontWeight.w700, color: color),
            textAlign: TextAlign.center,
          ),
          if (nis.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'NIS: $nis',
              style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500),
            ),
          ],
          const SizedBox(height: 20),

          // QR Code
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
            ),
            child: QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: 220,
              backgroundColor: Colors.white,
              eyeStyle: QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: color,
              ),
              dataModuleStyle: QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: color,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Token label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              qrData,
              style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: color,
                  fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 12),

          // Label tipe QR
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isAbsensi ? '📋 QR ABSENSI' : '🍽️ QR KONSUMSI',
              style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
