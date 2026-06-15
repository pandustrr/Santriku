import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:santriku_app/core/core.dart';
import 'detail_izin_screen.dart';

class DaftarIzinScreen extends StatelessWidget {
  const DaftarIzinScreen({super.key});

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
        body: const TabBarView(
          children: [
            _IzinList(status: 'Menunggu'),
            _IzinList(status: 'Disetujui'),
            _IzinList(status: 'Ditolak'),
          ],
        ),
      ),
    );
  }
}

class _IzinList extends StatelessWidget {
  final String status;
  const _IzinList({required this.status});

  @override
  Widget build(BuildContext context) {
    // Dummy data
    final itemCount = status == 'Menunggu' ? 12 : (status == 'Disetujui' ? 5 : 2);
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Card(
          color: Colors.white,
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.black.withValues(alpha: 0.05)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF1C6B59),
              child: Text(
                'S',
                style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(
              'Santri ${index + 1}',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E2925),
              ),
            ),
            subtitle: Text(
              'Alasan: Pulang\nDiajukan: ${index + 1} jam lalu',
              style: GoogleFonts.poppins(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            trailing: status == 'Menunggu'
                ? ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DetailIzinScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF104A3E),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Tinjau'),
                  )
                : Chip(
                    label: Text(
                      status,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: status == 'Disetujui' ? Colors.green[800] : Colors.red[800],
                      ),
                    ),
                    backgroundColor: status == 'Disetujui' ? Colors.green[50] : Colors.red[50],
                    side: BorderSide.none,
                  ),
          ),
        );
      },
    );
  }
}
