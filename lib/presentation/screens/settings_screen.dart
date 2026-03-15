import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/providers/providers.dart';
import '../../main.dart';
import 'about_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  // ─── Popular Apps Quick-Add ──────────────
  static const List<Map<String, dynamic>> _popularApps = [
    {'name': 'Instagram', 'pkg': 'com.instagram.android', 'icon': '📸'},
    {'name': 'YouTube', 'pkg': 'com.google.android.youtube', 'icon': '▶️'},
    {'name': 'WhatsApp', 'pkg': 'com.whatsapp', 'icon': '💬'},
    {'name': 'Facebook', 'pkg': 'com.facebook.katana', 'icon': '👤'},
    {'name': 'Twitter / X', 'pkg': 'com.twitter.android', 'icon': '🐦'},
    {'name': 'TikTok', 'pkg': 'com.zhiliaoapp.musically', 'icon': '🎵'},
    {'name': 'Snapchat', 'pkg': 'com.snapchat.android', 'icon': '👻'},
    {'name': 'Reddit', 'pkg': 'com.reddit.frontpage', 'icon': '🔴'},
    {'name': 'Discord', 'pkg': 'com.discord', 'icon': '🎮'},
    {'name': 'Spotify', 'pkg': 'com.spotify.music', 'icon': '🎧'},
    {'name': 'Pinterest', 'pkg': 'com.pinterest', 'icon': '📌'},
    {'name': 'LinkedIn', 'pkg': 'com.linkedin.android', 'icon': '💼'},
    {'name': 'Telegram', 'pkg': 'org.telegram.messenger', 'icon': '✈️'},
    {'name': 'Netflix', 'pkg': 'com.netflix.mediaclient', 'icon': '🎬'},
    {'name': 'Threads', 'pkg': 'com.instagram.barcelona', 'icon': '🔗'},
    {'name': 'Amazon', 'pkg': 'com.amazon.mShop.android.shopping', 'icon': '📦'},
  ];

  @override
  Widget build(BuildContext context) {
    final accessibilityAsync = ref.watch(accessibilityEnabledProvider);
    final blockedAppsAsync = ref.watch(blockedAppsProvider);
    final serviceEnabledAsync = ref.watch(serviceEnabledProvider);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 90),
        physics: const BouncingScrollPhysics(),
        children: [
          // Header
          Text(
            'Settings',
            style: GoogleFonts.poppins(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: FocusLockApp.textPrimary,
            ),
          ),
          const SizedBox(height: 24),

          // ═══════════════════════════════════
          //  PERMISSIONS
          // ═══════════════════════════════════
          _sectionTitle('Permissions', '🔐'),
          const SizedBox(height: 10),

          // Accessibility Service
          accessibilityAsync.when(
            data: (enabled) => _settingTile(
              icon: Icons.accessibility_new_rounded,
              title: 'Accessibility Service',
              subtitle: enabled ? 'Enabled ✓' : 'Required for app blocking',
              trailing: enabled
                  ? const Icon(Icons.check_circle, color: FocusLockApp.mint)
                  : TextButton(
                      onPressed: () {
                        ref.read(blockingServiceProvider).openAccessibilitySettings();
                      },
                      child: Text('Enable',
                          style: GoogleFonts.poppins(
                              color: FocusLockApp.accent, fontWeight: FontWeight.w600)),
                    ),
            ),
            loading: () => _loadingTile(),
            error: (_, __) => _errorTile('Could not check accessibility'),
          ),
          const SizedBox(height: 8),

          // Notification Permission
          _settingTile(
            icon: Icons.notifications_active_rounded,
            title: 'Notifications',
            subtitle: 'For taunts and reminders',
            trailing: IconButton(
              icon: const Icon(Icons.open_in_new_rounded,
                  color: FocusLockApp.accent, size: 20),
              onPressed: () {
                ref.read(blockingServiceProvider).openAccessibilitySettings();
              },
            ),
          ),
          const SizedBox(height: 28),

          // ═══════════════════════════════════
          //  SERVICE CONTROL
          // ═══════════════════════════════════
          _sectionTitle('Service Control', '⚙️'),
          const SizedBox(height: 10),

          serviceEnabledAsync.when(
            data: (enabled) => _settingTile(
              icon: Icons.power_settings_new_rounded,
              title: 'Blocking Service',
              subtitle: enabled
                  ? 'Active — blocking distracting apps'
                  : 'Inactive — apps not blocked',
              trailing: Switch(
                value: enabled,
                onChanged: (v) => _toggleService(v),
                activeColor: FocusLockApp.accent,
              ),
            ),
            loading: () => _loadingTile(),
            error: (_, __) => _errorTile('Could not load service status'),
          ),
          const SizedBox(height: 28),

          // ═══════════════════════════════════
          //  BLOCKED APPS
          // ═══════════════════════════════════
          _sectionTitle('Blocked Apps', '🚫'),
          const SizedBox(height: 10),

          // Quick-add grid
          Text(
            'Tap to toggle blocking',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: FocusLockApp.textSecondary,
            ),
          ),
          const SizedBox(height: 10),

          blockedAppsAsync.when(
            data: (blockedApps) {
              return Column(
                children: [
                  // Quick-add grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      childAspectRatio: 0.85,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: _popularApps.length,
                    itemBuilder: (_, i) {
                      final app = _popularApps[i];
                      final isBlocked = blockedApps.contains(app['pkg']);
                      return _appGridItem(
                        app['name'] as String,
                        app['icon'] as String,
                        app['pkg'] as String,
                        isBlocked,
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Add custom
                  InkWell(
                    onTap: () => _addCustomApp(),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 14),
                      decoration: BoxDecoration(
                        color: FocusLockApp.bgCardLight,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: FocusLockApp.accent.withAlpha(40),
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_rounded,
                              color: FocusLockApp.accent, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Add Custom Package',
                            style: GoogleFonts.poppins(
                              color: FocusLockApp.accent,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Currently blocked (summary)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: FocusLockApp.bgCard,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: FocusLockApp.bgCardLight.withAlpha(80),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.shield_rounded,
                            color: FocusLockApp.accent, size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '${blockedApps.length} apps currently blocked',
                            style: GoogleFonts.poppins(
                              color: FocusLockApp.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                  child: CircularProgressIndicator(color: FocusLockApp.accent)),
            ),
            error: (e, _) => _errorTile('Failed to load blocked apps: $e'),
          ),

          const SizedBox(height: 28),

          // ═══════════════════════════════════
          //  ABOUT
          // ═══════════════════════════════════
          _sectionTitle('About', 'ℹ️'),
          const SizedBox(height: 10),
          _settingTile(
            icon: Icons.info_outline_rounded,
            title: 'About FocusLock',
            subtitle: 'Version, credits & info',
            trailing: const Icon(Icons.chevron_right_rounded,
                color: FocusLockApp.textSecondary),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  // ─── Widgets ────────────────────────────

  Widget _sectionTitle(String title, String emoji) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: FocusLockApp.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _settingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: FocusLockApp.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: FocusLockApp.bgCardLight.withAlpha(80),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: FocusLockApp.accent.withAlpha(15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: FocusLockApp.accent, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.poppins(
                          color: FocusLockApp.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500)),
                  Text(subtitle,
                      style: GoogleFonts.poppins(
                          color: FocusLockApp.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  Widget _appGridItem(String name, String emoji, String pkg, bool isBlocked) {
    return InkWell(
      onTap: () => _toggleApp(pkg, isBlocked),
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: isBlocked
              ? FocusLockApp.coral.withAlpha(15)
              : FocusLockApp.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isBlocked
                ? FocusLockApp.coral.withAlpha(60)
                : FocusLockApp.bgCardLight.withAlpha(60),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 6),
            Text(
              name,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: isBlocked
                    ? FocusLockApp.coral
                    : FocusLockApp.textSecondary,
                fontWeight: isBlocked ? FontWeight.w600 : FontWeight.w400,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (isBlocked)
              Icon(Icons.block_rounded,
                  size: 14, color: FocusLockApp.coral.withAlpha(150)),
          ],
        ),
      ),
    );
  }

  Widget _loadingTile() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: FocusLockApp.bgCard,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Center(
          child: CircularProgressIndicator(color: FocusLockApp.accent)),
    );
  }

  Widget _errorTile(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FocusLockApp.coral.withAlpha(10),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(message,
          style: GoogleFonts.poppins(color: FocusLockApp.coral, fontSize: 13)),
    );
  }

  // ─── Actions ────────────────────────────

  Future<void> _toggleApp(String pkg, bool currentlyBlocked) async {
    HapticFeedback.lightImpact();
    final repo = ref.read(settingsRepositoryProvider);
    if (currentlyBlocked) {
      await repo.removeBlockedApp(pkg);
    } else {
      await repo.addBlockedApp(pkg);
    }
    ref.invalidate(blockedAppsProvider);
  }

  Future<void> _toggleService(bool enable) async {
    HapticFeedback.mediumImpact();
    final blocking = ref.read(blockingServiceProvider);
    final settingsRepo = ref.read(settingsRepositoryProvider);

    if (enable) {
      final apps = await settingsRepo.getBlockedApps();
      await blocking.startBlocking(apps);
      await settingsRepo.setServiceEnabled(true);
    } else {
      await blocking.stopBlocking();
      await settingsRepo.setServiceEnabled(false);
    }
    ref.invalidate(serviceEnabledProvider);
  }

  Future<void> _addCustomApp() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add Custom App',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: TextField(
          controller: controller,
          style: GoogleFonts.poppins(color: FocusLockApp.textPrimary),
          decoration: const InputDecoration(
            hintText: 'e.g. com.example.app',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: GoogleFonts.poppins(color: FocusLockApp.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: Text('Add',
                style: GoogleFonts.poppins(
                    color: FocusLockApp.accent, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      final repo = ref.read(settingsRepositoryProvider);
      await repo.addBlockedApp(result);
      ref.invalidate(blockedAppsProvider);
    }
  }
}
