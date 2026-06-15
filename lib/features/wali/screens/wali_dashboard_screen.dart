import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:santriku_app/core/core.dart';
import 'package:santriku_app/features/wali/screens/pengajuan_izin_screen.dart';
import 'package:santriku_app/features/wali/screens/detail_santri_screen.dart';
import 'package:santriku_app/features/wali/screens/riwayat_izin_wali_screen.dart';
import 'package:santriku_app/features/wali/services/wali_service.dart';
import 'package:santriku_app/features/auth/screens/login_screen.dart';
import 'package:santriku_app/features/auth/services/auth_service.dart';

/// Halaman Dashboard utama untuk role Wali Santri.
class WaliDashboardScreen extends StatefulWidget {
  const WaliDashboardScreen({super.key});

  @override
  State<WaliDashboardScreen> createState() => _WaliDashboardScreenState();
}

class _WaliDashboardScreenState extends State<WaliDashboardScreen> {
  bool _isLoadingSantris = true;
  bool _isLoadingData = false;
  List<Map<String, dynamic>> _santriList = [];
  Map<String, dynamic>? _selectedSantri;
  Map<String, dynamic>? _dashboardData;

  @override
  void initState() {
    super.initState();
    _fetchSantris();
  }

  Future<void> _fetchSantris() async {
    setState(() {
      _isLoadingSantris = true;
    });
    final list = await WaliService.getSantris();
    if (mounted) {
      setState(() {
        _santriList = list;
        _isLoadingSantris = false;
        if (list.isNotEmpty) {
          _selectedSantri = list.first;
        }
      });
      if (_selectedSantri != null) {
        _fetchDashboardData();
      }
    }
  }

  Future<void> _fetchDashboardData() async {
    if (_selectedSantri == null) return;
    setState(() {
      _isLoadingData = true;
    });
    final res = await WaliService.getDashboardStats(_selectedSantri!['id']);
    if (mounted) {
      setState(() {
        if (res['success'] == true) {
          _dashboardData = res['data'];
        } else {
          _dashboardData = null;
        }
        _isLoadingData = false;
      });
    }
  }

