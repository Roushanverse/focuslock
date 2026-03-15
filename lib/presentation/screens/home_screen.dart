import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../data/models/goal.dart';
import '../../data/motivational_quotes.dart';
import '../../data/providers/providers.dart';
import '../../main.dart';
import 'goal_create_screen.dart';
import 'goal_detail_screen.dart';
import 'statistics_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _refreshGoals();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _refreshGoals() {
    ref.invalidate(goalListProvider);
    ref.invalidate(activeGoalsProvider);
    ref.invalidate(pendingGoalsProvider);
    ref.invalidate(blockingActiveProvider);
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      _buildDashboard(),
      const StatisticsScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: FocusLockApp.bgCard,
          border: Border(
            top: BorderSide(
              color: FocusLockApp.accent.withAlpha(25),
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) {
            HapticFeedback.lightImpact();
            setState(() => _currentIndex = i);
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.insights_rounded),
              activeIcon: Icon(Icons.insights_rounded),
              label: 'Stats',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.tune_rounded),
              activeIcon: Icon(Icons.tune_rounded),
              label: 'Settings',
            ),
          ],
        ),
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () async {
                HapticFeedback.mediumImpact();
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GoalCreateScreen()),
                );
                _refreshGoals();
              },
              icon: const Icon(Icons.add_rounded, size: 22),
              label: Text('New Goal',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600, fontSize: 14)),
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            )
          : null,
    );
  }

  Widget _buildDashboard() {
    final goalsAsync = ref.watch(goalListProvider);
    final blockingAsync = ref.watch(blockingActiveProvider);

    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ─── Header ─────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 0),
              child: Row(
                children: [
                  // Logo
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [FocusLockApp.accent, Color(0xFF5B5FDB)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: FocusLockApp.accent.withAlpha(40),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.lock_rounded,
                        color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'FocusLock',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: FocusLockApp.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  // Status badge
                  blockingAsync.when(
                    data: (active) => _statusBadge(active),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),

          // ─── Motivational Quote Card ────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      FocusLockApp.accent.withAlpha(30),
                      FocusLockApp.bgCard.withAlpha(200),
                    ],
                  ),
                  border: Border.all(
                    color: FocusLockApp.accent.withAlpha(40),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Text('💡', style: GoogleFonts.poppins(fontSize: 28)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        MotivationalQuotes.getQuoteOfTheDay(),
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: FocusLockApp.textPrimary.withAlpha(200),
                          fontWeight: FontWeight.w400,
                          height: 1.5,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ─── Goals List ─────────────────
          goalsAsync.when(
            data: (goals) {
              if (goals.isEmpty) {
                return SliverFillRemaining(child: _emptyState());
              }

              final activeGoals =
                  goals.where((g) => g.status == GoalStatus.active).toList();
              final pendingGoals =
                  goals.where((g) => g.status == GoalStatus.pending).toList();
              final completedGoals = goals
                  .where((g) =>
                      g.status == GoalStatus.completed ||
                      g.status == GoalStatus.missed)
                  .toList()
                ..sort((a, b) => b.deadline.compareTo(a.deadline));

              return SliverList(
                delegate: SliverChildListDelegate([
                  if (activeGoals.isNotEmpty) ...[
                    _sectionHeader('Active Goals', '🔥'),
                    ...activeGoals.map((g) => _goalCard(g, isActive: true)),
                  ],
                  if (pendingGoals.isNotEmpty) ...[
                    _sectionHeader('Upcoming', '⏳'),
                    ...pendingGoals.map((g) => _goalCard(g)),
                  ],
                  if (completedGoals.isNotEmpty) ...[
                    _sectionHeader('Recent', '📋'),
                    ...completedGoals.take(10).map((g) => _goalCard(g)),
                  ],
                  const SizedBox(height: 90),
                ]),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: FocusLockApp.accent),
              ),
            ),
            error: (e, _) => SliverFillRemaining(
              child: Center(
                child: Text('Error: $e',
                    style: const TextStyle(color: FocusLockApp.coral)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(bool active) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: active
            ? FocusLockApp.coral.withAlpha(25)
            : FocusLockApp.mint.withAlpha(25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: active
              ? FocusLockApp.coral.withAlpha(80)
              : FocusLockApp.mint.withAlpha(80),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active ? FocusLockApp.coral : FocusLockApp.mint,
              boxShadow: [
                BoxShadow(
                  color: (active ? FocusLockApp.coral : FocusLockApp.mint)
                      .withAlpha(80),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            active ? 'Blocking' : 'Idle',
            style: GoogleFonts.poppins(
              color: active ? FocusLockApp.coral : FocusLockApp.mint,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: FocusLockApp.accent.withAlpha(15),
              ),
              child: Icon(Icons.flag_rounded,
                  size: 48, color: FocusLockApp.accent.withAlpha(80)),
            ),
            const SizedBox(height: 24),
            Text(
              'No goals yet',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: FocusLockApp.textPrimary.withAlpha(180),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first focus goal\nand start building discipline ✨',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: FocusLockApp.textSecondary,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, String emoji) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 10),
      child: Row(
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
      ),
    );
  }

  Widget _goalCard(Goal goal, {bool isActive = false}) {
    final statusColor = _getStatusColor(goal.status);
    final df = DateFormat('MMM d – h:mm a');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () async {
            HapticFeedback.lightImpact();
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => GoalDetailScreen(goalId: goal.id),
              ),
            );
            _refreshGoals();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isActive
                  ? FocusLockApp.accent.withAlpha(15)
                  : FocusLockApp.bgCard,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isActive
                    ? FocusLockApp.accent.withAlpha(50)
                    : FocusLockApp.bgCardLight.withAlpha(80),
                width: 1,
              ),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: FocusLockApp.accent.withAlpha(15),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        goal.title,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: FocusLockApp.textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withAlpha(20),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        goal.status.name.toUpperCase(),
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                if (goal.description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    goal.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: FocusLockApp.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.timer_outlined,
                        size: 14, color: FocusLockApp.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      '${goal.durationMinutes} min',
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: FocusLockApp.textSecondary),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.event_outlined,
                        size: 14, color: FocusLockApp.textSecondary),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        df.format(goal.deadline),
                        style: GoogleFonts.poppins(
                            fontSize: 12, color: FocusLockApp.textSecondary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (isActive) ...[
                  const SizedBox(height: 10),
                  _buildTimeRemaining(goal),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeRemaining(Goal goal) {
    final remaining = goal.remainingTime;
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes % 60;
    final seconds = remaining.inSeconds % 60;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: FocusLockApp.accent.withAlpha(15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.hourglass_bottom_rounded,
              size: 14, color: FocusLockApp.accent),
          const SizedBox(width: 6),
          Text(
            hours > 0
                ? '${hours}h ${minutes}m remaining'
                : '${minutes}m ${seconds}s remaining',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: FocusLockApp.accent,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(GoalStatus status) {
    switch (status) {
      case GoalStatus.active:
        return FocusLockApp.accent;
      case GoalStatus.pending:
        return FocusLockApp.amber;
      case GoalStatus.completed:
        return FocusLockApp.mint;
      case GoalStatus.missed:
        return FocusLockApp.coral;
    }
  }
}
