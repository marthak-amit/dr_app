import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/widgets.dart';
import '../../../../data/repositories/providers.dart';
import '../../../booking/presentation/widgets/slot_picker.dart';

// ───────────────────────── Reschedule ─────────────────────────

Future<void> showRescheduleSheet(BuildContext context, Appointment a) {
  return showAppBottomSheet<void>(context, title: 'Reschedule appointment', builder: (_) => _RescheduleBody(appointment: a));
}

class _RescheduleBody extends ConsumerStatefulWidget {
  const _RescheduleBody({required this.appointment});
  final Appointment appointment;
  @override
  ConsumerState<_RescheduleBody> createState() => _RescheduleBodyState();
}

class _RescheduleBodyState extends ConsumerState<_RescheduleBody> {
  late DateTime _date = dateOnly(widget.appointment.dateTime.isBefore(DateTime.now()) ? DateTime.now() : widget.appointment.dateTime);
  DateTime? _slot;
  bool _busy = false;

  Future<void> _confirm() async {
    final slot = _slot;
    if (slot == null || _busy) return;
    setState(() => _busy = true);
    await fakeLatency(400, 700);
    ref.read(appointmentsProvider.notifier).reschedule(widget.appointment.id, slot);
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('Rescheduled to ${fmtWhen(slot)}'), margin: const EdgeInsets.fromLTRB(16, 0, 16, 16)));
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final doc = doctorById(widget.appointment.doctorId);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: p.primarySoft, borderRadius: AppRadius.rMd),
        child: Row(children: [
          DoctorAvatar(doctor: doc, size: 44, hero: false),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(doc.name, style: context.tt.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
            Text('Currently ${fmtWhen(widget.appointment.dateTime)}', style: context.tt.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
          ])),
        ]),
      ),
      const SizedBox(height: 20),
      DateStrip(selected: _date, onChanged: (d) => setState(() {
            _date = d;
            _slot = null;
          })),
      const SizedBox(height: 20),
      SlotGrid(doctorId: widget.appointment.doctorId, date: _date, selected: _slot, onSelect: (t) => setState(() => _slot = t)),
      const SizedBox(height: 12),
      AppButton(label: _slot == null ? 'Select a time slot' : 'Confirm ${fmtTime(_slot!)}', onPressed: _slot == null ? null : _confirm, loading: _busy),
    ]);
  }
}

// ───────────────────────── Cancel ─────────────────────────

const _cancelReasons = ['Schedule conflict', 'Feeling better', 'Found another doctor', 'Booked by mistake', 'Personal emergency', 'Other'];

Future<void> showCancelSheet(BuildContext context, Appointment a, {VoidCallback? onCancelled}) {
  return showAppBottomSheet<void>(context, title: 'Cancel appointment', builder: (_) => _CancelBody(appointment: a, onCancelled: onCancelled));
}

class _CancelBody extends ConsumerStatefulWidget {
  const _CancelBody({required this.appointment, this.onCancelled});
  final Appointment appointment;
  final VoidCallback? onCancelled;
  @override
  ConsumerState<_CancelBody> createState() => _CancelBodyState();
}

class _CancelBodyState extends ConsumerState<_CancelBody> {
  String? _reason;

  Future<void> _submit() async {
    final reason = _reason;
    if (reason == null) return;
    final ok = await showConfirmSheet(context,
        title: 'Cancel this visit?',
        message: 'Your slot will be released. ${widget.appointment.paid ? 'A refund of ${rupees(widget.appointment.fee)} will be initiated.' : 'You will not be charged.'}',
        confirmLabel: 'Yes, cancel',
        cancelLabel: 'Keep it',
        destructive: true,
        icon: Icons.event_busy_rounded);
    if (!ok || !mounted) return;
    ref.read(appointmentsProvider.notifier).cancel(widget.appointment.id, reason);
    final messenger = ScaffoldMessenger.of(context);
    final paid = widget.appointment.paid;
    final fee = widget.appointment.fee;
    Navigator.of(context).pop();
    widget.onCancelled?.call();
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(paid ? 'Appointment cancelled. ${rupees(fee)} refund in 3–5 days' : 'Appointment cancelled'),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ));
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Tell us why you are cancelling', style: context.tt.bodyMedium),
      const SizedBox(height: 12),
      for (final r in _cancelReasons)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: TapScale(
            onTap: () => setState(() => _reason = r),
            scale: .98,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: _reason == r ? p.primarySoft : p.surface,
                borderRadius: AppRadius.rMd,
                border: Border.all(color: _reason == r ? p.primary : p.border),
              ),
              child: Row(children: [
                Expanded(child: Text(r, style: context.tt.titleSmall)),
                Icon(_reason == r ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded, color: _reason == r ? p.primary : p.textTertiary, size: 22),
              ]),
            ),
          ),
        ),
      const SizedBox(height: 12),
      AppButton(label: 'Cancel appointment', variant: AppButtonVariant.danger, onPressed: _reason == null ? null : _submit),
    ]);
  }
}

// ───────────────────────── Rate ─────────────────────────

Future<void> showRateSheet(BuildContext context, Doctor doctor) {
  return showAppBottomSheet<void>(context, title: 'Rate your visit', builder: (_) => _RateBody(doctor: doctor));
}

class _RateBody extends StatefulWidget {
  const _RateBody({required this.doctor});
  final Doctor doctor;
  @override
  State<_RateBody> createState() => _RateBodyState();
}

class _RateBodyState extends State<_RateBody> {
  int _stars = 0;
  final _c = TextEditingController();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Column(children: [
      DoctorAvatar(doctor: widget.doctor, size: 72, hero: false),
      const SizedBox(height: 10),
      Text(widget.doctor.name, style: context.tt.titleMedium),
      Text('How was your experience?', style: context.tt.bodyMedium),
      const SizedBox(height: 16),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        for (var i = 1; i <= 5; i++)
          TapScale(
            onTap: () => setState(() => _stars = i),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: AnimatedScale(
                scale: i <= _stars ? 1.12 : 1,
                duration: const Duration(milliseconds: 180),
                child: Icon(i <= _stars ? Icons.star_rounded : Icons.star_outline_rounded, size: 42, color: i <= _stars ? AppColors.star : p.textTertiary),
              ),
            ),
          ),
      ]),
      const SizedBox(height: 16),
      AppTextField(controller: _c, hint: 'Share a few words (optional)', maxLines: 3),
      const SizedBox(height: 20),
      AppButton(
        label: 'Submit review',
        onPressed: _stars == 0
            ? null
            : () {
                showAppSnack(context, 'Thanks for your $_stars★ review!', icon: Icons.favorite_rounded);
                Navigator.of(context).pop();
              },
      ),
    ]);
  }
}
