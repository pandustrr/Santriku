import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:santriku_app/main.dart';
import 'package:santriku_app/features/auth/screens/login_screen.dart';
import 'package:santriku_app/features/pengurus/screens/pengurus_dashboard_screen.dart';
import 'package:santriku_app/features/pengurus/screens/daftar_santri_screen.dart';
import 'package:santriku_app/features/wali/screens/wali_dashboard_screen.dart';
import 'package:santriku_app/features/admin/screens/admin_dashboard_screen.dart';

void main() {
  testWidgets('End-to-End Navigation Test for Pengurus Role', (WidgetTester tester) async {
    // Jalankan aplikasi
    await tester.pumpWidget(const SantrikuApp());

    // 1. Verifikasi berada di halaman Login
    expect(find.byType(LoginScreen), findsOneWidget);

    // 2. Isi textfield agar validasi lolos
    final emailField = find.descendant(
      of: find.byType(TextFormField),
      matching: find.textContaining('Email'),
      skipOffstage: false,
    ).first;
    
    // As in standard Flutter test, we can just find by type and index since the UI has labels
    final textFields = find.byType(TextFormField);
    await tester.enterText(textFields.at(0), 'pengurus@santriku.com');
    await tester.enterText(textFields.at(1), 'password123');
    await tester.pump();

    // 3. Tekan tombol Masuk
    final loginButton = find.widgetWithText(ElevatedButton, 'Masuk Sekarang');
    await tester.ensureVisible(loginButton);
    await tester.tap(loginButton);
    
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    // 4. Verifikasi masuk ke PengurusDashboardScreen (karena role default adalah Pengurus)
    expect(find.byType(PengurusDashboardScreen), findsOneWidget);

    // 5. Test navigasi ke Daftar Santri
    // Cari widget dengan teks "Daftar Santri" yang bisa di tap
    final daftarSantriButton = find.text('Santri').first;
    await tester.ensureVisible(daftarSantriButton);
    await tester.tap(daftarSantriButton);
    await tester.pumpAndSettle();

    // Verifikasi berada di halaman Daftar Santri
    expect(find.byType(DaftarSantriScreen), findsOneWidget);

    // 6. Test navigasi kembali
    final backButton = find.byType(BackButton).first;
    await tester.tap(backButton);
    await tester.pumpAndSettle();

    // Verifikasi kembali ke PengurusDashboardScreen
    expect(find.byType(PengurusDashboardScreen), findsOneWidget);

    // 7. Test Logout Flow
    final logoutIcon = find.byIcon(Icons.logout_rounded);
    await tester.ensureVisible(logoutIcon);
    await tester.tap(logoutIcon);
    await tester.pumpAndSettle();

    // Verifikasi popup muncul
    expect(find.text('Apakah Anda yakin ingin keluar dari akun ini?'), findsOneWidget);

    // Tekan tombol Logout di Dialog
    final logoutConfirmButton = find.widgetWithText(ElevatedButton, 'Logout');
    await tester.tap(logoutConfirmButton);
    await tester.pumpAndSettle();

    // 8. Verifikasi kembali ke halaman Login
    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
