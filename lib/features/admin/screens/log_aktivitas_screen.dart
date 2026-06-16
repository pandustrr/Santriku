import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:santriku_app/core/core.dart';
import 'package:santriku_app/features/auth/services/auth_service.dart';

class LogAktivitasScreen extends StatefulWidget {
  const LogAktivitasScreen({super.key});

  @override
  State<LogAktivitasScreen> createState() => _LogAktivitasScreenState();
}

class _LogAktivitasScreenState extends State<LogAktivitasScreen> {
  DateTime? _selectedDate;
  bool _isLoading = true;
  List<Map<String, dynamic>> _logs = [];
  Timer? _timer;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchLogs();
    // Realtime: polling setiap 15 detik
    _timer = Timer.periodic(const Duration(seconds: 15), (_) => _fetchLogs(silent: true));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchLogs({bool silent = false}) async {
    if (!silent && mounted) setState(() => _isLoading = true);

    try {
      final dateParam = _selectedDate != null
          ? '?date=${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}'
          : '';

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/admin/activity-logs$dateParam'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${AuthService.token}',
        },
      );

      if (mounted) {
        if (response.statusCode == 200) {
          final body = jsonDecode(response.body);
          final List<dynamic> list = body is List ? body : (body['data'] ?? []);
          final newLogs = list.map((e) => Map<String, dynamic>.from(e)).toList();
          
          setState(() {
            _logs = newLogs;
            _isLoading = false;
          });
        } else {
          if (!silent) {
            setState(() {
              _isLoading = false;
            });
          }
        }
      }
    } catch (e) {
      if (mounted && !silent) {
        setState(() {
          _isLoading = false;
          // Jika gagal, tampilkan data dummy untuk demo
          _logs = _getDummyLogs();
        });
      } else if (mounted && silent && _logs.isEmpty) {
        setState(() => _logs = _getDummyLogs());
      }
    }
  }

  List<Map<String, dynamic>> _getDummyLogs() {
    final now = DateTime.now();
    return [
      {
        'type': 'login',
        'user': 'Ust. Ahmad',
        'description': 'Login sebagai Pengurus',
        'created_at': now.subtract(const Duration(minutes: 5)).toIso8601String(),
      },
      {
        'type': 'attendance',
        'user': 'Ust. Budi',
        'description': 'Mencatat kehadiran: Ahmad Fauzi - Hadir',
        'created_at': now.subtract(const Duration(minutes: 15)).toIso8601String(),
      },
      {
        'type': 'consumption',
        'user': 'Ust. Budi',
        'description': 'Mencatat konsumsi: Muhammad Ali - Sarapan',
        'created_at': now.subtract(const Duration(minutes: 30)).toIso8601String(),
      },
      {
        'type': 'permission',
        'user': 'Ust. Ahmad',
        'description': 'Menyetujui izin: Bilal Hasan - Sakit',
        'created_at': now.subtract(const Duration(hours: 1)).toIso8601String(),
      },
      {
        'type': 'user_create',
        'user': 'Admin',
        'description': 'Menambahkan santri baru: Zaid Mustafa',
        'created_at': now.subtract(const Duration(hours: 2)).toIso8601String(),
      },
    ];
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
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
      setState(() => _selectedDate = picked);
      _fetchLogs();
    }
  }

  String _formatTime(String? dateStr) {
    if (dateStr == null) return '--:--';
    try {
      final dt = DateTime.parse(dateStr).toLocal();
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return '$h:$m';
    } catch (_) {
      return '--:--';
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '-';
    try {
      final dt = DateTime.parse(dateStr).toLocal();
      final months = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
      ];
      return '${dt.day} ${months[dt.month]}';
    } catch (_) {
      return '-';
    }
  }

  IconData _getIcon(String? type) {
    switch (type) {
      case 'login':
        return Icons.login_rounded;
      case 'logout':
        return Icons.logout_rounded;
      case 'attendance':
        return Icons.how_to_reg_rounded;
      case 'consumption':
        return Icons.restaurant_rounded;
      case 'permission':
        return Icons.assignment_turned_in_rounded;
      case 'user_create':
      case 'user_update':
        return Icons.manage_accounts_rounded;
      case 'user_delete':
        return Icons.person_remove_rounded;
      default:
        return Icons.notifications_active_rounded;
    }
  }

  Color _getColor(String? type) {
    switch (type) {
      case 'login':
      case 'logout':
        return AppColors.info;
      case 'attendance':
        return AppColors.success;
      case 'consumption':
        return AppColors.accent;
      case 'permission':
        return const Color(0xFF2A8B72);
      case 'user_create':
        return AppColors.success;
      case 'user_delete':
        return AppColors.error;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),
      appBar: AppBar(
        title: Text('Log Aktivitas Sistem',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        actions: [
          // Indikator realtime
          Container(
            margin: const EdgeInsets.only(right: 4),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4CAF50),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'LIVE',
                  style: GoogleFonts.poppins(
                      color: const Color(0xFF4CAF50),
                      fontSize: 11,
                      fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: _fetchLogs,
          ),
          IconButton(
            icon: const Icon(Icons.date_range_rounded, color: Colors.white),
            onPressed: _pickDate,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter tanggal aktif
          if (_selectedDate != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.filter_alt_rounded,
                          color: AppColors.primaryDark, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Filter: ${_selectedDate!.day}-${_selectedDate!.month}-${_selectedDate!.year}',
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryDark),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () {
                      setState(() => _selectedDate = null);
                      _fetchLogs();
                    },
                    child: const Icon(Icons.close_rounded,
                        color: AppColors.error, size: 20),
                  ),
                ],
              ),
            ),

          // Keterangan polling
          Container(
            color: AppColors.primaryDark.withValues(alpha: 0.05),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.update_rounded,
                    size: 14, color: AppColors.primaryDark),
                const SizedBox(width: 6),
                Text(
                  'Diperbarui otomatis setiap 15 detik',
                  style: GoogleFonts.poppins(
                      fontSize: 11, color: AppColors.primaryDark),
                ),
              ],
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primaryDark))
                : _logs.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.history_rounded,
                                size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            Text(
                              'Tidak ada log aktivitas',
                              style:
                                  GoogleFonts.poppins(color: Colors.grey, fontSize: 16),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _fetchLogs,
                        color: AppColors.accent,
                        child: ListView.builder(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(20),
                          itemCount: _logs.length,
                          itemBuilder: (context, index) {
                            final log = _logs[index];
                            final type = log['type']?.toString();
                            final color = _getColor(type);
                            final desc =
                                log['description']?.toString() ??
                                log['detail']?.toString() ??
                                '-';
                            final actor =
                                log['user']?.toString() ??
                                log['operator_name']?.toString() ??
                                '-';
                            final timeStr = log['created_at']?.toString() ??
                                log['time']?.toString();

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.02),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                leading: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(_getIcon(type),
                                      color: color, size: 22),
                                ),
                                title: Text(
                                  actor,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: const Color(0xFF1E2925),
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    desc,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: const Color(0xFF6B7280),
                                    ),
                                  ),
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      _formatTime(timeStr),
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primaryDark,
                                      ),
                                    ),
                                    Text(
                                      _formatDate(timeStr),
                                      style: GoogleFonts.poppins(
                                        fontSize: 10,
                                        color: AppColors.textHint,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
<<<<<<< HEAD
                    ),
                    trailing: Text(
                      '${10 + index}:20',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[500],
                      ),
                    ),
                  ),
                );
              },
            ),
=======
>>>>>>> e71c638dd9843a9acc3567b77b5e7f3da8fbb551
          ),
        ],
      ),
    );
  }
}