  Future<void> _handleRefresh() async {
    if (_selectedSantri == null) {
      await _fetchSantris();
    } else {
      await _fetchDashboardData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Wali'),
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.accent),
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: _isLoadingSantris
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.accent),
                )
              : _santriList.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline, size: 64, color: AppColors.textHint.withValues(alpha: 0.5)),
                          const SizedBox(height: 16),
                          Text(
                            'Tidak ada data santri terhubung',
                            style: GoogleFonts.poppins(
                              color: AppColors.textSecondary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _fetchSantris,
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
                            child: Text(
                              'Coba Lagi',
                              style: GoogleFonts.poppins(color: AppColors.primaryDarker),
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _handleRefresh,
                      color: AppColors.accent,
                      backgroundColor: AppColors.primaryDark,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(),
                            const SizedBox(height: 20),
                            _buildChildSelector(),
                            const SizedBox(height: 24),
                            _buildSantriProfileCard(context),
                            const SizedBox(height: 28),
                            _buildSectionTitle('Status Hari Ini'),
                            const SizedBox(height: 16),
                            _buildStatusGrid(context),
                            const SizedBox(height: 28),
                            _buildQuickActions(context),
                            const SizedBox(height: 32),
                            _buildSectionTitle('Aktivitas Santri'),
                            const SizedBox(height: 16),
                            _buildSantriActivities(context),
                          ],
                        ),
                      ),
                    ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final parentName = AuthService.currentUser?['name'] ?? 'Wali Santri';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selamat Datang,',
          style: GoogleFonts.poppins(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        Text(
          parentName,
          style: GoogleFonts.poppins(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildChildSelector() {
    if (_santriList.length <= 1) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PILIH ANAK',
          style: GoogleFonts.poppins(
            color: AppColors.textSecondary.withValues(alpha: 0.8),
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 42,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _santriList.length,
            itemBuilder: (context, index) {
              final child = _santriList[index];
              final isSelected = _selectedSantri?['id'] == child['id'];
              return GestureDetector(
                onTap: () {
                  if (isSelected) return;
                  setState(() {
                    _selectedSantri = child;
                  });
                  _fetchDashboardData();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.accent : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppColors.accent : AppColors.inputBorder,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.accent.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            )
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      child['name'] ?? '-',
                      style: GoogleFonts.poppins(
                        color: isSelected ? AppColors.primaryDarker : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSantriProfileCard(BuildContext context) {
    if (_selectedSantri == null) return const SizedBox.shrink();
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DetailSantriScreen(santri: _selectedSantri!),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.accent,
                  child: Icon(Icons.person_rounded, color: AppColors.primaryDarker, size: 36),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedSantri!['name'] ?? '-',
                        style: GoogleFonts.poppins(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'NIS: ${_selectedSantri!['nis'] ?? '-'}',
                        style: GoogleFonts.poppins(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusGrid(BuildContext context) {
    if (_isLoadingData || _dashboardData == null) {
      return GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 12,
        childAspectRatio: 0.9,
        children: List.generate(3, (index) => _buildSkeletonItem()),
      );
    }

    final absensi = _dashboardData!['absensi_status'] ?? 'Belum Absen';
    final izin = _dashboardData!['izin_status'] ?? 'Tidak Izin';
    
    final consumption = _dashboardData!['consumption'] as Map<String, dynamic>? ?? {};
    int claimCount = 0;
    if (consumption['sarapan'] == 'Sukses') claimCount++;
    if (consumption['siang'] == 'Sukses') claimCount++;
    if (consumption['malam'] == 'Sukses') claimCount++;
    final makan = "$claimCount / 3 Makan";

    Color absensiColor = absensi == 'Hadir' ? AppColors.success : (absensi == 'Belum Absen' ? AppColors.warning : AppColors.error);
    Color izinColor = izin == 'Tidak Izin' ? AppColors.info : AppColors.warning;

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      childAspectRatio: 0.9,
      children: [
        _buildStatusItem(context, 'Absensi', absensi, Icons.check_circle_rounded, absensiColor),
        _buildStatusItem(context, 'Makan Harian', makan, Icons.restaurant_rounded, AppColors.accent),
        _buildStatusItem(context, 'Perizinan', izin, Icons.verified_user_rounded, izinColor),
      ],
    );
  }

  Widget _buildSkeletonItem() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accent),
        ),
      ),
    );
  }

  Widget _buildStatusItem(BuildContext context, String title, String value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Status $title hari ini: $value')),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    if (_selectedSantri == null) return const SizedBox.shrink();
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => PengajuanIzinScreen(
                    santriList: _santriList,
                    initialSantriId: _selectedSantri!['id'],
                  ),
                ),
              );
              if (result == true) {
                _fetchDashboardData();
              }
            },
            icon: const Icon(Icons.add_moderator_rounded, size: 22),
            label: const Text('Ajukan Izin Santri'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.primaryDarker,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => RiwayatIzinWaliScreen(
                  santriId: _selectedSantri!['id'],
                  santriList: _santriList,
                ),
              ),
            ),
            icon: const Icon(Icons.history_rounded, size: 22),
            label: const Text('Riwayat & Status Izin'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.accent,
              side: const BorderSide(color: AppColors.accent, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        color: AppColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildSantriActivities(BuildContext context) {
    if (_isLoadingData || _dashboardData == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
      );
    }

    final List<dynamic> activities = _dashboardData!['activities'] ?? [];

    if (activities.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.inputBorder),
        ),
        child: Column(
          children: [
            Icon(Icons.history_rounded, size: 40, color: AppColors.textHint.withValues(alpha: 0.5)),
            const SizedBox(height: 12),
            Text(
              'Belum ada aktivitas hari ini',
              style: GoogleFonts.poppins(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: activities.map<Widget>((act) {
        final type = act['type'] ?? 'attendance';
        final title = act['title'] ?? '-';
        final detail = act['detail'] ?? '-';
        final time = act['time'] ?? '-';
        
        final IconData icon = type == 'consumption'
            ? Icons.restaurant_rounded
            : Icons.check_circle_outline_rounded;
            
        final Color iconColor = type == 'consumption'
            ? AppColors.accent
            : AppColors.success;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.inputBorder),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            title: Text(
              title,
              style: GoogleFonts.poppins(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            subtitle: Text(
              detail,
              style: GoogleFonts.poppins(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            trailing: Text(
              "$time WIB",
              style: GoogleFonts.poppins(
                color: AppColors.textHint,
                fontSize: 11,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Logout', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        content: Text(
          'Apakah Anda yakin ingin keluar dari akun ini?',
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal', style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Logout', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
