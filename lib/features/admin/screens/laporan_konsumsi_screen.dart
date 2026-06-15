import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart';
import 'package:santriku_app/core/core.dart';
import 'package:santriku_app/features/auth/services/auth_service.dart';
import 'package:universal_html/html.dart' as html;
import 'package:open_file_plus/open_file_plus.dart';

class LaporanKonsumsiScreen extends StatefulWidget {
  const LaporanKonsumsiScreen({super.key});

  @override
  State<LaporanKonsumsiScreen> createState() => _LaporanKonsumsiScreenState();
}

class _LaporanKonsumsiScreenState extends State<LaporanKonsumsiScreen> {
  DateTime _selectedMonth = DateTime.now();
  bool _isLoading = true;
  bool _isExporting = false;
  List<Map<String, dynamic>> _reportData = [];
  Map<String, dynamic>? _summaryData;

  @override
  void initState() {
    super.initState();
    _fetchReport();
  }

  String _getBulanNama(int bulan) {
    const list = [
      '',
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
    ];
    return list[bulan];
  }

  Future<void> _fetchReport() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse(
          '${ApiConstants.baseUrl}/admin/consumption-report?month=${_selectedMonth.month}&year=${_selectedMonth.year}',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${AuthService.token}',
        },
      );
      if (mounted) {
        if (response.statusCode == 200) {
          final body = jsonDecode(response.body);
          setState(() {
            _reportData = body is List
                ? List<Map<String, dynamic>>.from(body)
                : List<Map<String, dynamic>>.from(body['data'] ?? []);
            _summaryData = body is Map ? body['summary'] : null;
            _isLoading = false;
          });
        } else {
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
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
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedMonth = picked);
      _fetchReport();
    }
  }

  Future<void> _exportToExcel() async {
    setState(() => _isExporting = true);
    try {
      var excel = Excel.createExcel();
      Sheet sheet = excel['Laporan Konsumsi'];
      excel.setDefaultSheet('Laporan Konsumsi');

      sheet.appendRow([
        TextCellValue('Nama Santri'),
        TextCellValue('Sarapan'),
        TextCellValue('Makan Siang'),
        TextCellValue('Makan Malam'),
        TextCellValue('Total'),
      ]);

      for (var row in _reportData) {
        final sarapan = (row['sarapan'] as num?)?.toInt() ?? 0;
        final siang = (row['siang'] as num?)?.toInt() ?? 0;
        final malam = (row['malam'] as num?)?.toInt() ?? 0;
        sheet.appendRow([
          TextCellValue(row['nama']?.toString() ?? '-'),
          IntCellValue(sarapan),
          IntCellValue(siang),
          IntCellValue(malam),
          IntCellValue(sarapan + siang + malam),
        ]);
      }

      final fileBytes = excel.save();
      if (fileBytes == null) throw 'Gagal membuat file Excel';

      final fileName = 'Laporan_Konsumsi_${_selectedMonth.month}_${_selectedMonth.year}.xlsx';

      if (kIsWeb) {
        final content = base64Encode(fileBytes);
        html.AnchorElement(
            href: "data:application/octet-stream;charset=utf-16le;base64,$content")
          ..setAttribute("download", fileName)
          ..click();

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Berhasil diunduh!'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        Directory? directory;
        try {
          if (defaultTargetPlatform == TargetPlatform.android) {
            directory = await getExternalStorageDirectory();
            if (directory != null) {
              final parts = directory.path.split('/');
              final idx = parts.indexOf('Android');
              if (idx > 0) {
                directory = Directory('${parts.sublist(0, idx).join('/')}/Download');
                if (!await directory.exists()) {
                  await directory.create(recursive: true);
                }
              }
            }
          }
        } catch (_) {
          directory = null;
        }
        directory ??= await getApplicationDocumentsDirectory();

        final filePath = '${directory.path}/$fileName';
        await File(filePath).create(recursive: true);
        await File(filePath).writeAsBytes(fileBytes);

        // Langsung buka
        await OpenFile.open(filePath);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    '✅ Berhasil diunduh! Ketuk untuk buka.',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    OpenFile.open(filePath);
                  },
                  child: const Text(
                    'BUKA',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal export: $e'), backgroundColor: AppColors.error),
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
        title: Text('Laporan Konsumsi',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter bulan
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
                          style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF6B7280))),
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

          // Ringkasan kalau ada
          if (_summaryData != null) ...[
            Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryDark,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryItem('Sarapan', _summaryData!['total_sarapan'] ?? 0, AppColors.accent),
                  _buildSummaryItem('Siang', _summaryData!['total_siang'] ?? 0, AppColors.info),
                  _buildSummaryItem('Malam', _summaryData!['total_malam'] ?? 0, AppColors.success),
                ],
              ),
            ),
          ],

          // Tabel
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
                : _reportData.isEmpty
                    ? Center(
                        child: Text(
                          'Tidak ada data konsumsi bulan ini',
                          style: GoogleFonts.poppins(color: Colors.grey),
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
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: _isExporting ? null : _exportToExcel,
          icon: _isExporting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.file_download_rounded),
          label: Text(
            _isExporting ? 'Mengekspor...' : 'Export ke Excel',
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryDark,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, dynamic count, Color color) {
    return Column(
      children: [
        Text(
          '$count',
          style: GoogleFonts.poppins(
              color: color, fontSize: 22, fontWeight: FontWeight.w800),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(color: Colors.white60, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildTable() {
    const double wNum = 52.0;
    return Column(
      children: [
        Container(
          color: AppColors.primaryLight,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Text('Nama Santri',
                    style: GoogleFonts.poppins(
                        fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
              _headerCell('Srp', AppColors.accent, wNum),
              _headerCell('Sng', AppColors.info, wNum),
              _headerCell('Mlm', AppColors.success, wNum),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFE5E7EB)),
        Expanded(
          child: ListView.separated(
            itemCount: _reportData.length,
            separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFE5E7EB)),
            itemBuilder: (_, i) {
              final row = _reportData[i];
              final sarapan = (row['sarapan'] as num?)?.toInt() ?? 0;
              final siang = (row['siang'] as num?)?.toInt() ?? 0;
              final malam = (row['malam'] as num?)?.toInt() ?? 0;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                color: i.isEven ? Colors.white : const Color(0xFFF9FAFB),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        row['nama'] ?? '-',
                        style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF1E2925)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _dataCell('$sarapan', wNum, AppColors.accent),
                    _dataCell('$siang', wNum, AppColors.info),
                    _dataCell('$malam', wNum, AppColors.success),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _headerCell(String label, Color color, double width) {
    return SizedBox(
      width: width,
      child: Center(
        child: Text(label,
            style: GoogleFonts.poppins(
                fontSize: 12, fontWeight: FontWeight.w700, color: color)),
      ),
    );
  }

  Widget _dataCell(String text, double width, Color? color) {
    return SizedBox(
      width: width,
      child: Center(
        child: Text(text,
            style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color ?? const Color(0xFF374151))),
      ),
    );
  }
}
