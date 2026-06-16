import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:santriku_app/core/core.dart';
import 'package:santriku_app/features/admin/admin.dart';

class KelolaPenggunaScreen extends StatefulWidget {
  final String initialFilter;
  const KelolaPenggunaScreen({super.key, this.initialFilter = 'Semua'});

  @override
  State<KelolaPenggunaScreen> createState() => _KelolaPenggunaScreenState();
}

class _KelolaPenggunaScreenState extends State<KelolaPenggunaScreen> {
  late String _selectedFilter;
  final List<String> _filters = ['Semua', 'Santri', 'Pengurus', 'Wali'];
  
  bool _isLoading = true;
  List<Map<String, dynamic>> _mergedUsers = [];
  List<Map<String, dynamic>> _waliList = []; // List of Wali users for dropdown selection

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.initialFilter;
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);

    final rawUsers = await AdminService.getUsers();
    final rawSantris = await AdminService.getSantris();

    final usersMapped = rawUsers.map((u) {
      final roles = List<String>.from(u['roles'] ?? []);
      String displayRole = 'Admin';
      if (roles.contains('pengurus')) displayRole = 'Pengurus';
      if (roles.contains('wali_santri')) displayRole = 'Wali';

      // Find children names linked to this parent
      String childrenNames = '';
      if (displayRole == 'Wali') {
        final childrenList = rawSantris
            .where((s) => s['wali_id'] == u['id'])
            .map((s) => s['name'] ?? '')
            .toList();
        childrenNames = childrenList.isEmpty ? 'Belum terhubung dengan anak' : childrenList.join(', ');
      }

      return {
        'id': u['id'],
        'name': u['name'] ?? '',
        'email': u['email'] ?? '',
        'username': u['username'] ?? '',
        'role': displayRole,
        'children': childrenNames,
        'status': 'Aktif',
        'is_santri': false,
        'raw': u,
      };
    }).toList();

    final santrisMapped = rawSantris.map((s) {
      // Find wali name linked to this child
      final waliObj = s['wali'];
      final String waliName = waliObj != null ? (waliObj['name'] ?? 'Belum terhubung') : 'Belum terhubung';

      return {
        'id': s['id'],
        'name': s['name'] ?? '',
        'nis': s['nis'] ?? '',
        'wali_id': s['wali_id'],
        'wali_name': waliName,
        'qr_token': s['qr_token'] ?? '',
        'role': 'Santri',
        'status': 'Aktif',
        'is_santri': true,
        'raw': s,
      };
    }).toList();

    if (mounted) {
      setState(() {
        _mergedUsers = [...usersMapped, ...santrisMapped];
        _waliList = usersMapped.where((u) => u['role'] == 'Wali').toList();
        _isLoading = false;
      });
    }
  }

  void _showUserDialog({Map<String, dynamic>? item}) {
    final isEdit = item != null;
    final isSantri = isEdit && (item['is_santri'] as bool);

    // Controllers
    final nameController = TextEditingController(text: isEdit ? item['name'] : '');
    final emailController = TextEditingController(text: (isEdit && !isSantri) ? item['email'] : '');
    final usernameController = TextEditingController(text: (isEdit && !isSantri) ? item['username'] : '');
    final passwordController = TextEditingController();

    // Santri specific
    final nisController = TextEditingController(text: (isEdit && isSantri) ? item['nis'] : '');
    final qrController = TextEditingController(text: (isEdit && isSantri) ? item['qr_token'] : '');
    int? selectedWaliId = (isEdit && isSantri) ? item['wali_id'] : null;

    String selectedRole = isEdit ? item['role']! : 'Santri';

    // Auto-generate QR Token when typing NIS
    nisController.addListener(() {
      if (!isEdit && selectedRole == 'Santri') {
        qrController.text = 'santri_${nameController.text.toLowerCase().replaceAll(' ', '_')}_${nisController.text}';
      }
    });

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final isRoleSantri = selectedRole == 'Santri';

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              backgroundColor: Colors.white,
              title: Text(
                isEdit ? 'Edit Pengguna' : 'Tambah Pengguna',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: AppColors.primaryDark),
              ),
              content: SizedBox(
                width: 400,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Role Selector (Only editable on Create)
                      if (!isEdit) ...[
                        DropdownButtonFormField<String>(
                          value: selectedRole,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: 'ROLE PENGGUNA',
                            labelStyle: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primaryDark),
                            filled: true,
                            fillColor: const Color(0xFFF5F7F6),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          items: ['Santri', 'Pengurus', 'Wali'].map((r) => DropdownMenuItem(value: r, child: Text(r, overflow: TextOverflow.ellipsis))).toList(),
                          onChanged: (v) {
                            if (v != null) {
                              setDialogState(() => selectedRole = v);
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                      
                      // Full Name
                      TextField(
                        controller: nameController,
                        style: GoogleFonts.poppins(fontSize: 14, color: AppColors.primaryDark),
                        decoration: InputDecoration(
                          labelText: 'NAMA LENGKAP',
                          hintText: 'Masukkan nama lengkap',
                          labelStyle: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primaryDark),
                          filled: true,
                          fillColor: const Color(0xFFF5F7F6),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                      const SizedBox(height: 16),

                      if (isRoleSantri) ...[
                        // NIS
                        TextField(
                          controller: nisController,
                          keyboardType: TextInputType.number,
                          style: GoogleFonts.poppins(fontSize: 14, color: AppColors.primaryDark),
                          decoration: InputDecoration(
                            labelText: 'NIS (NOMOR INDUK SANTRI)',
                            hintText: 'Masukkan NIS',
                            labelStyle: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primaryDark),
                            filled: true,
                            fillColor: const Color(0xFFF5F7F6),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                        const SizedBox(height: 16),



                        // Wali Dropdown
                        DropdownButtonFormField<int>(
                          value: selectedWaliId,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: 'WALI SANTRI (ORANG TUA)',
                            labelStyle: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primaryDark),
                            filled: true,
                            fillColor: const Color(0xFFF5F7F6),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          items: [
                            const DropdownMenuItem<int>(
                              value: null,
                              child: Text(
                                'Tanpa Wali (Belum terhubung)',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            ..._waliList.map((w) => DropdownMenuItem<int>(
                                  value: w['id'],
                                  child: Text(
                                    w['name']?.toString() ?? '',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                )),
                          ],
                          onChanged: (v) {
                            setDialogState(() => selectedWaliId = v);
                          },
                        ),
                        const SizedBox(height: 16),

                        // QR Token
                        TextField(
                          controller: qrController,
                          style: GoogleFonts.poppins(fontSize: 14, color: AppColors.primaryDark),
                          decoration: InputDecoration(
                            labelText: 'QR TOKEN',
                            hintText: 'Token unik kartu santri',
                            labelStyle: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primaryDark),
                            filled: true,
                            fillColor: const Color(0xFFF5F7F6),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                      ] else ...[
                        // Email
                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: GoogleFonts.poppins(fontSize: 14, color: AppColors.primaryDark),
                          decoration: InputDecoration(
                            labelText: 'EMAIL',
                            hintText: 'Masukkan alamat email',
                            labelStyle: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primaryDark),
                            filled: true,
                            fillColor: const Color(0xFFF5F7F6),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Username
                        TextField(
                          controller: usernameController,
                          style: GoogleFonts.poppins(fontSize: 14, color: AppColors.primaryDark),
                          decoration: InputDecoration(
                            labelText: 'USERNAME',
                            hintText: 'Masukkan username',
                            labelStyle: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primaryDark),
                            filled: true,
                            fillColor: const Color(0xFFF5F7F6),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Password
                        TextField(
                          controller: passwordController,
                          obscureText: true,
                          style: GoogleFonts.poppins(fontSize: 14, color: AppColors.primaryDark),
                          decoration: InputDecoration(
                            labelText: 'PASSWORD',
                            hintText: isEdit ? 'Kosongkan jika tidak diubah' : 'Masukkan password (min. 6 karakter)',
                            labelStyle: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primaryDark),
                            filled: true,
                            fillColor: const Color(0xFFF5F7F6),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Batal', style: GoogleFonts.poppins(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final name = nameController.text.trim();
                    if (name.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Nama tidak boleh kosong!'), backgroundColor: AppColors.error),
                      );
                      return;
                    }

                    Map<String, dynamic> result = {};

                    if (isRoleSantri) {
                      final nis = nisController.text.trim();
                      final qrToken = qrController.text.trim();

                      if (nis.isEmpty || qrToken.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('NIS dan QR Token harus diisi!'), backgroundColor: AppColors.error),
                        );
                        return;
                      }

                      final data = {
                        'name': name,
                        'nis': nis,
                        'wali_id': selectedWaliId,
                        'qr_token': qrToken,
                      };

                      if (isEdit) {
                        result = await AdminService.updateSantri(item['id'], data);
                      } else {
                        result = await AdminService.createSantri(data);
                      }
                    } else {
                      final email = emailController.text.trim();
                      final username = usernameController.text.trim();
                      final password = passwordController.text;

                      if (email.isEmpty || username.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Email dan Username harus diisi!'), backgroundColor: AppColors.error),
                        );
                        return;
                      }

                      if (!isEdit && password.length < 6) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Password minimal 6 karakter!'), backgroundColor: AppColors.error),
                        );
                        return;
                      }

                      final data = {
                        'name': name,
                        'email': email,
                        'username': username,
                        'role': selectedRole == 'Pengurus' ? 'pengurus' : 'wali_santri',
                      };

                      if (password.isNotEmpty) {
                        data['password'] = password;
                      }

                      if (isEdit) {
                        result = await AdminService.updateUser(item['id'], data);
                      } else {
                        result = await AdminService.createUser(data);
                      }
                    }

                    if (context.mounted) {
                      if (result['success'] == true) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(result['message']), backgroundColor: AppColors.success),
                        );
                        _fetchData();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(result['message'] ?? 'Terjadi kesalahan'), backgroundColor: AppColors.error),
                        );
                      }
                    }
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

  void _deleteUser(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Hapus Pengguna', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: AppColors.error)),
        content: Text(
          'Apakah Anda yakin ingin menghapus "${item['name']}"? Tindakan ini tidak dapat dibatalkan.',
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal', style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _isLoading = true);

              Map<String, dynamic> result;
              if (item['is_santri'] as bool) {
                result = await AdminService.deleteSantri(item['id']);
              } else {
                result = await AdminService.deleteUser(item['id']);
              }

              if (mounted) {
                if (result['success']) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(result['message']), backgroundColor: AppColors.success),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(result['message'] ?? 'Gagal menghapus'), backgroundColor: AppColors.error),
                  );
                }
                _fetchData();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Hapus', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredUsers = _selectedFilter == 'Semua'
        ? _mergedUsers
        : _mergedUsers.where((u) => u['role'] == _selectedFilter).toList();

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
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.primaryDark : AppColors.primaryDark.withValues(alpha: 0.6),
                      ),
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
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryDark,
                    ),
                  )
                : filteredUsers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.people_outline_rounded, size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            Text(
                              'Tidak ada pengguna ditemukan',
                              style: GoogleFonts.poppins(color: Colors.grey, fontSize: 16),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _fetchData,
                        color: AppColors.accent,
                        backgroundColor: AppColors.primaryDark,
                        child: ListView.separated(
                          padding: const EdgeInsets.all(20),
                          itemCount: filteredUsers.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final user = filteredUsers[index];
                            final isSantri = user['is_santri'] as bool;
                            final isActive = user['status'] == 'Aktif';

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
                                  backgroundColor: isSantri ? const Color(0xFFE3F2FD) : const Color(0xFFE8F2EF),
                                  child: Icon(
                                    isSantri ? Icons.school_rounded : Icons.person,
                                    color: isSantri ? Colors.blue.shade700 : AppColors.primaryDark,
                                  ),
                                ),
                                title: Text(
                                  user['name']!,
                                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: const Color(0xFF1E2925)),
                                ),
                                 subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFE8F2EF), // visible background
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              user['role']!,
                                              style: GoogleFonts.poppins(
                                                fontSize: 11, 
                                                color: AppColors.primaryDark, // highly visible dark color
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          if (!isSantri) ...[
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
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      if (isSantri)
                                        Text(
                                          'Wali: ${user['wali_name']}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        )
                                      else if (user['role'] == 'Wali')
                                        Text(
                                          'Anak: ${user['children']}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                trailing: PopupMenuButton<String>(
                                  icon: const Icon(
                                    Icons.more_vert_rounded,
                                    color: AppColors.primaryDark,
                                    size: 24,
                                  ),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  onSelected: (val) {
                                    if (val == 'edit') {
                                      _showUserDialog(item: user);
                                    } else if (val == 'delete') {
                                      _deleteUser(user);
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                                    const PopupMenuItem(
                                      value: 'delete', 
                                      child: Text('Hapus', style: TextStyle(color: AppColors.error)),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
