import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/widgets/widgets.dart';
import '../../../../data/repositories/providers.dart';
import '../../providers/lab_cart_provider.dart';

const _slots = ['06:00 – 08:00 AM', '08:00 – 10:00 AM', '10:00 – 12:00 PM', '12:00 – 02:00 PM', '02:00 – 04:00 PM', '04:00 – 06:00 PM'];
const _slotStart = [6, 8, 10, 12, 14, 16];

/// Full-height bottom sheet: address → slot & patient → summary & payment → success.
Future<void> showLabBookingFlow(BuildContext context, {required CartSummary cart, required VoidCallback onDone}) {
  return showAppBottomSheet<void>(
    context,
    title: 'Home sample collection',
    scrollable: false,
    fullHeight: true,
    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
    builder: (ctx) => _Flow(cart: cart, onDone: onDone),
  );
}

class _Flow extends ConsumerStatefulWidget {
  const _Flow({required this.cart, required this.onDone});
  final CartSummary cart;
  final VoidCallback onDone;

  @override
  ConsumerState<_Flow> createState() => _FlowState();
}

class _FlowState extends ConsumerState<_Flow> {
  int step = 0; // 3 = success
  final addresses = [...labAddresses];
  String addressId = labAddresses.first.id;
  int dayIdx = 0;
  int? slotIdx;
  String? patientId;
  PaymentMethod pay = PaymentMethod.upi;
  bool loading = false;
  String bookingId = '';

  late final days = List.generate(7, (i) => DateTime.now().add(Duration(days: i)));

  bool _slotDisabled(int day, int s) {
    if (day == 0 && _slotStart[s] <= DateTime.now().hour + 1) return true;
    return (day + s) % 4 == 0 && !(day == 0 && s == 0);
  }

  LabAddress get address => addresses.firstWhere((a) => a.id == addressId);

  Future<void> _confirm() async {
    setState(() => loading = true);
    await fakeLatency(900, 1400);
    if (!mounted) return;
    bookingId = 'LAB${100000 + Random().nextInt(899999)}';
    setState(() {
      loading = false;
      step = 3;
    });
  }

