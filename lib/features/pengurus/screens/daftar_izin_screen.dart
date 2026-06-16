import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:santriku_app/core/core.dart';
import 'package:santriku_app/features/pengurus/services/pengurus_service.dart';
import 'detail_izin_screen.dart';

class DaftarIzinScreen extends StatefulWidget {
  const DaftarIzinScreen({super.key});

  @override
  State<DaftarIzinScreen> createState() => _DaftarIzinScreenState();
}

class _DaftarIzinScreenState extends State<DaftarIzinScreen> {
  List<Map<String, dynamic>> _permissions = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchPermissions();
  }

  Future<void> _fetchPermissions() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final data = await PengurusService.getPermissions();
      if (mounted) {
        setState(() {
          _permissions = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Gagal mengambil data perizinan';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7F6),
        appBar: AppBar(
          backgroundColor: const Color(0xFF104A3E),
          foregroundColor: Colors.white,
          elevation: 0,
          title: Text(
            'Daftar Izin',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          bottom: TabBar(
            labelColor: AppColors.accent,
            unselectedLabelColor: Colors.white70,
            indicatorColor: AppColors.accent,
            tabs: const [
              Tab(text: 'Menunggu'),
              Tab(text: 'Disetujui'),
              Tab(text: 'Ditolak'),
            ],
          ),
        ),
        body: _isLoading && _permissions.isEmpty
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF104A3E),
                ),
              )
            : _errorMessage != null && _permissions.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, color: Colors.red[300], size: 48),
                          const SizedBox(height: 16),
                          Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(color: Colors.grey[700]),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _fetchPermissions,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF104A3E),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    ),
                  )
                : TabBarView(
                    children: [
                      _IzinList(
                        permissions: _permissions.where((p) => p['status'] == 'Pending').toList(),
                        onRefresh: _fetchPermissions,
                      ),
                      _IzinList(
                        permissions: _permissions.where((p) => p['status'] == 'Approved').toList(),
                        onRefresh: _fetchPermissions,
                      ),
                      _IzinList(
                        permissions: _permissions.where((p) => p['status'] == 'Rejected').toList(),
                        onRefresh: _fetchPermissions,
                      ),
                    ],
                  ),
      ),
    );
  }
}

class _IzinList extends StatelessWidget {
  final List<Map<String, dynamic>> permissions;
  final Future<void> Function() onRefresh;

  const _IzinList({
    required this.permissions,
    required this.onRefresh,
  });

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '-';
    try {
      final dt = DateTime.parse(dateStr).toLocal();
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}, ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (permissions.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        color: const Color(0xFF104A3E),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.25),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_turned_in_outlined, color: Colors.grey[400], size: 64),
                  const SizedBox(height: 16),
                  Text(
                    'Tidak ada pengajuan perizinan',
                    style: GoogleFonts.poppins(
                      color: Colors.grey[600],
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tarik ke bawah untuk memuat ulang',
                    style: GoogleFonts.poppins(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: const Color(0xFF104A3E),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: permissions.length,
        itemBuilder: (context, index) {
          final item = permissions[index];
          final santri = item['santri'] ?? {};
          final status = item['status'] ?? 'Pending';
          final jenisIzin = item['jenis_izin'] ?? '-';
          final alasan = item['alasan'] ?? '-';
          final createdAt = item['created_at'];

          return Card(
            color: Colors.white,
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.black.withValues(alpha: 0.05)),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailIzinScreen(permission: item),
                  ),
                );
                if (result == true) {
                  onRefresh();
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color(0xFF1C6B59),
                      child: Text(
                        (santri['name'] ?? 'S').isNotEmpty
                            ? santri['name'][0].toUpperCase()
                            : 'S',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  santri['name'] ?? '-',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF1E2925),
                                    fontSize: 15,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: jenisIzin == 'Sakit'
                                      ? Colors.amber[50]
                                      : Colors.blue[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: jenisIzin == 'Sakit'
                                        ? Colors.amber[200]!
                                        : Colors.blue[200]!,
                                  ),
                                ),
                                child: Text(
                                  jenisIzin,
                                  style: GoogleFonts.poppins(
                                    color: jenisIzin == 'Sakit'
                                        ? Colors.amber[800]
                                        : Colors.blue[800],
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Alasan: $alasan',
                            style: GoogleFonts.poppins(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Diajukan: ${_formatDate(createdAt)}',
                            style: GoogleFonts.poppins(
                              color: Colors.grey[400],
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (status == 'Pending')
                      ElevatedButton(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailIzinScreen(permission: item),
                            ),
                          );
                          if (result == true) {
                            onRefresh();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF104A3E),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                          minimumSize: const Size(60, 32),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Tinjau',
                          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      )
                    else
                      Chip(
                        label: Text(
                          status == 'Approved' ? 'Disetujui' : 'Ditolak',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: status == 'Approved' ? Colors.green[800] : Colors.red[800],
                          ),
                        ),
                        backgroundColor: status == 'Approved' ? Colors.green[50] : Colors.red[50],
                        side: BorderSide.none,
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
