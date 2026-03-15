import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'data/models/goal.dart';
import 'data/models/meme.dart';
import 'data/models/goal_session.dart';
import 'data/models/taunt_event.dart';
import 'presentation/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive TypeAdapters
  Hive.registerAdapter(GoalStatusAdapter());
  Hive.registerAdapter(GoalAdapter());
  Hive.registerAdapter(MemeAdapter());
  Hive.registerAdapter(GoalSessionAdapter());
  Hive.registerAdapter(TauntEventAdapter());

  runApp(const ProviderScope(child: FocusLockApp()));
}

class FocusLockApp extends StatelessWidget {
  const FocusLockApp({super.key});

  // ─── Design Tokens ────────────────────────────────────
  static const Color bgDeep      = Color(0xFF0F0E2E);
  static const Color bgCard      = Color(0xFF1A1940);
  static const Color bgCardLight = Color(0xFF242352);
  static const Color accent      = Color(0xFF7C83FD);
  static const Color accentSoft  = Color(0xFFB8BBFF);
  static const Color coral       = Color(0xFFFF6B6B);
  static const Color mint        = Color(0xFF6FECB4);
  static const Color amber       = Color(0xFFFFD93D);
  static const Color textPrimary = Color(0xFFF0EFF4);
  static const Color textSecondary = Color(0xFF9896B0);

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.poppinsTextTheme(
      ThemeData.dark().textTheme,
    );

    return MaterialApp(
      title: 'FocusLock',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.dark(
          primary: accent,
          secondary: accentSoft,
          surface: bgCard,
          error: coral,
        ),
        scaffoldBackgroundColor: bgDeep,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: textPrimary,
          elevation: 0,
          centerTitle: true,
        ),
        cardColor: bgCard,
        textTheme: textTheme,
        iconTheme: const IconThemeData(color: accentSoft),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          elevation: 8,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: bgCard,
          selectedItemColor: accent,
          unselectedItemColor: textSecondary,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: bgCardLight,
          contentTextStyle: const TextStyle(color: textPrimary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          behavior: SnackBarBehavior.floating,
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: bgCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          titleTextStyle: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary),
          contentTextStyle: GoogleFonts.poppins(fontSize: 14, color: textSecondary),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: bgCardLight,
          selectedColor: accent,
          labelStyle: GoogleFonts.poppins(fontSize: 13, color: textPrimary),
          side: BorderSide.none,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: bgCardLight,
          hintStyle: TextStyle(color: textSecondary.withAlpha(120)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: accent, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: accent,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            textStyle: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
