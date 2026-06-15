import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:santriku_app/core/core.dart';
import 'package:santriku_app/features/pengurus/services/pengurus_service.dart';

class DetailIzinScreen extends StatefulWidget {
  final Map<String, dynamic> permission;
  const DetailIzinScreen({super.key, required this.permission});

  @override
  State<DetailIzinScreen> createState() => _DetailIzinScreenState();
}

class _DetailIzinScreenState extends State<DetailIzinScreen> {
  bool _isLoading = false;

  String _formatOnlyDate(String? dateStr) {
    if (dateStr == null) return '-';
    try {
      final dt = DateTime.parse(dateStr);
      final months = [
        'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (e) {
      return dateStr;
    }
  }

  Future<void> _updateStatus(String status) async {
    setState(() => _isLoading = true);

    try {
      final result = await PengurusService.updatePermissionStatus(
        widget.permission['id'],
        status,
      );

      if (mounted) {
        setState(() => _isLoading = false);
        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(status == 'Approved'
                  ? 'Izin berhasil disetujui!'
                  : 'Izin berhasil ditolak!'),
              backgroundColor: status == 'Approved' ? Colors.green : Colors.red,
            ),
          );
          Navigator.pop(context, true); // Return true to trigger reload in parent
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final santri = widget.permission['santri'] ?? {};
    final wali = widget.permission['wali'] ?? {};
    final status = widget.permission['status'] ?? 'Pending';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF104A3E),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Detail Izin',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: const Color(0xFF1C6B59),
                            child: Text(
                              (santri['name'] ?? 'S').isNotEmpty
                                  ? santri['name'][0].toUpperCase()
                                  : 'S',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  santri['name'] ?? '-',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1E2925),
                                  ),
                                ),
                                Text(
                                  'NIS: ${santri['nis'] ?? '-'} • Wali: ${wali['name'] ?? '-'}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildDetailRow('Kategori', widget.permission['jenis_izin'] ?? '-'),
                      _buildDetailRow('Tanggal Keluar', _formatOnlyDate(widget.permission['tanggal_mulai'])),
                      _buildDetailRow('Tanggal Kembali', _formatOnlyDate(widget.permission['tanggal_selesai'])),
                      _buildDetailRow('Alasan', widget.permission['alasan'] ?? '-'),
                      
                      const SizedBox(height: 16),
                      Text(
                        'Lampiran / Bukti:',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      widget.permission['bukti_path'] != null
                          ? Container(
                              height: 180,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[300]!),
                                image: DecorationImage(
                                  image: NetworkImage(
                                    widget.permission['bukti_path'].startsWith('http')
                                        ? widget.permission['bukti_path']
                                        : '${ApiConstants.baseUrl}/${widget.permission['bukti_path']}',
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                          : Container(
                              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[200]!),
                              ),
                              child: Column(
                                children: [
                                  Icon(Icons.info_outline, color: Colors.grey[400], size: 36),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tidak ada bukti surat dilampirkan.',
                                    style: GoogleFonts.poppins(
                                      color: Colors.grey[500],
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                      
                      if (status != 'Pending') ...[
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: status == 'Approved'
                                ? Colors.green[50]
                                : Colors.red[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: status == 'Approved'
                                  ? Colors.green[100]!
                                  : Colors.red[100]!,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                status == 'Approved' ? Icons.check_circle : Icons.cancel,
                                color: status == 'Approved' ? Colors.green : Colors.red,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  status == 'Approved'
                                      ? 'Izin ini telah disetujui.'
                                      : 'Izin ini telah ditolak.',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    color: status == 'Approved'
                                        ? Colors.green[800]
                                        : Colors.red[800],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF104A3E),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: status == 'Pending'
          ? Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => _updateStatus('Rejected'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Tolak',
                        style: GoogleFonts.poppins(
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : () => _updateStatus('Approved'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF104A3E),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Setujui',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E2925),
            ),
          ),
        ],
      ),
    );
  }
}
