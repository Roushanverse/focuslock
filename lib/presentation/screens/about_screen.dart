import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../main.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        physics: const BouncingScrollPhysics(),
        children: [
          const SizedBox(height: 20),

          // Logo
          Center(
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [FocusLockApp.accent, Color(0xFF5B5FDB)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: FocusLockApp.accent.withAlpha(50),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(Icons.lock_rounded,
                  color: Colors.white, size: 40),
            ),
          ),
          const SizedBox(height: 20),

          Center(
            child: Text(
              'FocusLock',
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: FocusLockApp.textPrimary,
              ),
            ),
          ),
          Center(
            child: Text(
              'Version 1.0.0',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: FocusLockApp.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Description
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: FocusLockApp.bgCard,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: FocusLockApp.bgCardLight.withAlpha(80),
              ),
            ),
            child: Text(
              'FocusLock helps you stay focused by blocking distracting apps during your focus sessions. '
              'Set goals, block temptations, and build discipline — one session at a time.\n\n'
              'With custom taunts across 6 categories, FocusLock keeps you accountable with humor, '
              'motivation, and sometimes a little tough love. 💪',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: FocusLockApp.textPrimary.withAlpha(200),
                height: 1.7,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Features
          _featureItem('🎯', 'Goal-based focus sessions'),
          _featureItem('🛡️', 'App blocking via accessibility service'),
          _featureItem('😈', '84+ taunts across 6 categories'),
          _featureItem('📊', 'Focus statistics & analytics'),
          _featureItem('🔔', 'Smart notifications'),
          _featureItem('🌙', 'Beautiful dark theme'),
          const SizedBox(height: 32),

          // Footer
          Center(
            child: Text(
              'Made with 💜 for productivity',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: FocusLockApp.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              '© 2026 FocusLock',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: FocusLockApp.textSecondary.withAlpha(100),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _featureItem(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: FocusLockApp.textPrimary.withAlpha(200),
            ),
          ),
        ],
      ),
    );
  }
}
