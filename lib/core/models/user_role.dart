/// Enum role pengguna dalam sistem Santriku.
///
/// Digunakan untuk menentukan hak akses dan tampilan
/// berdasarkan peran pengguna di pondok pesantren.
enum UserRole {
  admin,
  pengurus,
  wali;

  /// Nama tampilan role dalam bahasa Indonesia.
  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.pengurus:
        return 'Pengurus';
      case UserRole.wali:
        return 'Wali';
    }
  }

  /// Nama lengkap role untuk pesan/notifikasi.
  String get fullName {
    switch (this) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.pengurus:
        return 'Pengurus';
      case UserRole.wali:
        return 'Wali Santri';
    }
  }

  /// Contoh placeholder username berdasarkan role.
  String get usernamePlaceholder {
    switch (this) {
      case UserRole.admin:
        return 'admin';
      case UserRole.pengurus:
        return 'pengurus';
      case UserRole.wali:
        return 'wali';
    }
  }
}
