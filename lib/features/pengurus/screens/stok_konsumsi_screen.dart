import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:santriku_app/core/core.dart';
import 'package:santriku_app/features/pengurus/services/pengurus_service.dart';

class StokKonsumsiScreen extends StatefulWidget {
  const StokKonsumsiScreen({super.key});

  @override
  State<StokKonsumsiScreen> createState() => _StokKonsumsiScreenState();
}

class _StokKonsumsiScreenState extends State<StokKonsumsiScreen> {
  Map<String, dynamic>? _data;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await PengurusService.getConsumptionStats();
      if (mounted) {
        if (result['success']) {
          setState(() {
            _data = result['data'];
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = result['message'];
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Kesalahan saat memuat data: $e';
          _isLoading = false;
        });
      }
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '-';
    try {
      final dt = DateTime.parse(dateStr);
      final days = ['', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
      final months = [
        'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
      ];
      return '${days[dt.weekday]}, ${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (e) {
      return dateStr;
    }
  }

  void _showUpdateQuotaDialog() {
    String selectedMeal = 'Siang';
    final TextEditingController portionController = TextEditingController();
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(
                'Atur Kuota Porsi',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: const Color(0xFF104A3E)),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pilih Jadwal Makan:',
                    style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedMeal,
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem(value: 'Sarapan', child: Text('Sarapan')),
                          DropdownMenuItem(value: 'Siang', child: Text('Makan Siang')),
                          DropdownMenuItem(value: 'Malam', child: Text('Makan Malam')),
                        ],
                        onChanged: isSaving
                            ? null
                            : (val) {
                                if (val != null) {
                                  setDialogState(() => selectedMeal = val);
                                }
                              },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Jumlah Kuota Porsi:',
                    style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: portionController,
                    keyboardType: TextInputType.number,
                    enabled: !isSaving,
                    decoration: InputDecoration(
                      hintText: 'Masukkan jumlah porsi harian',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF104A3E), width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.pop(context),
                  child: Text('Batal', style: GoogleFonts.poppins(color: Colors.grey[600], fontWeight: FontWeight.w600)),
                ),
                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          final int? portion = int.tryParse(portionController.text);
                          if (portion == null || portion <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Jumlah porsi harus berupa angka lebih besar dari 0'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          final scaffoldMessenger = ScaffoldMessenger.of(context);
                          final navigator = Navigator.of(context);

                          setDialogState(() => isSaving = true);
                          try {
                            final res = await PengurusService.updateConsumptionQuota(selectedMeal, portion);
                            if (mounted) {
                              setDialogState(() => isSaving = false);
                              if (res['success']) {
                                navigator.pop();
                                scaffoldMessenger.showSnackBar(
                                  SnackBar(
                                    content: Text('Kuota porsi $selectedMeal berhasil diperbarui!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                _fetchStats();
                              } else {
                                scaffoldMessenger.showSnackBar(
                                  SnackBar(
                                    content: Text(res['message']),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          } catch (e) {
                            if (mounted) {
                              setDialogState(() => isSaving = false);
                              scaffoldMessenger.showSnackBar(
                                SnackBar(
                                  content: Text('Terjadi kesalahan: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF104A3E),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text('Simpan', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateRaw = _data?['date_raw'];
    final statsList = (_data?['stats'] as List<dynamic>?) ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF104A3E),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Manajemen Stok Makanan',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      body: _isLoading && _data == null
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF104A3E),
              ),
            )
          : _errorMessage != null && _data == null
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
                          onPressed: _fetchStats,
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
              : RefreshIndicator(
                  onRefresh: _fetchStats,
                  color: const Color(0xFF104A3E),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    children: [
                      Text(
                        'Hari ini, ${_formatDate(dateRaw)}',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1E2925),
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (statsList.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            child: Text(
                              'Tidak ada data statistik makan hari ini.',
                              style: GoogleFonts.poppins(color: Colors.grey[600]),
                            ),
                          ),
                        )
                      else
                        ...statsList.map((stat) {
                          final title = stat['title'] ?? '-';
                          final time = stat['time'] ?? '-';
                          final total = stat['total'] ?? 0;
                          final taken = stat['taken'] ?? 0;
                          final isDone = stat['is_done'] ?? false;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: _buildStokCard(
                              title: title,
                              time: time,
                              totalPortions: total,
                              taken: taken,
                              isDone: isDone,
                            ),
                          );
                        }),
                    ],
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showUpdateQuotaDialog,
        backgroundColor: AppColors.accent,
        icon: const Icon(Icons.edit, color: Colors.white),
        label: Text(
          'Atur Kuota',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildStokCard({
    required String title,
    required String time,
    required int totalPortions,
    required int taken,
    required bool isDone,
  }) {
    final progress = totalPortions > 0 ? (taken / totalPortions) : 0.0;
    final int remaining = totalPortions - taken;
    
    return Container(
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDone ? Colors.grey[100] : const Color(0xFFE8F2EF),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.restaurant,
                      color: isDone ? Colors.grey : const Color(0xFF2A8B72),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1E2925),
                        ),
                      ),
                      Text(
                        time,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (isDone)
                Chip(
                  label: Text(
                    'Selesai',
                    style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[700]),
                  ),
                  backgroundColor: Colors.grey[200],
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                )
              else
                Chip(
                  label: Text(
                    'Berjalan',
                    style: GoogleFonts.poppins(fontSize: 11, color: Colors.white),
                  ),
                  backgroundColor: const Color(0xFF2A8B72),
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Terambil: $taken / $totalPortions Porsi',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                'Sisa: $remaining Porsi',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: remaining > 0 ? const Color(0xFF2A8B72) : Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress > 1.0 ? 1.0 : progress,
              minHeight: 8,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                isDone ? Colors.grey : const Color(0xFF2A8B72),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
