import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:santriku_app/core/theme/app_theme.dart';
import 'package:santriku_app/features/auth/screens/login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );

  // Lock orientation to portrait
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const SantrikuApp());
}

class SantrikuApp extends StatelessWidget {
  const SantrikuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Santriku - Pesantren Digital',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const LoginScreen(),
    );
  }
}
