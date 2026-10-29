import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/widgets.dart';
import '../../../../data/repositories/providers.dart';
import '../providers/doctor_providers.dart';
import '../widgets/doctor_widgets.dart';

enum _SlotStatus { free, booked, blocked, past }

class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  late DateTime _selected = _d(DateTime.now());
  bool _selectMode = false;
  final _picked = <DateTime>{};
  bool _loading = true;

  static DateTime _d(DateTime t) => DateTime(t.year, t.month, t.day);
  DateTime get _weekStart => _selected.subtract(Duration(days: _selected.weekday - 1));

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    await fakeLatency(350, 600);
    if (mounted) setState(() => _loading = false);
  }

  List<DateTime> _slotsFor(DateTime day) => [
        for (var m = 9 * 60; m < 20 * 60; m += 30) DateTime(day.year, day.month, day.day, m ~/ 60, m % 60),
      ];

  String? _bookedPatient(DateTime t) {
    final h = t.hour * 2 + (t.minute ~/ 30) + t.day * 3 + t.month;
    if (h % 4 != 0) return null;
    return mockQueuePatients[h % mockQueuePatients.length].name;
  }

  _SlotStatus _status(DateTime t, ScheduleState s) {
    if (s.blocked.containsKey(slotKey(t))) return _SlotStatus.blocked;
    if (_bookedPatient(t) != null) return _SlotStatus.booked;
    if (t.isBefore(DateTime.now())) return _SlotStatus.past;
    return _SlotStatus.free;
  }

  void _shiftWeek(int dir) => setState(() {
        _selected = _selected.add(Duration(days: 7 * dir));
        _picked.clear();
      });

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final sch = ref.watch(scheduleProvider);
    final slots = _slotsFor(_selected);
    final onLeave = sch.onLeave(_selected);
    final dayOff = !sch.isWorking(_selected);
    final closed = onLeave || dayOff;
    final statuses = [for (final s in slots) _status(s, sch)];
    final booked = statuses.where((e) => e == _SlotStatus.booked).length;
    final blocked = statuses.where((e) => e == _SlotStatus.blocked).length;
    final free = statuses.where((e) => e == _SlotStatus.free).length;
    final weekStart = _weekStart;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Schedule', style: context.tt.headlineMedium),
                  const SizedBox(height: 4),
                  const DoctorModeChip(),
                ]),
              ),
              AppIconButton(icon: Icons.schedule_rounded, tooltip: 'Working hours', onTap: () => _workingHours(context)),
              const SizedBox(width: 8),
              AppIconButton(icon: Icons.beach_access_rounded, tooltip: 'Mark leave', onTap: () => _leaveSheet(context)),
            ]),
          ),
          // Week header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(children: [
              IconButton(onPressed: () => _shiftWeek(-1), icon: const Icon(Icons.chevron_left_rounded)),
              Expanded(child: Text(DateFormat('MMMM yyyy').format(_selected), textAlign: TextAlign.center, style: context.tt.titleMedium)),
              IconButton(onPressed: () => _shiftWeek(1), icon: const Icon(Icons.chevron_right_rounded)),
            ]),
          ),
          SizedBox(
            height: 78,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(children: [
                for (var i = 0; i < 7; i++)
                  Expanded(child: _DayCell(
                    date: weekStart.add(Duration(days: i)),
                    selected: isSameDay(weekStart.add(Duration(days: i)), _selected),
                    today: isSameDay(weekStart.add(Duration(days: i)), DateTime.now()),
                    leave: sch.onLeave(weekStart.add(Duration(days: i))),
                    off: !sch.isWorking(weekStart.add(Duration(days: i))),
                    onTap: () => setState(() {
                      _selected = weekStart.add(Duration(days: i));
                      _picked.clear();
                    }),
                  )),
              ]),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [
              Expanded(child: _Count(label: 'Booked', n: booked, color: p.primary, bg: p.primarySoft)),
              const SizedBox(width: 8),
              Expanded(child: _Count(label: 'Free', n: free, color: p.success, bg: p.successSoft)),
              const SizedBox(width: 8),
              Expanded(child: _Count(label: 'Blocked', n: blocked, color: p.warning, bg: p.warningSoft)),
            ]),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [
              Expanded(child: Text(relativeDay(_selected) == fmtDate(_selected) ? fmtDate(_selected) : '${relativeDay(_selected)} · ${fmtDate(_selected)}', style: context.tt.titleSmall)),
              if (!closed) ...[
                TextButton.icon(
                  onPressed: () => setState(() {
                    _selectMode = !_selectMode;
                    _picked.clear();
                  }),
                  icon: Icon(_selectMode ? Icons.close_rounded : Icons.checklist_rounded, size: 18),
                  label: Text(_selectMode ? 'Cancel' : 'Select'),
                ),
                TextButton.icon(onPressed: () => _blockWholeDay(context, slots, statuses), icon: const Icon(Icons.block_rounded, size: 18), label: const Text('Block day')),
              ],
            ]),
          ),
          Expanded(
            child: _loading
                ? const ShimmerList(itemCount: 6, itemHeight: 64)
                : RefreshIndicator(
                    color: p.primary,
                    onRefresh: _load,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(20, 4, 20, _selectMode && _picked.isNotEmpty ? 100 : 24),
                      children: [
                        if (onLeave) _Banner(icon: Icons.beach_access_rounded, title: 'You are on leave', msg: 'No appointments can be booked on this day.', color: p.accent, bg: p.accentSoft, action: 'Cancel leave', onAction: () {
                          final l = sch.leaves.firstWhere((l) => l.covers(_selected));
                          ref.read(scheduleProvider.notifier).removeLeave(l);
                          showAppSnack(context, 'Leave cancelled — slots reopened', icon: Icons.event_available_rounded);
                        })
                        else if (dayOff) _Banner(icon: Icons.weekend_rounded, title: 'Day off', msg: 'This weekday is not in your working hours.', color: p.textSecondary, bg: p.surfaceAlt, action: 'Edit hours', onAction: () => _workingHours(context)),
                        for (var i = 0; i < slots.length; i++)
                          _SlotRow(
                            time: slots[i],
                            status: closed ? _SlotStatus.past : statuses[i],
                            patient: _bookedPatient(slots[i]),
                            reason: sch.blocked[slotKey(slots[i])],
                            selected: _picked.contains(slots[i]),
                            selectMode: _selectMode,
                            onTap: closed ? null : () => _tapSlot(context, slots[i], statuses[i], sch),
                          ).animate().fadeIn(duration: 250.ms, delay: (15 * i).ms),
                      ],
                    ),
                  ),
          ),
          if (_selectMode && _picked.isNotEmpty)
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
              decoration: BoxDecoration(color: p.surface, border: Border(top: BorderSide(color: p.border))),
              child: AppButton(label: 'Block ${_picked.length} slot${_picked.length > 1 ? 's' : ''}', icon: Icons.block_rounded, variant: AppButtonVariant.accent, onPressed: () => _reasonSheet(context, _picked.toList(), 'Block ${_picked.length} slots')),
            ),
        ]),
      ),
    );
  }

  void _tapSlot(BuildContext context, DateTime t, _SlotStatus st, ScheduleState sch) {
    HapticFeedback.selectionClick();
    switch (st) {
      case _SlotStatus.free:
        if (_selectMode) {
          setState(() => _picked.contains(t) ? _picked.remove(t) : _picked.add(t));
        } else {
          _reasonSheet(context, [t], 'Block ${fmtTime(t)}');
        }
      case _SlotStatus.blocked:
        showAppBottomSheet<void>(context, title: 'Blocked · ${fmtTime(t)}', builder: (ctx) => Column(children: [
              Row(children: [
                Icon(Icons.block_rounded, color: ctx.pal.warning),
                const SizedBox(width: 10),
                Expanded(child: Text('Reason: ${sch.blocked[slotKey(t)] ?? 'Personal'}', style: ctx.tt.titleSmall)),
              ]),
              const SizedBox(height: 20),
              AppButton(label: 'Unblock slot', icon: Icons.lock_open_rounded, onPressed: () {
                ref.read(scheduleProvider.notifier).unblock(t);
                Navigator.pop(ctx);
                showAppSnack(context, '${fmtTime(t)} is open for booking again', icon: Icons.lock_open_rounded);
              }),
            ]));
      case _SlotStatus.booked:
        showAppSnack(context, 'Booked by ${_bookedPatient(t)} — manage it from Queue', icon: Icons.person_rounded);
      case _SlotStatus.past:
        showAppSnack(context, 'This slot has already passed', icon: Icons.history_rounded, error: true);
    }
  }

  void _reasonSheet(BuildContext context, List<DateTime> slots, String title) {
    String reason = 'Lunch';
    showAppBottomSheet<void>(context, title: title, builder: (ctx) {
      return StatefulBuilder(builder: (ctx, setS) {
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Reason', style: ctx.tt.labelMedium),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8, children: [for (final r in ['Lunch', 'Meeting', 'Surgery', 'Personal']) ChoicePill(label: r, selected: reason == r, onTap: () => setS(() => reason = r))]),
          const SizedBox(height: 8),
          Text('Patients will not be able to book these slots.', style: ctx.tt.bodySmall),
          const SizedBox(height: 20),
          AppButton(label: 'Block', icon: Icons.block_rounded, onPressed: () {
            ref.read(scheduleProvider.notifier).block(slots, reason);
            Navigator.pop(ctx);
            setState(() {
              _picked.clear();
              _selectMode = false;
            });
            showAppSnack(context, '${slots.length} slot${slots.length > 1 ? 's' : ''} blocked · $reason', icon: Icons.block_rounded);
          }),
        ]);
      });
    });
  }

  Future<void> _blockWholeDay(BuildContext context, List<DateTime> slots, List<_SlotStatus> st) async {
    final free = [for (var i = 0; i < slots.length; i++) if (st[i] == _SlotStatus.free) slots[i]];
    if (free.isEmpty) {
      showAppSnack(context, 'No free slots left to block on this day', icon: Icons.info_outline_rounded);
      return;
    }
    final ok = await showConfirmSheet(context, title: 'Block the whole day?', message: '${free.length} free slots on ${fmtDate(_selected)} will be blocked. Booked patients are not affected.', confirmLabel: 'Block day', destructive: true, icon: Icons.block_rounded);
    if (!ok || !mounted) return;
    ref.read(scheduleProvider.notifier).block(free, 'Personal');
    if (mounted) showAppSnack(this.context, '${free.length} slots blocked for ${fmtDate(_selected)}', icon: Icons.block_rounded);
  }

  void _leaveSheet(BuildContext context) {
    showAppBottomSheet<void>(context, title: 'Mark leave', builder: (ctx) => _LeaveForm(
          initial: _selected,
          onConfirm: (range, reason, notify) {
            ref.read(scheduleProvider.notifier).addLeave(LeaveRange(from: range.start, to: range.end, reason: reason));
            Navigator.pop(ctx);
            final days = range.end.difference(range.start).inDays + 1;
            showAppSnack(context, 'Leave marked for $days day${days > 1 ? 's' : ''}${notify ? ' · patients notified' : ''}', icon: Icons.beach_access_rounded);
          },
        ));
  }

  void _workingHours(BuildContext context) {
    showAppBottomSheet<void>(context, title: 'Working hours', builder: (ctx) => Consumer(builder: (ctx, ref, _) {
          final s = ref.watch(scheduleProvider);
          const names = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
          return Column(children: [
            for (var i = 1; i <= 7; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(names[i - 1], style: ctx.tt.titleSmall), Text(s.workingDays.contains(i) ? '9:00 AM – 8:00 PM' : 'Closed', style: ctx.tt.bodySmall)])),
                  Switch(value: s.workingDays.contains(i), onChanged: (_) => ref.read(scheduleProvider.notifier).toggleDay(i)),
                ]),
              ),
            const SizedBox(height: 12),
            AppButton(label: 'Save', onPressed: () {
              Navigator.pop(ctx);
              showAppSnack(context, 'Working hours updated', icon: Icons.schedule_rounded);
            }),
          ]);
        }));
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({required this.date, required this.selected, required this.today, required this.leave, required this.off, required this.onTap});
  final DateTime date;
  final bool selected, today, leave, off;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final fg = selected ? p.onPrimary : (off ? p.textTertiary : p.textPrimary);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? p.primary : p.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? p.primary : (today ? p.primary.withValues(alpha: .5) : p.border)),
          boxShadow: selected ? [BoxShadow(color: p.primary.withValues(alpha: .3), blurRadius: 10, offset: const Offset(0, 4))] : null,
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(DateFormat('E').format(date).substring(0, 3), style: context.tt.labelSmall!.copyWith(color: selected ? p.onPrimary.withValues(alpha: .85) : p.textSecondary)),
          const SizedBox(height: 4),
          Text('${date.day}', style: context.tt.titleSmall!.copyWith(color: fg)),
          const SizedBox(height: 4),
          Container(width: 5, height: 5, decoration: BoxDecoration(shape: BoxShape.circle, color: leave ? p.accent : (today ? (selected ? p.onPrimary : p.primary) : Colors.transparent))),
        ]),
      ),
    );
  }
}

