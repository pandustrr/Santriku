/// Kumpulan string konstan yang digunakan dalam aplikasi
class AppStrings {
  AppStrings._();

  // App
  static const String appName = 'Santriku';
  static const String appTagline = 'Pesantren Digital';

  // Login
  static const String loginTitle = 'Masuk sebagai';
  static const String loginTitleAccent = 'peran Anda';
  static const String loginButton = 'Masuk Sekarang';
  static const String loginFooter = 'Akun dikelola oleh Admin Pesantren';
  static const String rememberMe = 'Ingat saya';
  static const String forgotPassword = 'Lupa password?';

  // Roles
  static const String roleAdmin = 'Admin';
  static const String rolePengurus = 'Pengurus';
  static const String roleWali = 'Wali';

  // Input labels
  static const String emailLabel = 'USERNAME';
  static const String passwordLabel = 'PASSWORD';
  static const String emailHint = 'Masukkan username';
  static const String passwordHint = 'Masukkan password';

  // Validation
  static const String emailRequired = 'Username tidak boleh kosong';
  static const String passwordRequired = 'Password tidak boleh kosong';
  static const String emailInvalid = 'Username tidak valid';
  static const String passwordMinLength = 'Password minimal 6 karakter';
}
