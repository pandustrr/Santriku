import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:santriku_app/core/core.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';

class LaporanAbsensiScreen extends StatefulWidget {
  const LaporanAbsensiScreen({super.key});

  @override
  State<LaporanAbsensiScreen> createState() => _LaporanAbsensiScreenState();
}

class _LaporanAbsensiScreenState extends State<LaporanAbsensiScreen> {
  DateTime _selectedMonth = DateTime.now();
  bool _isExporting = false;

  final List<Map<String, dynamic>> _rekapData = [
    {'nama': 'Muhammad Fatih', 'hadir': 28, 'sakit': 1, 'izin': 1, 'alpha': 0},
    {'nama': 'Aisyah', 'hadir': 30, 'sakit': 0, 'izin': 0, 'alpha': 0},
    {'nama': 'Ahmad Fauzi', 'hadir': 25, 'sakit': 2, 'izin': 3, 'alpha': 0},
    {'nama': 'Budi Santoso', 'hadir': 20, 'sakit': 5, 'izin': 2, 'alpha': 3},
    {'nama': 'Siti Aminah', 'hadir': 29, 'sakit': 1, 'izin': 0, 'alpha': 0},
  ];

  Future<void> _pickMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2025),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryDark,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
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
    }
  }

  Future<void> _exportToExcel() async {
    setState(() => _isExporting = true);
    
    try {
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Rekap Absensi'];
      excel.setDefaultSheet('Rekap Absensi');

      // Tambahkan header
      sheetObject.appendRow([
        TextCellValue('Nama Santri'),
        TextCellValue('Hadir'),
        TextCellValue('Sakit'),
        TextCellValue('Izin'),
        TextCellValue('Alpha'),
      ]);

      // Isi data
      for (var row in _rekapData) {
        sheetObject.appendRow([
          TextCellValue(row['nama'].toString()),
          IntCellValue(row['hadir']),
          IntCellValue(row['sakit']),
          IntCellValue(row['izin']),
          IntCellValue(row['alpha']),
        ]);
      }

      // Ambil path dokumen HP/Emulator
      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      final String filePath = '${directory?.path}/Rekap_Absensi_${_selectedMonth.month}_${_selectedMonth.year}.xlsx';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),
      appBar: AppBar(
        title: Text('Laporan Absensi', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Bulan Laporan', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF6B7280))),
                      const SizedBox(height: 4),
                      Text(
                        '${_selectedMonth.month} - ${_selectedMonth.year}',
                        style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF1E2925)),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _pickMonth,
                  icon: const Icon(Icons.calendar_month_rounded, size: 18),
                  label: Text('Pilih', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE8F2EF),
                    foregroundColor: AppColors.primaryDark,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(AppColors.primaryLight),
                  dataRowColor: WidgetStateProperty.all(Colors.white),
                  columnSpacing: 24,
                  columns: [
                    DataColumn(label: Text('Nama Santri', style: GoogleFonts.poppins(fontWeight: FontWeight.w600))),
                    DataColumn(label: Text('H', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.success))),
                    DataColumn(label: Text('S', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.accent))),
                    DataColumn(label: Text('I', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.info))),
                    DataColumn(label: Text('A', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.error))),
                  ],
                  rows: _rekapData.map((data) {
                    return DataRow(
                      cells: [
                        DataCell(Text(data['nama'], style: GoogleFonts.poppins(fontWeight: FontWeight.w500))),
                        DataCell(Text(data['hadir'].toString(), style: GoogleFonts.poppins(fontWeight: FontWeight.w600))),
                        DataCell(Text(data['sakit'].toString(), style: GoogleFonts.poppins())),
                        DataCell(Text(data['izin'].toString(), style: GoogleFonts.poppins())),
                        DataCell(Text(data['alpha'].toString(), style: GoogleFonts.poppins(color: data['alpha'] > 0 ? AppColors.error : null))),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -4))],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: _isExporting ? null : _exportToExcel,
            icon: _isExporting 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.file_download_rounded),
            label: Text(_isExporting ? 'Mengekspor...' : 'Export ke Excel', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
      ),
    );
  }
}
