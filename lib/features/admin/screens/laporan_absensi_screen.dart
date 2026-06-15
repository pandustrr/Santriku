import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:santriku_app/core/core.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:santriku_app/features/admin/services/admin_service.dart';

class LaporanAbsensiScreen extends StatefulWidget {
  const LaporanAbsensiScreen({super.key});

  @override
  State<LaporanAbsensiScreen> createState() => _LaporanAbsensiScreenState();
}

class _LaporanAbsensiScreenState extends State<LaporanAbsensiScreen> {
  DateTime _selectedMonth = DateTime.now();
  bool _isExporting = false;
  bool _isLoading = true;
  List<Map<String, dynamic>> _rekapData = [];

  @override
  void initState() {
    super.initState();
    _fetchReport();
  }

  Future<void> _fetchReport() async {
    setState(() => _isLoading = true);
    final data = await AdminService.getAttendanceReport(
        _selectedMonth.month, _selectedMonth.year);
    if (mounted) {
      setState(() {
        _rekapData = data;
        _isLoading = false;
      });
    }
  }

  String _getBulanNama(int bulan) {
    const list = [
      '',
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
    ];
    return list[bulan];
  }

  Future<void> _pickMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2025),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.accent,
              onPrimary: AppColors.primaryDarker,
              surface: AppColors.primaryDark,
              onSurface: Colors.white,
              secondaryContainer: AppColors.accent.withValues(alpha: 0.3),
              onSecondaryContainer: Colors.white,
              surfaceVariant: AppColors.primaryDarker,
              onSurfaceVariant: Colors.white,
              outline: AppColors.accent.withValues(alpha: 0.5),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.accent,
                textStyle: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedMonth = picked;
      });
      _fetchReport();
    }
  }

  Future<void> _exportToExcel() async {
    setState(() => _isExporting = true);

    try {
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Rekap Absensi'];
      excel.setDefaultSheet('Rekap Absensi');

      sheetObject.appendRow([
        TextCellValue('Nama Santri'),
        TextCellValue('Hadir'),
        TextCellValue('Sakit'),
        TextCellValue('Izin'),
        TextCellValue('Alpha'),
      ]);

      for (var row in _rekapData) {
        sheetObject.appendRow([
          TextCellValue(row['nama'].toString()),
          IntCellValue(row['hadir']),
          IntCellValue(row['sakit']),
          IntCellValue(row['izin']),
          IntCellValue(row['alpha']),
        ]);
      }

      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      final String filePath =
          '${directory?.path}/Rekap_Absensi_${_selectedMonth.month}_${_selectedMonth.year}.xlsx';
      final fileBytes = excel.save();

      if (fileBytes != null) {
        File(filePath)
          ..createSync(recursive: true)
          ..writeAsBytesSync(fileBytes);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Laporan berhasil diexport ke:\n$filePath'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengekspor data: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  // ── Tabel Absensi ─────────────────────────────────────────────────────────
  //
  // FIX FINAL: Tidak menggunakan scroll horizontal sama sekali.
  //
  // Masalah utama dengan approach sebelumnya:
  //   - SingleChildScrollView(horizontal) selalu memberikan UNCONSTRAINED HEIGHT
  //     ke child-nya — tidak bisa diselesaikan dengan LayoutBuilder karena
  //     maxHeight dari LayoutBuilder bisa menjadi infinity dalam kondisi tertentu
  //     (terutama di Flutter Web), menyebabkan SizedBox(height: infinity) crash.
  //
  // Solusi yang benar:
  //   Gunakan Column sederhana tanpa scroll horizontal.
  //   Kolom nama menggunakan Expanded (fleksibel), kolom H/S/I/A menggunakan
  //   lebar tetap kecil. Semua data muat di layar tanpa horizontal scroll.
  //   Vertikal scroll ditangani ListView.builder yang bounded oleh Expanded.
  //
  Widget _buildTable() {
    // Lebar tetap kolom angka
    const double wNum = 48.0;

    // ── Header ──────────────────────────────────
    Widget buildHeader() => Container(
          color: AppColors.primaryLight,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Nama — fleksibel mengisi sisa lebar
              Expanded(
                child: Text(
                  'Nama Santri',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              _headerCell('H', AppColors.success, wNum),
              _headerCell('S', AppColors.accentLight, wNum),
              _headerCell('I', AppColors.info, wNum),
              _headerCell('A', AppColors.error, wNum),
            ],
          ),
        );

    // ── Baris data ───────────────────────────────
    Widget buildRow(Map<String, dynamic> data, int index) {
      final int alpha = (data['alpha'] ?? 0) as int;
      final int hadir = (data['hadir'] ?? 0) as int;
      final int sakit = (data['sakit'] ?? 0) as int;
      final int izin = (data['izin'] ?? 0) as int;
      final bool isAlpha = alpha > 0;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        color: index.isEven ? Colors.white : const Color(0xFFF9FAFB),
        child: Row(
          children: [
            // Nama — fleksibel, ellipsis jika terlalu panjang
            Expanded(
              child: Text(
                data['nama'] ?? '-',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1E2925),
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            _dataCell('$hadir', wNum, color: AppColors.success, bold: true),
            _dataCell('$sakit', wNum),
            _dataCell('$izin', wNum),
            _dataCell(
              '$alpha',
              wNum,
              color: isAlpha ? AppColors.error : const Color(0xFF6B7280),
              bold: isAlpha,
            ),
          ],
        ),
      );
    }

    // ── Layout: Column + ListView (TIDAK ada nested scroll) ─────────
    return Column(
      children: [
        buildHeader(),
        const Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),
        // Expanded memberi bounded height → ListView.builder aman
        Expanded(
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: _rekapData.length,
            separatorBuilder: (_, __) => const Divider(
              height: 1,
              thickness: 1,
              color: Color(0xFFE5E7EB),
            ),
            itemBuilder: (_, i) => buildRow(_rekapData[i], i),
          ),
        ),
      ],
    );
  }

  Widget _headerCell(String label, Color color, double width) {
    return SizedBox(
      width: width,
      child: Center(
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ),
    );
  }

  Widget _dataCell(String text, double width,
      {Color? color, bool bold = false}) {
    return SizedBox(
      width: width,
      child: Center(
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
            color: color ?? const Color(0xFF374151),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),
      appBar: AppBar(
        title: Text('Laporan Absensi',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
      ),
      body: Column(
        children: [
          // ── Filter bulan ─────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Bulan Laporan',
                          style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: const Color(0xFF6B7280))),
                      const SizedBox(height: 2),
                      Text(
                        '${_getBulanNama(_selectedMonth.month)} ${_selectedMonth.year}',
                        style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1E2925)),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _pickMonth,
                  icon: const Icon(Icons.calendar_month_rounded, size: 18),
                  label: Text('Pilih',
                      style:
                          GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE8F2EF),
                    foregroundColor: AppColors.primaryDark,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),

          // ── Konten tabel ─────────────────────────────
          // Expanded ini memberi bounded height ke _buildTable(),
          // sehingga ListView.builder di dalamnya selalu punya constraint.
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.accent))
                : _rekapData.isEmpty
                    ? Center(
                        child: Text(
                          'Tidak ada data laporan untuk bulan ini',
                          style: GoogleFonts.poppins(
                              color: AppColors.textSecondary),
                        ),
                      )
                    : _buildTable(),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            )
          ],
        ),
        child: ElevatedButton.icon(
            onPressed: _isExporting ? null : _exportToExcel,
            icon: _isExporting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.file_download_rounded),
            label: Text(
              _isExporting ? 'Mengekspor...' : 'Export ke Excel',
              style: GoogleFonts.poppins(
                  fontSize: 16, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
              foregroundColor: Colors.white,
              // Size.fromHeight: tinggi tetap 56, lebar mengikuti parent (bounded)
              // TIDAK memakai SizedBox(width: infinity) karena bisa crash
              // jika parent memberikan unconstrained width.
              minimumSize: const Size.fromHeight(56),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
          ),
      ),
    );
  }
}
