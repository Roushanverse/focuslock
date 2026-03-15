import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../data/models/goal.dart';
import '../../data/providers/providers.dart';
import '../../main.dart';
import 'goal_create_screen.dart';

class GoalDetailScreen extends ConsumerStatefulWidget {
  final String goalId;

  const GoalDetailScreen({super.key, required this.goalId});

  @override
  ConsumerState<GoalDetailScreen> createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends ConsumerState<GoalDetailScreen> {
  Goal? _goal;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGoal();
  }

  Future<void> _loadGoal() async {
    final repo = ref.read(goalRepositoryProvider);
    final goal = await repo.getGoalById(widget.goalId);
    if (mounted) {
      setState(() {
        _goal = goal;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: CircularProgressIndicator(color: FocusLockApp.accent),
        ),
      );
    }

    if (_goal == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Text('Goal not found',
              style: GoogleFonts.poppins(color: FocusLockApp.textSecondary)),
        ),
      );
    }

    final goal = _goal!;
    final df = DateFormat('MMM d, yyyy – h:mm a');
    final statusColor = _getStatusColor(goal.status);

    return Scaffold(
      appBar: AppBar(
        title: Text('Goal Details',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        actions: [
          if (goal.status == GoalStatus.pending)
            IconButton(
              icon: const Icon(Icons.edit_rounded),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GoalCreateScreen(existingGoal: goal),
                  ),
                );
                _loadGoal();
              },
            ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded,
                color: FocusLockApp.coral),
            onPressed: () => _confirmDelete(goal),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(22),
        physics: const BouncingScrollPhysics(),
        children: [
          // Status badge
          Center(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                color: statusColor.withAlpha(20),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: statusColor.withAlpha(60)),
              ),
              child: Text(
                goal.status.name.toUpperCase(),
                style: GoogleFonts.poppins(
                  color: statusColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Title
          Text(
            goal.title,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: FocusLockApp.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          if (goal.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              goal.description,
              style: GoogleFonts.poppins(
                  fontSize: 14, color: FocusLockApp.textSecondary, height: 1.5),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 28),

          // Progress ring for active goals
          if (goal.status == GoalStatus.active) ...[
            _buildProgressRing(goal),
            const SizedBox(height: 28),
          ],

          // Info cards
          _infoCard('📅', 'Deadline', df.format(goal.deadline)),
          _infoCard('⏱️', 'Duration', '${goal.durationMinutes} minutes'),
          _infoCard('🕐', 'Start Time', df.format(goal.startTime)),
          _infoCard('🛡️', 'Blocked Attempts', '${goal.blockedAttempts} times'),
          _infoCard('📆', 'Created', df.format(goal.createdAt)),

          if (goal.status == GoalStatus.active) ...[
            _infoCard('⏳', 'Remaining', _formatDuration(goal.remainingTime)),
          ],

          const SizedBox(height: 32),

          // Actions
          if (goal.status == GoalStatus.active)
            _actionButton(
              'Mark as Completed',
              Icons.check_circle_rounded,
              FocusLockApp.mint,
              () => _completeGoal(goal),
            ),

          if (goal.status == GoalStatus.pending)
            _actionButton(
              'Start Now',
              Icons.play_arrow_rounded,
              FocusLockApp.accent,
              () => _startNow(goal),
            ),
        ],
      ),
    );
  }

  Widget _buildProgressRing(Goal goal) {
    final total = Duration(minutes: goal.durationMinutes);
    final remaining = goal.remainingTime;
    final progress = 1.0 - (remaining.inSeconds / total.inSeconds).clamp(0.0, 1.0);

    return Center(
      child: SizedBox(
        width: 140,
        height: 140,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 140,
              height: 140,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 8,
                backgroundColor: FocusLockApp.bgCardLight,
                valueColor: AlwaysStoppedAnimation(
                  progress > 0.8 ? FocusLockApp.mint : FocusLockApp.accent,
                ),
                strokeCap: StrokeCap.round,
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${(progress * 100).toInt()}%',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: FocusLockApp.textPrimary,
                  ),
                ),
                Text(
                  'complete',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: FocusLockApp.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(String emoji, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: FocusLockApp.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: FocusLockApp.bgCardLight.withAlpha(80),
        ),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Text(label,
              style: GoogleFonts.poppins(
                  color: FocusLockApp.textSecondary, fontSize: 14)),
          const Spacer(),
          Text(value,
              style: GoogleFonts.poppins(
                  color: FocusLockApp.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _actionButton(
      String label, IconData icon, Color color, VoidCallback onTap) {
    return SizedBox(
      height: 54,
      child: ElevatedButton.icon(
        onPressed: () {
          HapticFeedback.mediumImpact();
          onTap();
        },
        icon: Icon(icon),
        label: Text(label,
            style: GoogleFonts.poppins(
                fontSize: 16, fontWeight: FontWeight.w600)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes % 60;
    if (hours > 0) return '${hours}h ${minutes}m';
    return '${minutes}m';
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

  Future<void> _completeGoal(Goal goal) async {
    final useCase = ref.read(completeGoalUseCaseProvider);
    await useCase.execute(goal);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎉 Goal completed! Great job!',
              style: GoogleFonts.poppins()),
          backgroundColor: FocusLockApp.mint,
        ),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _startNow(Goal goal) async {
    final useCase = ref.read(activateGoalUseCaseProvider);
    await useCase.execute(goal);
    await _loadGoal();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎯 Focus session started!',
              style: GoogleFonts.poppins()),
          backgroundColor: FocusLockApp.accent,
        ),
      );
    }
  }

  Future<void> _confirmDelete(Goal goal) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Goal'),
        content: const Text('Are you sure you want to delete this goal?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: GoogleFonts.poppins(color: FocusLockApp.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete',
                style:
                    GoogleFonts.poppins(color: FocusLockApp.coral)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final repo = ref.read(goalRepositoryProvider);
      await repo.deleteGoal(goal.id);
      if (mounted) Navigator.pop(context);
    }
  }
}
