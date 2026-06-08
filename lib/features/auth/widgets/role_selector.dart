import 'package:flutter/material.dart';
import 'package:santriku_app/core/models/user_role.dart';
import 'package:santriku_app/core/theme/app_colors.dart';

/// Widget pemilih role pengguna dengan gaya tab.
///
/// Menampilkan tiga opsi role (Admin, Pengurus, Wali)
/// dengan ikon dan animasi perpindahan yang halus.
class RoleSelector extends StatelessWidget {
  final UserRole selectedRole;
  final ValueChanged<UserRole> onRoleChanged;

  const RoleSelector({
    super.key,
    required this.selectedRole,
    required this.onRoleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.inputBorder),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: UserRole.values.map(_buildRoleTab).toList(),
      ),
    );
  }

  /// Membangun satu tab role.
  Widget _buildRoleTab(UserRole role) {
    final isSelected = selectedRole == role;

    return Expanded(
      child: GestureDetector(
        onTap: () => onRoleChanged(role),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryDark : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(
                    color: AppColors.accent.withValues(alpha: 0.5),
                    width: 1.5,
                  )
                : null,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primaryDarker.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ikon role
              AnimatedScale(
                duration: const Duration(milliseconds: 200),
                scale: isSelected ? 1.1 : 1.0,
                child: Icon(
                  _iconFor(role),
                  color: isSelected ? AppColors.accent : AppColors.textSecondary,
                  size: 26,
                ),
              ),

              const SizedBox(height: 6),

              // Label role
              Text(
                role.displayName,
                style: TextStyle(
                  color: isSelected
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Mengembalikan ikon yang sesuai untuk setiap role.
  IconData _iconFor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Icons.admin_panel_settings_outlined;
      case UserRole.pengurus:
        return Icons.people_alt_outlined;
      case UserRole.wali:
        return Icons.favorite_outline;
    }
  }
}
