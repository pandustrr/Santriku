import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:santriku_app/core/core.dart';
import 'package:santriku_app/features/wali/services/wali_service.dart';

/// Halaman Riwayat & Status Izin yang diajukan oleh Wali Santri.
class RiwayatIzinWaliScreen extends StatefulWidget {
  final int santriId;
  final List<Map<String, dynamic>> santriList;

  const RiwayatIzinWaliScreen({
    super.key,
    required this.santriId,
    required this.santriList,
  });

  @override
  State<RiwayatIzinWaliScreen> createState() => _RiwayatIzinWaliScreenState();
}

class _RiwayatIzinWaliScreenState extends State<RiwayatIzinWaliScreen> {
  late int _selectedSantriId;
  List<Map<String, dynamic>> _permissions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedSantriId = widget.santriId;
    _fetchPermissions();
  }

  Future<void> _fetchPermissions() async {
    setState(() => _isLoading = true);
    final list = await WaliService.getPermissions(_selectedSantriId);
    if (mounted) {
      setState(() {
        _permissions = list;
        _isLoading = false;
      });
    }
  }

  String _formatDateStr(String? dateStr) {
    if (dateStr == null) return '-';
    final parts = dateStr.split('-');
    if (parts.length == 3) {
      final year = parts[0];
      final month = parts[1];
      final day = parts[2];
      
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
      ];
      final mIdx = int.tryParse(month);
      if (mIdx != null && mIdx >= 1 && mIdx <= 12) {
        return "$day ${months[mIdx - 1]} $year";
      }
    }
    return dateStr;
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

  Widget _buildChildSelector() {
    if (widget.santriList.length <= 1) return const SizedBox.shrink();
    return Container(
      color: AppColors.primaryDark,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'PILIH SANTRI:',
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
          DropdownButton<int>(
            value: _selectedSantriId,
            dropdownColor: AppColors.primaryDark,
            icon: const Icon(Icons.arrow_drop_down, color: AppColors.accent),
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
            underline: Container(height: 1.5, color: AppColors.accent),
            items: widget.santriList.map((santri) {
              return DropdownMenuItem<int>(
                value: santri['id'] as int,
                child: Text(santri['name'] ?? ''),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null && val != _selectedSantriId) {
                setState(() {
                  _selectedSantriId = val;
                });
                _fetchPermissions();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionList(String tabStatus) {
    final String dbStatus = tabStatus == 'Menunggu'
        ? 'Pending'
        : (tabStatus == 'Disetujui' ? 'Approved' : 'Rejected');

    final filtered = _permissions.where((p) => p['status'] == dbStatus).toList();

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.accent));
    }

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_rounded, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'Belum ada izin $tabStatus',
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

    return RefreshIndicator(
      onRefresh: _fetchPermissions,
      color: AppColors.accent,
      backgroundColor: AppColors.primaryDark,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          final item = filtered[index];
          final tglMulai = _formatDateStr(item['tanggal_mulai']);
          final tglSelesai = _formatDateStr(item['tanggal_selesai']);
          
          final santriObj = widget.santriList.firstWhere(
            (s) => s['id'] == item['santri_id'],
            orElse: () => <String, dynamic>{},
          );
          final santriName = santriObj['name'] ?? 'Santri';

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
                  color: _getStatusColor(tabStatus).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getStatusIcon(tabStatus),
                  color: _getStatusColor(tabStatus),
                  size: 22,
                ),
              ),
              title: Text(
                santriName,
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
                      'Jenis: ${item['jenis_izin']}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Alasan: ${item['alasan']}',
                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$tglMulai - $tglSelesai',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              trailing: _buildStatusChip(tabStatus),
            ),
          );
        },
      ),
    );
  }

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
            'Riwayat Izin Santri',
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
        body: Column(
          children: [
            _buildChildSelector(),
            Expanded(
              child: TabBarView(
                children: [
                  _buildPermissionList('Menunggu'),
                  _buildPermissionList('Disetujui'),
                  _buildPermissionList('Ditolak'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
