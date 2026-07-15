import 'package:flutter/material.dart';

import 'screens/auth_gate.dart';

/// ことのは文庫 アプリ本体。
class KotonohaApp extends StatelessWidget {
  const KotonohaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF6D4C2F),
      surface: const Color(0xFFFBF6EC),
    );
    return MaterialApp(
      title: 'ことのは文庫',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        scaffoldBackgroundColor: const Color(0xFFFBF6EC),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFFFBF6EC),
          foregroundColor: scheme.onSurface,
          elevation: 0,
          centerTitle: true,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            textStyle: const TextStyle(fontSize: 16),
          ),
        ),
      ),
      home: const AuthGate(),
    );
  }
}