class _Count extends StatelessWidget {
  const _Count({required this.label, required this.n, required this.color, required this.bg});
  final String label;
  final int n;
  final Color color, bg;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(color: bg, borderRadius: AppRadius.rSm),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text('$n', style: context.tt.titleMedium!.copyWith(color: color)),
        const SizedBox(width: 6),
        Flexible(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.tt.labelSmall!.copyWith(color: color))),
      ]),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.icon, required this.title, required this.msg, required this.color, required this.bg, required this.action, required this.onAction});
  final IconData icon;
  final String title, msg, action;
  final Color color, bg;
  final VoidCallback onAction;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: bg, borderRadius: AppRadius.rLg),
      child: Row(children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: context.tt.titleSmall!.copyWith(color: color)), Text(msg, style: context.tt.bodySmall)])),
        TextButton(onPressed: onAction, child: Text(action)),
      ]),
    );
  }
}

class _SlotRow extends StatelessWidget {
  const _SlotRow({required this.time, required this.status, required this.patient, required this.reason, required this.selected, required this.selectMode, required this.onTap});
  final DateTime time;
  final _SlotStatus status;
  final String? patient, reason;
  final bool selected, selectMode;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final (label, c, bg, icon) = switch (status) {
      _SlotStatus.free => ('Available', p.success, p.successSoft, Icons.add_circle_outline_rounded),
      _SlotStatus.booked => (patient ?? 'Booked', p.primary, p.primarySoft, Icons.person_rounded),
      _SlotStatus.blocked => ('Blocked · ${reason ?? ''}', p.warning, p.warningSoft, Icons.block_rounded),
      _SlotStatus.past => ('Unavailable', p.textTertiary, p.surfaceAlt, Icons.remove_circle_outline_rounded),
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        SizedBox(width: 62, child: Text(fmtTime(time), style: context.tt.labelMedium!.copyWith(color: p.textSecondary))),
        Expanded(
          child: TapScale(
            onTap: onTap,
            scale: .98,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(color: bg, borderRadius: AppRadius.rSm, border: Border.all(color: selected ? p.primary : Colors.transparent, width: 2)),
              child: Row(children: [
                Icon(selected ? Icons.check_circle_rounded : icon, size: 18, color: selected ? p.primary : c),
                const SizedBox(width: 10),
                Expanded(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.tt.labelMedium!.copyWith(color: c, fontWeight: FontWeight.w700))),
                if (status == _SlotStatus.free && selectMode && !selected) Icon(Icons.radio_button_unchecked_rounded, size: 16, color: p.textTertiary),
              ]),
            ),
          ),
        ),
      ]),
    );
  }
}

