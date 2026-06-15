import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:santriku_app/core/core.dart';

/// Halaman Riwayat & Status Izin yang diajukan oleh Wali Santri.
class RiwayatIzinWaliScreen extends StatelessWidget {
  const RiwayatIzinWaliScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7F6),
        appBar: AppBar(
          backgroundColor: AppColors.primaryDark,
          foregroundColor: Colors.white,
          elevation: 0,
          title: Text(
            'Riwayat Izin Saya',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          bottom: TabBar(
            labelColor: AppColors.accent,
            unselectedLabelColor: Colors.white70,
            indicatorColor: AppColors.accent,
            labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
            tabs: const [
              Tab(text: 'Menunggu'),
              Tab(text: 'Disetujui'),
              Tab(text: 'Ditolak'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _IzinWaliList(status: 'Menunggu'),
            _IzinWaliList(status: 'Disetujui'),
            _IzinWaliList(status: 'Ditolak'),
          ],
        ),
      ),
    );
  }
}

class _IzinWaliList extends StatelessWidget {
  final String status;
  const _IzinWaliList({required this.status});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> dummyData = _getDummyData(status);

    if (dummyData.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_rounded, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'Belum ada izin $status',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: dummyData.length,
      itemBuilder: (context, index) {
        final item = dummyData[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _getStatusColor(status).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getStatusIcon(status),
                color: _getStatusColor(status),
                size: 22,
              ),
            ),
            title: Text(
              item['santri']!,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: const Color(0xFF1E2925),
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Alasan: ${item['alasan']}',
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${item['tglMulai']} - ${item['tglSelesai']}',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            trailing: _buildStatusChip(status),
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: _getStatusColor(status),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Menunggu':
        return AppColors.warning;
      case 'Disetujui':
        return AppColors.success;
      case 'Ditolak':
        return AppColors.error;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Menunggu':
        return Icons.hourglass_top_rounded;
      case 'Disetujui':
        return Icons.check_circle_outline_rounded;
      case 'Ditolak':
        return Icons.cancel_outlined;
      default:
        return Icons.help_outline;
    }
  }

  List<Map<String, String>> _getDummyData(String status) {
    switch (status) {
      case 'Menunggu':
        return [
          {
            'santri': 'Muhammad Fatih',
            'alasan': 'Acara keluarga',
            'tglMulai': '15 Jun 2026',
            'tglSelesai': '17 Jun 2026',
          },
        ];
      case 'Disetujui':
        return [
          {
            'santri': 'Muhammad Fatih',
            'alasan': 'Sakit demam',
            'tglMulai': '5 Jun 2026',
            'tglSelesai': '7 Jun 2026',
          },
          {
            'santri': 'Aisyah',
            'alasan': 'Kontrol dokter',
            'tglMulai': '1 Jun 2026',
            'tglSelesai': '1 Jun 2026',
          },
        ];
      case 'Ditolak':
        return [
          {
            'santri': 'Muhammad Fatih',
            'alasan': 'Jalan-jalan',
            'tglMulai': '10 May 2026',
            'tglSelesai': '12 May 2026',
          },
        ];
      default:
        return [];
    }
  }
}
