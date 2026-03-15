import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/providers/providers.dart';
import '../../main.dart';
import 'home_screen.dart';

/// Beautiful splash screen with gradient animation and fade-in logo.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  String _statusMessage = 'Initializing...';
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _scaleAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutBack),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
    _initialize();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    try {
      setState(() => _statusMessage = 'Loading memes...');
      final memeService = ref.read(memeServiceProvider);
      await memeService.initialize();

      setState(() => _statusMessage = 'Setting up notifications...');
      final notifService = ref.read(notificationServiceProvider);
      await notifService.initialize();

      setState(() => _statusMessage = 'Setting up background tasks...');
      final wmService = ref.read(workManagerServiceProvider);
      await wmService.initialize();
      await wmService.registerPeriodicCheck();

      setState(() => _statusMessage = 'Checking goals...');
      final checkGoals = ref.read(checkGoalsUseCaseProvider);
      await checkGoals.execute();

      final blockingService = ref.read(blockingServiceProvider);
      blockingService.startListening();

      await Future.delayed(const Duration(milliseconds: 800));

      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const HomeScreen(),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    } catch (e) {
      setState(() => _statusMessage = 'Error: $e');
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F0E2E),
              Color(0xFF1A1940),
              Color(0xFF12113A),
              Color(0xFF0F0E2E),
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: ScaleTransition(
              scale: _scaleAnim,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo with soft glow
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          FocusLockApp.accent,
                          Color(0xFF5B5FDB),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: FocusLockApp.accent.withAlpha(60),
                          blurRadius: 40,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.lock_rounded,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // App name
                  Text(
                    'FocusLock',
                    style: GoogleFonts.poppins(
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      color: FocusLockApp.textPrimary,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Tagline
                  Text(
                    'Stay focused. Stay peaceful.',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: FocusLockApp.textSecondary,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const SizedBox(height: 50),

                  // Animated loading indicator
                  AnimatedBuilder(
                    animation: _pulseAnim,
                    builder: (_, __) => Opacity(
                      opacity: _pulseAnim.value,
                      child: SizedBox(
                        width: 36,
                        height: 36,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(
                            FocusLockApp.accent.withAlpha(180),
                          ),
                          strokeWidth: 2.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Status
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      _statusMessage,
                      key: ValueKey(_statusMessage),
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: FocusLockApp.textSecondary.withAlpha(150),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