class _LeaveForm extends StatefulWidget {
  const _LeaveForm({required this.initial, required this.onConfirm});
  final DateTime initial;
  final void Function(DateTimeRange range, String reason, bool notify) onConfirm;
  @override
  State<_LeaveForm> createState() => _LeaveFormState();
}

class _LeaveFormState extends State<_LeaveForm> {
  late DateTimeRange _range = DateTimeRange(start: widget.initial, end: widget.initial);
  String _reason = 'Vacation';
  bool _notify = true;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Dates', style: context.tt.labelMedium),
      const SizedBox(height: 8),
      AppCard(
        shadow: false,
        onTap: () async {
          final r = await showDateRangePicker(context: context, firstDate: DateTime.now().subtract(const Duration(days: 1)), lastDate: DateTime.now().add(const Duration(days: 365)), initialDateRange: _range);
          if (r != null) setState(() => _range = r);
        },
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          Icon(Icons.date_range_rounded, color: p.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(isSameDay(_range.start, _range.end) ? fmtDateLong(_range.start) : '${fmtDateShort(_range.start)} → ${fmtDateShort(_range.end)}', style: context.tt.titleSmall)),
          Icon(Icons.edit_calendar_rounded, size: 18, color: p.textTertiary),
        ]),
      ),
      const SizedBox(height: 16),
      Text('Reason', style: context.tt.labelMedium),
      const SizedBox(height: 8),
      Wrap(spacing: 8, runSpacing: 8, children: [for (final r in ['Vacation', 'Conference', 'Medical', 'Personal']) ChoicePill(label: r, selected: _reason == r, onTap: () => setState(() => _reason = r))]),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Notify patients', style: context.tt.titleSmall), Text('Send reschedule options to booked patients', style: context.tt.bodySmall)])),
        Switch(value: _notify, onChanged: (v) => setState(() => _notify = v)),
      ]),
      const SizedBox(height: 16),
      AppButton(label: 'Confirm leave', icon: Icons.check_rounded, onPressed: () => widget.onConfirm(_range, _reason, _notify)),
    ]);
  }
}