  @override
  Widget build(BuildContext context) {
    final family = ref.watch(familyProvider).valueOrNull ?? mockFamily;
    patientId ??= family.first.id;
    if (step == 3) return _success(context);
    return Column(children: [
      _Stepper(step: step),
      const SizedBox(height: 14),
      Expanded(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 240),
          child: SingleChildScrollView(key: ValueKey(step), child: switch (step) { 0 => _addressStep(context), 1 => _slotStep(context, family), _ => _summaryStep(context, family) }),
        ),
      ),
      const SizedBox(height: 12),
      _footer(context),
    ]);
  }

  Widget _footer(BuildContext context) {
    final canNext = step == 0 || (step == 1 && slotIdx != null);
    return Row(children: [
      if (step > 0) ...[
        Expanded(flex: 2, child: AppButton(label: 'Back', variant: AppButtonVariant.outline, onPressed: loading ? null : () => setState(() => step--))),
        const SizedBox(width: 12),
      ],
      Expanded(
        flex: 4,
        child: step < 2
            ? AppButton(label: 'Continue', trailingIcon: Icons.arrow_forward_rounded, onPressed: canNext ? () => setState(() => step++) : () => showAppSnack(context, 'Please choose a collection slot', error: true))
            : AppButton(label: 'Confirm · ${rupees(widget.cart.total)}', variant: AppButtonVariant.accent, loading: loading, onPressed: _confirm),
      ),
    ]);
  }

  // ── step 1
  Widget _addressStep(BuildContext context) {
    final p = context.pal;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Where should we collect the sample?', style: context.tt.titleMedium),
      const SizedBox(height: 12),
      for (final a in addresses)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: TapScale(
            onTap: () => setState(() => addressId = a.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: addressId == a.id ? p.primarySoft : p.surface, borderRadius: AppRadius.rLg, border: Border.all(color: addressId == a.id ? p.primary : p.border, width: addressId == a.id ? 1.6 : 1)),
              child: Row(children: [
                Container(width: 44, height: 44, decoration: BoxDecoration(color: p.surface, borderRadius: AppRadius.rMd), child: Center(child: SvgIcon(a.icon, size: 22, color: p.primary))),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(a.label, style: context.tt.titleSmall), Text(a.line, style: context.tt.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis)])),
                Icon(addressId == a.id ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded, color: addressId == a.id ? p.primary : p.textTertiary),
              ]),
            ),
          ),
        ),
      TapScale(
        onTap: () {
          setState(() {
            addresses.add(const LabAddress('ad3', 'Parents\' home', '45, Sarthana Jakatnaka, Surat 395006', 'house-plus'));
            addressId = 'ad3';
          });
          showAppSnack(context, 'New address added', icon: Icons.location_on_rounded);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(borderRadius: AppRadius.rLg, border: Border.all(color: p.primary.withValues(alpha: .5), width: 1.4)),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_location_alt_rounded, color: p.primary), const SizedBox(width: 8), Text('Add new address', style: context.tt.labelLarge!.copyWith(color: p.primary))]),
        ),
      ),
    ]);
  }

  // ── step 2
  Widget _slotStep(BuildContext context, List<Patient> family) {
    final p = context.pal;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Pick a date', style: context.tt.titleMedium),
      const SizedBox(height: 10),
      SizedBox(
        height: 78,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: days.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (_, i) {
            final d = days[i];
            final sel = i == dayIdx;
            return TapScale(
              onTap: () => setState(() {
                dayIdx = i;
                slotIdx = null;
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 58,
                decoration: BoxDecoration(color: sel ? p.primary : p.surface, borderRadius: AppRadius.rMd, border: Border.all(color: sel ? p.primary : p.border)),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(i == 0 ? 'Today' : ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][d.weekday - 1], style: context.tt.labelSmall!.copyWith(color: sel ? p.onPrimary : p.textSecondary)),
                  const SizedBox(height: 4),
                  Text('${d.day}', style: context.tt.titleLarge!.copyWith(color: sel ? p.onPrimary : p.textPrimary)),
                ]),
              ),
            );
          },
        ),
      ),
      const SizedBox(height: 18),
      Text('Collection slot', style: context.tt.titleMedium),
      const SizedBox(height: 10),
      LayoutBuilder(builder: (_, c) {
        final w = (c.maxWidth - 10) / 2;
        return Wrap(spacing: 10, runSpacing: 10, children: [
          for (var i = 0; i < _slots.length; i++) SizedBox(width: w, child: SlotChip(label: _slots[i], selected: slotIdx == i, disabled: _slotDisabled(dayIdx, i), onTap: () => setState(() => slotIdx = i))),
        ]);
      }),
      const SizedBox(height: 18),
      Text('Who is the test for?', style: context.tt.titleMedium),
      const SizedBox(height: 10),
      Wrap(spacing: 8, runSpacing: 8, children: [for (final f in family) ChoicePill(label: '${f.name.split(' ').first} · ${f.relation}', selected: patientId == f.id, onTap: () => setState(() => patientId = f.id))]),
    ]);
  }

  // ── step 3
  Widget _summaryStep(BuildContext context, List<Patient> family) {
    final p = context.pal;
    final c = widget.cart;
    final patient = family.firstWhere((f) => f.id == patientId, orElse: () => family.first);
    final d = days[dayIdx];
    Widget kv(String k, String v, {bool bold = false, Color? col}) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: Text(k, style: bold ? context.tt.titleSmall : context.tt.bodyMedium)),
            const SizedBox(width: 12),
            Flexible(child: Text(v, textAlign: TextAlign.right, style: (bold ? context.tt.titleMedium : context.tt.labelMedium)!.copyWith(color: col))),
          ]),
        );
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      AppCard(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Icon(Icons.event_available_rounded, color: p.primary, size: 20), const SizedBox(width: 8), Expanded(child: Text('${relativeDay(d)}, ${_slots[slotIdx ?? 0]}', style: context.tt.titleSmall))]),
        const SizedBox(height: 8),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(Icons.location_on_rounded, color: p.accent, size: 20), const SizedBox(width: 8), Expanded(child: Text('${address.label} · ${address.line}', style: context.tt.bodyMedium))]),
        const SizedBox(height: 8),
        Row(children: [Icon(Icons.person_rounded, color: p.textSecondary, size: 20), const SizedBox(width: 8), Expanded(child: Text('${patient.name} (${patient.relation})', style: context.tt.bodyMedium))]),
      ])),
      const SizedBox(height: 14),
      Text('Order summary', style: context.tt.titleMedium),
      const SizedBox(height: 8),
      for (final (t, q) in c.items) kv(q > 1 ? '${t.name} × $q' : t.name, rupees(t.price * q)),
      Divider(color: p.border),
      kv('Item total (MRP)', rupees(c.mrp)),
      kv('Discount', '− ${rupees(c.saved)}', col: p.success),
      kv('Home collection fee', 'FREE', col: p.success),
      Divider(color: p.border),
      kv('To pay', rupees(c.total), bold: true),
      const SizedBox(height: 14),
      Text('Payment method', style: context.tt.titleMedium),
      const SizedBox(height: 10),
      Wrap(spacing: 8, runSpacing: 8, children: [
        ChoicePill(label: 'UPI', icon: Icons.qr_code_2_rounded, selected: pay == PaymentMethod.upi, onTap: () => setState(() => pay = PaymentMethod.upi)),
        ChoicePill(label: 'Card', icon: Icons.credit_card_rounded, selected: pay == PaymentMethod.card, onTap: () => setState(() => pay = PaymentMethod.card)),
        ChoicePill(label: 'Pay on collection', icon: Icons.payments_rounded, selected: pay == PaymentMethod.payAtClinic, onTap: () => setState(() => pay = PaymentMethod.payAtClinic)),
      ]),
    ]);
  }

  Widget _success(BuildContext context) {
    final p = context.pal;
    final d = days[dayIdx];
    return Column(children: [
      Expanded(
        child: SingleChildScrollView(
          child: Column(children: [
            SizedBox(
              height: 170,
              child: Lottie.asset('assets/lottie/success.json', repeat: false, errorBuilder: (_, __, ___) => Icon(Icons.check_circle_rounded, size: 110, color: p.success)),
            ),
            Text('Booking confirmed!', style: context.tt.headlineSmall).animate().fadeIn(delay: 300.ms).slideY(begin: .2),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(color: p.primarySoft, borderRadius: AppRadius.rPill),
              child: Text('Booking ID  $bookingId', style: context.tt.labelMedium!.copyWith(color: p.primary)),
            ).animate().fadeIn(delay: 400.ms),
            const SizedBox(height: 18),
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                Container(width: 48, height: 48, decoration: BoxDecoration(color: p.successSoft, borderRadius: AppRadius.rMd), child: Icon(Icons.vaccines_rounded, color: p.success)),
                const SizedBox(width: 12),
                Expanded(child: Text('Our phlebotomist will arrive on ${relativeDay(d)} between ${_slots[slotIdx ?? 0]}.', style: context.tt.bodyMedium!.copyWith(color: p.textPrimary))),
              ]),
            ).animate().fadeIn(delay: 500.ms).slideY(begin: .15),
            const SizedBox(height: 12),
            Text('Please keep ${widget.cart.items.any((e) => e.$1.fasting) ? 'fasting for 10–12 hours before the sample.' : 'your ID handy at the time of collection.'}', textAlign: TextAlign.center, style: context.tt.bodySmall),
          ]),
        ),
      ),
      AppButton(
        label: 'Done',
        onPressed: () {
          widget.onDone();
          Navigator.of(context).pop();
        },
      ),
    ]);
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({required this.step});
  final int step;
  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    const labels = ['Address', 'Slot', 'Confirm'];
    return Row(children: [
      for (var i = 0; i < 3; i++) ...[
        if (i > 0) Expanded(child: Container(height: 2, margin: const EdgeInsets.symmetric(horizontal: 6), color: i <= step ? p.primary : p.border)),
        Column(children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: i <= step ? p.primary : p.surfaceAlt, shape: BoxShape.circle),
            child: i < step ? Icon(Icons.check_rounded, size: 16, color: p.onPrimary) : Text('${i + 1}', style: context.tt.labelSmall!.copyWith(color: i <= step ? p.onPrimary : p.textTertiary)),
          ),
          const SizedBox(height: 4),
          Text(labels[i], style: context.tt.labelSmall!.copyWith(color: i <= step ? p.primary : p.textTertiary)),
        ]),
      ],
    ]);
  }
}
