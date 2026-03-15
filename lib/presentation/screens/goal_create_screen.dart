import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/goal.dart';
import '../../data/providers/providers.dart';
import '../../main.dart';

class GoalCreateScreen extends ConsumerStatefulWidget {
  final Goal? existingGoal;

  const GoalCreateScreen({super.key, this.existingGoal});

  @override
  ConsumerState<GoalCreateScreen> createState() => _GoalCreateScreenState();
}

class _GoalCreateScreenState extends ConsumerState<GoalCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  DateTime _deadline = DateTime.now().add(const Duration(hours: 2));
  int _durationMinutes = 60;
  final bool _isRecurring = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingGoal != null) {
      final g = widget.existingGoal!;
      _titleController.text = g.title;
      _descController.text = g.description;
      _deadline = g.deadline;
      _durationMinutes = g.durationMinutes;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingGoal != null;
    final df = DateFormat('MMM d, yyyy');
    final tf = DateFormat('h:mm a');

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Goal' : 'Create Goal',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(22),
          physics: const BouncingScrollPhysics(),
          children: [
            // Title
            _label('Goal Title'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleController,
              style: GoogleFonts.poppins(color: FocusLockApp.textPrimary),
              decoration: InputDecoration(
                hintText: 'e.g. Study Math Chapter 5',
                prefixIcon: const Icon(Icons.flag_rounded,
                    color: FocusLockApp.accent),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Title is required' : null,
            ),
            const SizedBox(height: 20),

            // Description
            _label('Description (optional)'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descController,
              style: GoogleFonts.poppins(color: FocusLockApp.textPrimary),
              decoration: InputDecoration(
                hintText: 'What will you accomplish?',
                prefixIcon:
                    const Icon(Icons.notes_rounded, color: FocusLockApp.accent),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 28),

            // Deadline
            _label('Deadline'),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _pickerTile(
                  icon: Icons.calendar_today_rounded,
                  label: df.format(_deadline),
                  onTap: _pickDate,
                )),
                const SizedBox(width: 12),
                Expanded(child: _pickerTile(
                  icon: Icons.access_time_rounded,
                  label: tf.format(_deadline),
                  onTap: _pickTime,
                )),
              ],
            ),
            const SizedBox(height: 28),

            // Duration
            _label('Focus Duration'),
            const SizedBox(height: 10),
            _buildDurationSelector(),
            const SizedBox(height: 10),
            Text(
              'Blocking: ${tf.format(_deadline.subtract(Duration(minutes: _durationMinutes)))} → ${tf.format(_deadline)}',
              style: GoogleFonts.poppins(
                  fontSize: 12, color: FocusLockApp.textSecondary),
            ),
            const SizedBox(height: 24),

            // Preview
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    FocusLockApp.accent.withAlpha(20),
                    FocusLockApp.bgCard,
                  ],
                ),
                border: Border.all(
                  color: FocusLockApp.accent.withAlpha(40),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Session Preview',
                    style: GoogleFonts.poppins(
                      color: FocusLockApp.accent,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _previewRow('Start', DateFormat('MMM d – h:mm a').format(
                      _deadline.subtract(Duration(minutes: _durationMinutes)))),
                  _previewRow('End', DateFormat('MMM d – h:mm a').format(_deadline)),
                  _previewRow('Duration', '$_durationMinutes minutes'),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Save button
            SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveGoal,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 24, height: 24,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        isEditing ? 'Update Goal' : 'Create Goal',
                        style: GoogleFonts.poppins(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        color: FocusLockApp.textPrimary,
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _pickerTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: FocusLockApp.bgCardLight,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: FocusLockApp.accent, size: 20),
            const SizedBox(width: 10),
            Text(label,
                style: GoogleFonts.poppins(
                    color: FocusLockApp.textPrimary, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationSelector() {
    final durations = [15, 30, 45, 60, 90, 120];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: durations.map((d) {
        final selected = d == _durationMinutes;
        return ChoiceChip(
          label: Text(d < 60
              ? '${d}m'
              : '${d ~/ 60}h${d % 60 > 0 ? ' ${d % 60}m' : ''}'),
          selected: selected,
          onSelected: (_) {
            HapticFeedback.selectionClick();
            setState(() => _durationMinutes = d);
          },
          selectedColor: FocusLockApp.accent,
          backgroundColor: FocusLockApp.bgCardLight,
          labelStyle: GoogleFonts.poppins(
            color: selected ? Colors.white : FocusLockApp.textSecondary,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
          side: BorderSide(
            color: selected
                ? FocusLockApp.accent
                : FocusLockApp.bgCardLight,
          ),
        );
      }).toList(),
    );
  }

  Widget _previewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(label,
                style: GoogleFonts.poppins(
                    color: FocusLockApp.textSecondary, fontSize: 13)),
          ),
          Text(value,
              style: GoogleFonts.poppins(
                  color: FocusLockApp.textPrimary, fontSize: 13)),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _deadline = DateTime(
          picked.year, picked.month, picked.day,
          _deadline.hour, _deadline.minute,
        );
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_deadline),
    );
    if (picked != null) {
      setState(() {
        _deadline = DateTime(
          _deadline.year, _deadline.month, _deadline.day,
          picked.hour, picked.minute,
        );
      });
    }
  }

  Future<void> _saveGoal() async {
    if (!_formKey.currentState!.validate()) return;

    final startTime = _deadline.subtract(Duration(minutes: _durationMinutes));
    if (startTime.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Focus session start time is in the past. Choose a later deadline or shorter duration.',
            style: GoogleFonts.poppins(fontSize: 13),
          ),
          backgroundColor: FocusLockApp.coral,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    HapticFeedback.mediumImpact();

    final repo = ref.read(goalRepositoryProvider);
    final goal = Goal(
      id: widget.existingGoal?.id ?? const Uuid().v4(),
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      deadline: _deadline,
      durationMinutes: _durationMinutes,
      isRecurring: _isRecurring,
      status: widget.existingGoal?.status ?? GoalStatus.pending,
      createdAt: widget.existingGoal?.createdAt ?? DateTime.now(),
      blockedAttempts: widget.existingGoal?.blockedAttempts ?? 0,
    );

    await repo.addGoal(goal);

    if (mounted) Navigator.pop(context);
  }
}
