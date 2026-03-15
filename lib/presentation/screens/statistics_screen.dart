import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../data/models/goal.dart';
import '../../data/models/taunt_event.dart';
import '../../data/taunts.dart';
import '../../data/providers/providers.dart';
import '../../main.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(goalListProvider);
    final tauntsAsync = ref.watch(recentTauntsProvider);

    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ─── Header ─────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 0),
              child: Text(
                'Statistics',
                style: GoogleFonts.poppins(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: FocusLockApp.textPrimary,
                ),
              ),
            ),
          ),

          // ─── Summary Cards ──────────────
          goalsAsync.when(
            data: (goals) {
              final completed =
                  goals.where((g) => g.status == GoalStatus.completed).length;
              final missed =
                  goals.where((g) => g.status == GoalStatus.missed).length;
              final totalFocusMin = goals
                  .where((g) => g.status == GoalStatus.completed)
                  .fold<int>(0, (sum, g) => sum + g.durationMinutes);
              final totalBlocked =
                  goals.fold<int>(0, (sum, g) => sum + g.blockedAttempts);

              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 20, 18, 0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _statCard(
                              '🎯',
                              'Completed',
                              '$completed',
                              FocusLockApp.mint,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _statCard(
                              '❌',
                              'Missed',
                              '$missed',
                              FocusLockApp.coral,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _statCard(
                              '⏱️',
                              'Focus Time',
                              _formatMinutes(totalFocusMin),
                              FocusLockApp.accent,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _statCard(
                              '🛡️',
                              'Blocked',
                              '$totalBlocked',
                              FocusLockApp.amber,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Weekly chart
                      _buildWeeklyChart(goals),
                    ],
                  ),
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Center(
                    child:
                        CircularProgressIndicator(color: FocusLockApp.accent)),
              ),
            ),
            error: (e, _) => SliverToBoxAdapter(
              child: Center(
                  child: Text('Error: $e',
                      style:
                          const TextStyle(color: FocusLockApp.coral))),
            ),
          ),

          // ─── Taunts History ─────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 24, 22, 10),
              child: Text(
                'Recent Taunts',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: FocusLockApp.textPrimary,
                ),
              ),
            ),
          ),
          tauntsAsync.when(
            data: (taunts) {
              if (taunts.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(30),
                    child: Center(
                      child: Text(
                        'No taunts yet. Focus hard and you won\'t see any! 🌟',
                        style: GoogleFonts.poppins(
                          color: FocusLockApp.textSecondary,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => _tauntTile(taunts[i]),
                  childCount: taunts.length,
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(
              child: Center(
                  child:
                      CircularProgressIndicator(color: FocusLockApp.accent)),
            ),
            error: (e, _) => SliverToBoxAdapter(
              child: Center(
                  child: Text('Error: $e',
                      style:
                          const TextStyle(color: FocusLockApp.coral))),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  Widget _statCard(String emoji, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.poppins(
                  color: FocusLockApp.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart(List<Goal> goals) {
    final now = DateTime.now();
    final days = List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      final dayGoals = goals.where((g) =>
          g.status == GoalStatus.completed &&
          g.deadline.year == day.year &&
          g.deadline.month == day.month &&
          g.deadline.day == day.day);
      final totalMin =
          dayGoals.fold<int>(0, (sum, g) => sum + g.durationMinutes);
      return totalMin / 60.0; // hours
    });

    final maxY = days.reduce((a, b) => a > b ? a : b);
    final chartMax = maxY < 1.0 ? 2.0 : (maxY + 1).ceilToDouble();
    final dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final todayIndex = now.weekday - 1;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: FocusLockApp.bgCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: FocusLockApp.bgCardLight.withAlpha(80),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Focus Hours',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: FocusLockApp.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                maxY: chartMax,
                barGroups: List.generate(7, (i) {
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: days[i],
                        width: 20,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(6),
                          topRight: Radius.circular(6),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            FocusLockApp.accent.withAlpha(100),
                            FocusLockApp.accent,
                          ],
                        ),
                      ),
                    ],
                  );
                }),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        final idx = value.toInt();
                        final realIdx = (todayIndex - 6 + idx) % 7;
                        return Text(
                          dayLabels[realIdx < 0 ? realIdx + 7 : realIdx],
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: FocusLockApp.textSecondary,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${rod.toY.toStringAsFixed(1)}h',
                        GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tauntTile(TauntEvent taunt) {
    final appName = _getAppName(taunt.packageName);
    final timeAgo = _timeAgo(taunt.timestamp);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: FocusLockApp.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: FocusLockApp.bgCardLight.withAlpha(60),
          ),
        ),
        child: Row(
          children: [
            Text('😈', style: GoogleFonts.poppins(fontSize: 22)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    taunt.memeCaption,
                    style: GoogleFonts.poppins(
                      color: FocusLockApp.textPrimary,
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$appName · $timeAgo',
                    style: GoogleFonts.poppins(
                      color: FocusLockApp.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatMinutes(int minutes) {
    if (minutes < 60) return '${minutes}m';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m > 0 ? '${h}h ${m}m' : '${h}h';
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  String _getAppName(String pkg) {
    const names = {
      'com.instagram.android': 'Instagram',
      'com.google.android.youtube': 'YouTube',
      'com.whatsapp': 'WhatsApp',
      'com.facebook.katana': 'Facebook',
      'com.twitter.android': 'Twitter',
      'com.zhiliaoapp.musically': 'TikTok',
      'com.snapchat.android': 'Snapchat',
      'com.reddit.frontpage': 'Reddit',
      'com.spotify.music': 'Spotify',
      'com.discord': 'Discord',
      'com.pinterest': 'Pinterest',
      'com.linkedin.android': 'LinkedIn',
      'com.google.android.apps.messaging': 'Messages',
      'com.netflix.mediaclient': 'Netflix',
      'com.amazon.mShop.android.shopping': 'Amazon',
      'org.telegram.messenger': 'Telegram',
      'com.ss.android.ugc.trill': 'TikTok',
    };
    return names[pkg] ?? pkg.split('.').last;
  }
}
