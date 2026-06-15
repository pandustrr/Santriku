import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:santriku_app/core/constants/app_strings.dart';
import 'package:santriku_app/core/models/user_role.dart';
import 'package:santriku_app/core/theme/app_colors.dart';
import 'package:santriku_app/features/auth/widgets/app_logo.dart';
import 'package:santriku_app/features/auth/widgets/custom_text_field.dart';
import 'package:santriku_app/features/auth/widgets/role_selector.dart';
import 'package:santriku_app/features/admin/admin.dart';
import 'package:santriku_app/features/pengurus/pengurus.dart';
import 'package:santriku_app/features/wali/wali.dart';
import 'package:santriku_app/features/auth/services/auth_service.dart';

/// Halaman login aplikasi Santriku.
///
/// Menampilkan form login dengan pemilihan role,
/// input email/NIP, password, dan opsi "Ingat saya".
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  // ── Form ────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // ── State ───────────────────────────────────────────────
  UserRole _selectedRole = UserRole.pengurus;
  bool _obscurePassword = true;
  bool _rememberMe = true;
  bool _isLoading = false;

  // ── Animation ───────────────────────────────────────────
  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  // ── Lifecycle ───────────────────────────────────────────

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );

    _emailController.text = _selectedRole.usernamePlaceholder;
    _passwordController.text = '123456';

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ── Actions ─────────────────────────────────────────────

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await AuthService.login(
      _emailController.text,
      _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success']) {
      final user = result['user'] as Map<String, dynamic>;
      final List<dynamic> roles = user['roles'] ?? [];
      
      // Validasi apakah role yang dikembalikan cocok dengan pilihan role di UI
      String mappedRole = _selectedRole.name;
      if (mappedRole == 'wali') mappedRole = 'wali_santri';

      if (!roles.contains(mappedRole)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Anda tidak memiliki akses sebagai ${_selectedRole.fullName}!',
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        AuthService.logout();
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Login berhasil sebagai ${_selectedRole.fullName}!',
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      // Navigasi sesuai dengan role yang dipilih
      late final Widget dashboard;
      switch (_selectedRole) {
        case UserRole.admin:
          dashboard = const AdminDashboardScreen();
          break;
        case UserRole.pengurus:
          dashboard = const PengurusDashboardScreen();
          break;
        case UserRole.wali:
          dashboard = const WaliDashboardScreen();
          break;
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => dashboard),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['message'] ?? 'Login gagal!',
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  // ── Build ───────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      const AppLogo(size: 48),
                      const SizedBox(height: 36),
                      _buildTitle(),
                      const SizedBox(height: 28),
                      _buildRoleSelector(),
                      const SizedBox(height: 24),
                      _buildEmailField(),
                      const SizedBox(height: 16),
                      _buildPasswordField(),
                      const SizedBox(height: 14),
                      _buildRememberForgot(),
                      const SizedBox(height: 40),
                      _buildLoginButton(),
                      const SizedBox(height: 20),
                      _buildFooter(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  ),
);
  }

  // ── Section Builders ────────────────────────────────────

  /// Judul "Masuk sebagai / peran Anda"
  Widget _buildTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.loginTitle,
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            height: 1.2,
          ),
        ),
        Text(
          AppStrings.loginTitleAccent,
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppColors.accent,
            height: 1.2,
          ),
        ),
      ],
    );
  }

  /// Tab pemilih role (Admin / Pengurus / Wali)
  Widget _buildRoleSelector() {
    return RoleSelector(
      selectedRole: _selectedRole,
      onRoleChanged: (role) {
        setState(() {
          _selectedRole = role;
          _emailController.text = role.usernamePlaceholder;
          _passwordController.text = '123456';
        });
      },
    );
  }

  /// Field input username
  Widget _buildEmailField() {
    return CustomTextField(
      label: AppStrings.emailLabel,
      hintText: _selectedRole.usernamePlaceholder,
      controller: _emailController,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      validator: (value) {
        if (value == null || value.isEmpty) return AppStrings.emailRequired;
        return null;
      },
    );
  }

  /// Field input password
  Widget _buildPasswordField() {
    return CustomTextField(
      label: AppStrings.passwordLabel,
      hintText: AppStrings.passwordHint,
      controller: _passwordController,
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => _handleLogin(),
      suffixIcon: IconButton(
        icon: Icon(
          _obscurePassword
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          color: AppColors.textSecondary,
          size: 22,
        ),
        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return AppStrings.passwordRequired;
        if (value.length < 6) return AppStrings.passwordMinLength;
        return null;
      },
    );
  }

  /// Baris "Ingat saya" + "Lupa password?"
  Widget _buildRememberForgot() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Checkbox "Ingat saya"
        GestureDetector(
          onTap: () => setState(() => _rememberMe = !_rememberMe),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: _rememberMe ? AppColors.accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: _rememberMe
                        ? AppColors.accent
                        : AppColors.textSecondary,
                    width: 2,
                  ),
                ),
                child: _rememberMe
                    ? const Icon(
                        Icons.check,
                        size: 16,
                        color: AppColors.primaryDarker,
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Text(
                AppStrings.rememberMe,
                style: GoogleFonts.poppins(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        // Link "Lupa password?"
        GestureDetector(
          onTap: () {
            // TODO: Navigasi ke halaman lupa password
          },
          child: Text(
            AppStrings.forgotPassword,
            style: GoogleFonts.poppins(
              color: AppColors.accent,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  /// Tombol "Masuk Sekarang"
  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.primaryDarker,
          disabledBackgroundColor: AppColors.accentDark.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.primaryDarker,
                ),
              )
            : Text(
                AppStrings.loginButton,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }

  /// Footer "Akun dikelola oleh Admin Pesantren"
  Widget _buildFooter() {
    return Center(
      child: Text(
        AppStrings.loginFooter,
        style: GoogleFonts.poppins(
          color: AppColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
