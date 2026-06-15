import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:santriku_app/core/core.dart';
import 'package:santriku_app/features/admin/services/admin_service.dart';

/// Halaman Detail Kehadiran Harian untuk Admin.
/// Menampilkan rekap absensi bulan ini dari semua santri,
/// termasuk ringkasan statistik kehadiran.
class DetailKehadiranScreen extends StatefulWidget {
  const DetailKehadiranScreen({super.key});

  @override
  State<DetailKehadiranScreen> createState() => _DetailKehadiranScreenState();
}

class _DetailKehadiranScreenState extends State<DetailKehadiranScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  List<Map<String, dynamic>> _rekapData = [];
  String _errorMessage = '';
  late TabController _tabController;

  // Ringkasan statistik
  int _totalHadir = 0;
  int _totalSakit = 0;
  int _totalIzin = 0;
  int _totalAlpha = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final now = DateTime.now();
    final data = await AdminService.getAttendanceReport(now.month, now.year);

    if (mounted) {
      int hadir = 0, sakit = 0, izin = 0, alpha = 0;
      for (var item in data) {
        hadir += (item['hadir'] as num? ?? 0).toInt();
        sakit += (item['sakit'] as num? ?? 0).toInt();
        izin += (item['izin'] as num? ?? 0).toInt();
        alpha += (item['alpha'] as num? ?? 0).toInt();
      }

      setState(() {
        _rekapData = data;
        _totalHadir = hadir;
        _totalSakit = sakit;
        _totalIzin = izin;
        _totalAlpha = alpha;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bulanIni = _getBulanNama(DateTime.now().month);
    final tahunIni = DateTime.now().year;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detail Kehadiran',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: _fetchData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.accent,
          labelColor: AppColors.accent,
          unselectedLabelColor: Colors.white70,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
          unselectedLabelStyle: GoogleFonts.poppins(fontSize: 13),
          tabs: const [
            Tab(text: 'Ringkasan'),
            Tab(text: 'Per Santri'),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.accent),
              )
            : _errorMessage.isNotEmpty
                ? _buildError()
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildRingkasanTab(bulanIni, tahunIni),
                      _buildPerSantriTab(),
                    ],
                  ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 48),
          const SizedBox(height: 12),
          Text(
            _errorMessage,
            style: GoogleFonts.poppins(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _fetchData,
            icon: const Icon(Icons.refresh),
            label: Text('Coba Lagi', style: GoogleFonts.poppins()),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
          ),
        ],
      ),
    );
  }

  // ── Tab 1: Ringkasan ─────────────────────────────────────

  Widget _buildRingkasanTab(String bulanIni, int tahunIni) {
    final total = _totalHadir + _totalSakit + _totalIzin + _totalAlpha;
    final hadirPct = total > 0 ? (_totalHadir / total) : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header periode
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.inputBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.calendar_month_rounded,
                        color: AppColors.accent,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Periode Laporan',
                          style: GoogleFonts.poppins(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '$bulanIni $tahunIni',
                          style: GoogleFonts.poppins(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Total Kehadiran Bulan Ini',
                  style: GoogleFonts.poppins(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: hadirPct,
                    minHeight: 12,
                    backgroundColor: Colors.white.withValues(alpha: 0.15),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.success),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${(hadirPct * 100).toStringAsFixed(1)}% dari total catatan',
                  style: GoogleFonts.poppins(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 4 kartu statistik
          Text(
            'Rekap Kehadiran',
            style: GoogleFonts.poppins(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: [
              _buildStatCard('Hadir', _totalHadir, Icons.check_circle_outline_rounded, AppColors.success, const Color(0xFF1B5E20)),
              _buildStatCard('Sakit', _totalSakit, Icons.local_hospital_outlined, AppColors.accent, const Color(0xFF4E2E00)),
              _buildStatCard('Izin', _totalIzin, Icons.assignment_turned_in_outlined, AppColors.info, const Color(0xFF0D2F4F)),
              _buildStatCard('Alpha', _totalAlpha, Icons.cancel_outlined, AppColors.error, const Color(0xFF4A0000)),
            ],
          ),
          const SizedBox(height: 20),

          // Tabel ringkasan
          Text(
            'Santri Paling Sering Alpha',
            style: GoogleFonts.poppins(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          ..._buildTopAlpha(),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, int count, IconData icon, Color color, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '$count',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTopAlpha() {
    final sorted = [..._rekapData]
      ..sort((a, b) => (b['alpha'] as num).compareTo(a['alpha'] as num));
    final top5 = sorted.take(5).toList();

    if (top5.isEmpty || (top5.first['alpha'] as num) == 0) {
      return [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.inputBorder),
          ),
          child: Center(
            child: Text(
              '🎉 Tidak ada santri yang alpha bulan ini!',
              style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 13),
            ),
          ),
        ),
      ];
    }

    return top5.map((item) {
      final alpha = (item['alpha'] as num? ?? 0).toInt();
      final hadir = (item['hadir'] as num? ?? 0).toInt();
      final total = hadir + (item['sakit'] as num? ?? 0).toInt() + (item['izin'] as num? ?? 0).toInt() + alpha;
      final pct = total > 0 ? hadir / total : 0.0;

      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: alpha > 5
                ? AppColors.error.withValues(alpha: 0.5)
                : AppColors.inputBorder,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.error.withValues(alpha: 0.2),
              child: Text(
                (item['nama'] as String? ?? '?').substring(0, 1).toUpperCase(),
                style: GoogleFonts.poppins(
                  color: AppColors.error,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['nama'] ?? '-',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct,
                      minHeight: 5,
                      backgroundColor: Colors.white.withValues(alpha: 0.15),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        pct > 0.8 ? AppColors.success : (pct > 0.5 ? AppColors.warning : AppColors.error),
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Hadir: $hadir hari · Alpha: $alpha hari',
                    style: GoogleFonts.poppins(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$alpha ×',
                style: GoogleFonts.poppins(
                  color: AppColors.error,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  // ── Tab 2: Per Santri ────────────────────────────────────

  Widget _buildPerSantriTab() {
    if (_rekapData.isEmpty) {
      return Center(
        child: Text(
          'Tidak ada data kehadiran bulan ini.',
          style: GoogleFonts.poppins(color: Colors.white70),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: _rekapData.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = _rekapData[index];
        final hadir = (item['hadir'] as num? ?? 0).toInt();
        final sakit = (item['sakit'] as num? ?? 0).toInt();
        final izin = (item['izin'] as num? ?? 0).toInt();
        final alpha = (item['alpha'] as num? ?? 0).toInt();
        final total = hadir + sakit + izin + alpha;
        final hadirPct = total > 0 ? hadir / total : 0.0;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: alpha > 0
                  ? AppColors.error.withValues(alpha: 0.3)
                  : AppColors.inputBorder,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.accent.withValues(alpha: 0.2),
                    child: Text(
                      (item['nama'] as String? ?? '?').substring(0, 1).toUpperCase(),
                      style: GoogleFonts.poppins(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item['nama'] ?? '-',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Text(
                    '${(hadirPct * 100).toStringAsFixed(0)}%',
                    style: GoogleFonts.poppins(
                      color: hadirPct >= 0.8
                          ? AppColors.success
                          : (hadirPct >= 0.5 ? AppColors.warning : AppColors.error),
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: hadirPct,
                  minHeight: 8,
                  backgroundColor: Colors.white.withValues(alpha: 0.12),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    hadirPct >= 0.8
                        ? AppColors.success
                        : (hadirPct >= 0.5 ? AppColors.warning : AppColors.error),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildMiniStat('H', hadir, AppColors.success),
                  _buildMiniStat('S', sakit, AppColors.accent),
                  _buildMiniStat('I', izin, AppColors.info),
                  _buildMiniStat('A', alpha, AppColors.error),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMiniStat(String label, int value, Color color) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.4)),
          ),
          child: Center(
            child: Text(
              '$value',
              style: GoogleFonts.poppins(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.poppins(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ── Helpers ──────────────────────────────────────────────

  String _getBulanNama(int bulan) {
    const bulanList = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
    ];
    return bulanList[bulan];
  }
}
