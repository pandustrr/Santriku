import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:santriku_app/core/core.dart';

class KelolaPenggunaScreen extends StatefulWidget {
  const KelolaPenggunaScreen({super.key});

  @override
  State<KelolaPenggunaScreen> createState() => _KelolaPenggunaScreenState();
}

class _KelolaPenggunaScreenState extends State<KelolaPenggunaScreen> {
  String _selectedFilter = 'Semua';
  final List<String> _filters = ['Semua', 'Santri', 'Pengurus', 'Wali'];

  final List<Map<String, String>> _users = [
    {'name': 'Ahmad Fauzi', 'role': 'Santri', 'status': 'Aktif'},
    {'name': 'Ust. Hasanuddin', 'role': 'Pengurus', 'status': 'Aktif'},
    {'name': 'Bpk. Budi Santoso', 'role': 'Wali', 'status': 'Nonaktif'},
    {'name': 'Muhammad Fatih', 'role': 'Santri', 'status': 'Aktif'},
    {'name': 'Ibu Siti Aminah', 'role': 'Wali', 'status': 'Aktif'},
  ];

  void _showUserDialog({int? index}) {
    final isEdit = index != null;
    final nameController = TextEditingController(text: isEdit ? _users[index]['name'] : '');
    final passwordController = TextEditingController();
    String selectedRole = isEdit ? _users[index]['role']! : 'Santri';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              backgroundColor: Colors.white,
              title: Text(
                isEdit ? 'Edit Pengguna' : 'Tambah Pengguna',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: AppColors.primaryDark),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      style: GoogleFonts.poppins(fontSize: 14, color: AppColors.primaryDark),
                      decoration: InputDecoration(
                        labelText: 'NAMA LENGKAP',
                        hintText: 'Masukkan nama lengkap',
                        labelStyle: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600),
                        filled: true,
                        fillColor: const Color(0xFFF5F7F6),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: selectedRole,
                      decoration: InputDecoration(
                        labelText: 'ROLE PENGGUNA',
                        labelStyle: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600),
                        filled: true,
                        fillColor: const Color(0xFFF5F7F6),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      items: ['Santri', 'Pengurus', 'Wali'].map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                      onChanged: (v) {
                        if (v != null) setDialogState(() => selectedRole = v);
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      style: GoogleFonts.poppins(fontSize: 14, color: AppColors.primaryDark),
                      decoration: InputDecoration(
                        labelText: 'PASSWORD',
                        hintText: isEdit ? 'Kosongkan jika tidak diubah' : 'Masukkan password',
                        labelStyle: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600),
                        filled: true,
                        fillColor: const Color(0xFFF5F7F6),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Batal', style: GoogleFonts.poppins(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Nama tidak boleh kosong!'), backgroundColor: AppColors.error),
                      );
                      return;
                    }
                    Navigator.pop(context);
                    setState(() {
                      if (isEdit) {
                        _users[index] = {
                          'name': nameController.text.trim(),
                          'role': selectedRole,
                          'status': _users[index]['status']!,
                        };
                      } else {
                        _users.add({
                          'name': nameController.text.trim(),
                          'role': selectedRole,
                          'status': 'Aktif',
                        });
                      }
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isEdit ? 'Pengguna berhasil diperbarui!' : 'Pengguna berhasil ditambahkan!'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Simpan', style: GoogleFonts.poppins(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _toggleUserStatus(int index) {
    setState(() {
      final currentStatus = _users[index]['status'];
      _users[index] = {
        ..._users[index],
        'status': currentStatus == 'Aktif' ? 'Nonaktif' : 'Aktif',
      };
    });
    final newStatus = _users[index]['status'];
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Status ${_users[index]['name']} diubah ke $newStatus'),
        backgroundColor: newStatus == 'Aktif' ? AppColors.success : AppColors.warning,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredUsers = _selectedFilter == 'Semua' 
        ? _users 
        : _users.where((u) => u['role'] == _selectedFilter).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),
      appBar: AppBar(
        title: Text('Kelola Pengguna', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showUserDialog(),
        backgroundColor: AppColors.accent,
        icon: const Icon(Icons.person_add_rounded, color: AppColors.primaryDarker),
        label: Text('Tambah Pengguna', style: GoogleFonts.poppins(color: AppColors.primaryDarker, fontWeight: FontWeight.w600)),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters.map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: isSelected,
                      label: Text(filter, style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                      selectedColor: AppColors.primaryLight,
                      checkmarkColor: AppColors.primaryDark,
                      labelStyle: TextStyle(color: isSelected ? AppColors.primaryDark : Colors.grey[600]),
                      onSelected: (val) {
                        setState(() => _selectedFilter = filter);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: filteredUsers.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final user = filteredUsers[index];
                final isActive = user['status'] == 'Aktif';
                // Find the real index in _users for editing
                final realIndex = _users.indexOf(user);
                return Container(
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
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: isActive ? const Color(0xFFE8F2EF) : const Color(0xFFFDE8E8),
                      child: Icon(
                        Icons.person,
                        color: isActive ? AppColors.primaryDark : AppColors.error,
                      ),
                    ),
                    title: Text(
                      user['name']!,
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.textDark),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F7F6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              user['role']!,
                              style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[700]),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            user['status']!,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: isActive ? AppColors.success : AppColors.error,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    trailing: PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert_rounded),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      onSelected: (val) {
                        if (val == 'edit') {
                          _showUserDialog(index: realIndex);
                        } else {
                          _toggleUserStatus(realIndex);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        PopupMenuItem(value: 'status', child: Text(isActive ? 'Nonaktifkan' : 'Aktifkan')),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
