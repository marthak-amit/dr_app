import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/widgets.dart';
import '../../../../data/repositories/providers.dart';
import '../../../appointments/presentation/widgets/appointment_utils.dart';
import '../../providers/fee.dart';
import 'slot_picker.dart';

// ───────────────────────── Step 1 – slot ─────────────────────────

class SlotStep extends StatelessWidget {
  const SlotStep({super.key, required this.doctor, required this.type, required this.onType, required this.date, required this.onDate, required this.slot, required this.onSlot});
  final Doctor doctor;
  final ConsultType type;
  final ValueChanged<ConsultType> onType;
  final DateTime date;
  final ValueChanged<DateTime> onDate;
  final DateTime? slot;
  final ValueChanged<DateTime> onSlot;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final clinic = clinicById(doctor.clinicId);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      AppCard(
        padding: const EdgeInsets.all(12),
        child: Row(children: [
          DoctorAvatar(doctor: doctor, size: 58, hero: false),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(doctor.name, style: context.tt.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(doctor.specialty, style: context.tt.labelMedium!.copyWith(color: p.primary)),
            Text(clinic.name, style: context.tt.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(rupees(doctor.feeFor(type)), style: context.tt.titleMedium),
            Text('fee', style: context.tt.bodySmall),
          ]),
        ]),
      ),
      const SizedBox(height: 20),
      Text('Consultation type', style: context.tt.titleSmall),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(child: _TypeTile(icon: Icons.local_hospital_rounded, label: 'In-clinic', sub: rupees(doctor.fee), selected: type == ConsultType.inClinic, onTap: () => onType(ConsultType.inClinic))),
        const SizedBox(width: 12),
        Expanded(child: _TypeTile(icon: Icons.videocam_rounded, label: 'Video', sub: rupees(doctor.videoFee), selected: type == ConsultType.video, onTap: () => onType(ConsultType.video))),
      ]),
      const SizedBox(height: 24),
      Text('Select date', style: context.tt.titleSmall),
      const SizedBox(height: 10),
      DateStrip(selected: date, onChanged: onDate),
      const SizedBox(height: 24),
      Text('Select time', style: context.tt.titleSmall),
      const SizedBox(height: 12),
      SlotGrid(doctorId: doctor.id, date: date, selected: slot, onSelect: onSlot),
    ]);
  }
}

class _TypeTile extends StatelessWidget {
  const _TypeTile({required this.icon, required this.label, required this.sub, required this.selected, required this.onTap});
  final IconData icon;
  final String label, sub;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return TapScale(
      onTap: onTap,
      scale: .98,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? p.primarySoft : p.surface,
          borderRadius: AppRadius.rMd,
          border: Border.all(color: selected ? p.primary : p.border, width: selected ? 1.6 : 1),
        ),
        child: Row(children: [
          Icon(icon, color: selected ? p.primary : p.textTertiary, size: 24),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: context.tt.titleSmall, maxLines: 1),
            Text(sub, style: context.tt.bodySmall),
          ])),
          if (selected) Icon(Icons.check_circle_rounded, color: p.primary, size: 20),
        ]),
      ),
    );
  }
}

// ───────────────────────── Step 2 – patient ─────────────────────────

class PatientStep extends ConsumerWidget {
  const PatientStep({super.key, required this.selected, required this.onSelect});
  final Patient? selected;
  final ValueChanged<Patient> onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.pal;
    final async = ref.watch(familyProvider);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Who is this visit for?', style: context.tt.titleLarge),
      const SizedBox(height: 4),
      Text('Choose a family member or add a new one.', style: context.tt.bodyMedium),
      const SizedBox(height: 16),
      AsyncBody<List<Patient>>(
        value: async,
        onRetry: () => ref.invalidate(familyProvider),
        loading: const ShimmerList(itemCount: 3, itemHeight: 84, shrink: true, padding: EdgeInsets.zero),
        builder: (list) => Column(children: [
          for (final m in list)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TapScale(
                onTap: () => onSelect(m),
                scale: .98,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: selected?.id == m.id ? p.primarySoft : p.surface,
                    borderRadius: AppRadius.rLg,
                    border: Border.all(color: selected?.id == m.id ? p.primary : p.border, width: selected?.id == m.id ? 1.6 : 1),
                  ),
                  child: Row(children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: m.gender == Gender.female ? p.accentSoft : p.primarySoft,
                      child: Text(m.initials, style: context.tt.titleSmall!.copyWith(color: m.gender == Gender.female ? p.accent : p.primary)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(m.name, style: context.tt.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text('${m.relation} · ${m.age} yrs · ${m.gender == Gender.male ? 'Male' : 'Female'}', style: context.tt.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                    ])),
                    Icon(selected?.id == m.id ? Icons.check_circle_rounded : Icons.circle_outlined, color: selected?.id == m.id ? p.primary : p.textTertiary),
                  ]),
                ),
              ),
            ),
          TapScale(
            onTap: () => _showAdd(context, ref),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(borderRadius: AppRadius.rLg, border: Border.all(color: p.primary.withValues(alpha: .5), width: 1.4)),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.person_add_alt_1_rounded, color: p.primary, size: 20),
                const SizedBox(width: 8),
                Text('Add family member', style: context.tt.labelLarge!.copyWith(color: p.primary)),
              ]),
            ),
          ),
        ]),
      ),
    ]);
  }

  void _showAdd(BuildContext context, WidgetRef ref) {
    showAppBottomSheet<void>(context, title: 'Add family member', builder: (ctx) => _AddMemberForm(onAdd: (m) {
          ref.read(familyProvider.notifier).add(m);
          onSelect(m);
        }));
  }
}

class _AddMemberForm extends StatefulWidget {
  const _AddMemberForm({required this.onAdd});
  final ValueChanged<Patient> onAdd;
  @override
  State<_AddMemberForm> createState() => _AddMemberFormState();
}

class _AddMemberFormState extends State<_AddMemberForm> {
  final _name = TextEditingController();
  final _age = TextEditingController();
  String _rel = 'Father';
  Gender _gender = Gender.male;

  @override
  void dispose() {
    _name.dispose();
    _age.dispose();
    super.dispose();
  }

  void _save() {
    final age = int.tryParse(_age.text.trim());
    if (_name.text.trim().length < 2 || age == null || age < 0 || age > 120) {
      showAppSnack(context, 'Enter a valid name and age', error: true);
      return;
    }
    widget.onAdd(Patient(id: 'p${DateTime.now().millisecondsSinceEpoch}', name: _name.text.trim(), age: age, gender: _gender, phone: '+91 98765 43210', relation: _rel));
    showAppSnack(context, '${_name.text.trim()} added to your family', icon: Icons.group_add_rounded);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    const rels = ['Father', 'Mother', 'Spouse', 'Son', 'Daughter', 'Sibling', 'Other'];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      AppTextField(controller: _name, label: 'Full name', hint: 'e.g. Ramesh Marthak', prefixIcon: Icons.person_outline_rounded),
      const SizedBox(height: 14),
      AppTextField(controller: _age, label: 'Age', hint: 'Years', prefixIcon: Icons.cake_outlined, keyboardType: TextInputType.number, maxLength: 3, inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
      const SizedBox(height: 14),
      Text('Relation', style: context.tt.labelMedium!.copyWith(color: context.pal.textSecondary)),
      const SizedBox(height: 8),
      Wrap(spacing: 8, runSpacing: 8, children: [for (final r in rels) ChoicePill(label: r, selected: _rel == r, onTap: () => setState(() => _rel = r))]),
      const SizedBox(height: 14),
      Text('Gender', style: context.tt.labelMedium!.copyWith(color: context.pal.textSecondary)),
      const SizedBox(height: 8),
      Row(children: [
        ChoicePill(label: 'Male', icon: Icons.male_rounded, selected: _gender == Gender.male, onTap: () => setState(() => _gender = Gender.male)),
        const SizedBox(width: 8),
        ChoicePill(label: 'Female', icon: Icons.female_rounded, selected: _gender == Gender.female, onTap: () => setState(() => _gender = Gender.female)),
      ]),
      const SizedBox(height: 24),
      AppButton(label: 'Save member', onPressed: _save),
    ]);
  }
}

// ───────────────────────── Step 3 – reason ─────────────────────────

const symptomOptions = ['Fever', 'Cough & cold', 'Headache', 'Body pain', 'Fatigue', 'Chest discomfort', 'Skin rash', 'Stomach ache', 'Follow-up', 'Routine check-up'];

class ReasonStep extends StatelessWidget {
  const ReasonStep({super.key, required this.symptoms, required this.onToggle, required this.note});
  final Set<String> symptoms;
  final ValueChanged<String> onToggle;
  final TextEditingController note;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('What brings you in?', style: context.tt.titleLarge),
      const SizedBox(height: 4),
      Text('Select symptoms so the doctor can prepare.', style: context.tt.bodyMedium),
      const SizedBox(height: 16),
      Wrap(spacing: 8, runSpacing: 8, children: [for (final s in symptomOptions) ChoicePill(label: s, selected: symptoms.contains(s), onTap: () => onToggle(s))]),
      const SizedBox(height: 22),
      AppTextField(controller: note, label: 'Describe in your own words', hint: 'How long have you had this? Any medication you take?', maxLines: 4, maxLength: 300),
      const SizedBox(height: 16),
      TapScale(
        onTap: () => showAppSnack(context, 'Select a report from your Records vault (demo)', icon: Icons.attach_file_rounded),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: p.surface, borderRadius: AppRadius.rMd, border: Border.all(color: p.border)),
          child: Row(children: [
            Container(width: 40, height: 40, decoration: BoxDecoration(color: p.accentSoft, borderRadius: AppRadius.rSm), child: Icon(Icons.attach_file_rounded, color: p.accent, size: 20)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Attach a record', style: context.tt.titleSmall),
              Text('Share past reports with the doctor (optional)', style: context.tt.bodySmall),
            ])),
            Icon(Icons.add_circle_outline_rounded, color: p.primary),
          ]),
        ),
      ),
    ]);
  }
}

// ───────────────────────── Step 4 – summary ─────────────────────────

class SummaryStep extends StatelessWidget {
  const SummaryStep({super.key, required this.doctor, required this.type, required this.slot, required this.patient, required this.reason, required this.fee, required this.couponApplied, required this.coupon, required this.onApplyCoupon, required this.onRemoveCoupon});
  final Doctor doctor;
  final ConsultType type;
  final DateTime slot;
  final Patient patient;
  final String reason;
  final FeeBreakdown fee;
  final bool couponApplied;
  final TextEditingController coupon;
  final VoidCallback onApplyCoupon, onRemoveCoupon;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final clinic = clinicById(doctor.clinicId);
    Widget line(IconData i, String label, String value) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(i, size: 18, color: p.primary),
            const SizedBox(width: 10),
            SizedBox(width: 78, child: Text(label, style: context.tt.bodySmall)),
            Expanded(child: Text(value, style: context.tt.titleSmall)),
          ]),
        );
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Review your booking', style: context.tt.titleLarge),
      const SizedBox(height: 14),
      AppCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            DoctorAvatar(doctor: doctor, size: 56, hero: false),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(doctor.name, style: context.tt.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
              Text(doctor.specialty, style: context.tt.labelMedium!.copyWith(color: p.primary)),
            ])),
          ]),
          const SizedBox(height: 14),
          Divider(color: p.border),
          const SizedBox(height: 14),
          line(Icons.calendar_today_rounded, 'When', fmtWhen(slot)),
          line(type == ConsultType.video ? Icons.videocam_rounded : Icons.local_hospital_rounded, 'Type', typeLabel(type)),
          if (type == ConsultType.inClinic) line(Icons.location_on_rounded, 'Where', clinic.name),
          line(Icons.person_outline_rounded, 'Patient', '${patient.name} (${patient.relation})'),
          line(Icons.medical_information_outlined, 'Reason', reason),
        ]),
      ),
      const SizedBox(height: 16),
      // Coupon
      AppCard(
        padding: const EdgeInsets.all(14),
        child: couponApplied
            ? Row(children: [
                Container(width: 40, height: 40, decoration: BoxDecoration(color: p.successSoft, borderRadius: AppRadius.rSm), child: Icon(Icons.local_offer_rounded, color: p.success, size: 20)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${FeeBreakdown.couponCode} applied', style: context.tt.titleSmall),
                  Text('You save ${rupees(fee.discount)}', style: context.tt.bodySmall!.copyWith(color: p.success)),
                ])),
                TextButton(onPressed: onRemoveCoupon, child: Text('Remove', style: context.tt.labelMedium!.copyWith(color: p.danger))),
              ])
            : Row(children: [
                Expanded(
                  child: TextField(
                    controller: coupon,
                    textCapitalization: TextCapitalization.characters,
                    style: context.tt.titleSmall,
                    decoration: InputDecoration(hintText: 'Have a coupon? Try ${FeeBreakdown.couponCode}', prefixIcon: Icon(Icons.local_offer_outlined, size: 20, color: p.textTertiary), isDense: true),
                  ),
                ),
                const SizedBox(width: 10),
                AppButton(label: 'Apply', expand: false, size: AppButtonSize.medium, onPressed: onApplyCoupon),
              ]),
      ),
      const SizedBox(height: 16),
      AppCard(
        child: Column(children: [
          _Fee('Consultation fee', rupees(fee.consult)),
          if (couponApplied) _Fee('Coupon discount', '− ${rupees(fee.discount)}', color: p.success),
          _Fee('Platform fee', rupees(fee.platform)),
          _Fee('GST (18% on platform fee)', rupees(fee.gst)),
          const Divider(height: 24),
          Row(children: [Expanded(child: Text('Total payable', style: context.tt.titleMedium)), Text(rupees(fee.total), style: context.tt.titleLarge!.copyWith(color: p.primary))]),
        ]),
      ),
    ]);
  }
}

class _Fee extends StatelessWidget {
  const _Fee(this.label, this.value, {this.color});
  final String label, value;
  final Color? color;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(children: [
          Expanded(child: Text(label, style: context.tt.bodyMedium, maxLines: 1, overflow: TextOverflow.ellipsis)),
          Text(value, style: context.tt.titleSmall!.copyWith(color: color)),
        ]),
      );
}

// ───────────────────────── Step 5 – payment ─────────────────────────

class PaymentStep extends StatelessWidget {
  const PaymentStep({super.key, required this.type, required this.method, required this.onMethod, required this.upiApp, required this.onUpiApp, required this.upiId, required this.cardNumber, required this.cardExpiry, required this.cardCvv, required this.total});
  final ConsultType type;
  final PaymentMethod method;
  final ValueChanged<PaymentMethod> onMethod;
  final String? upiApp;
  final ValueChanged<String> onUpiApp;
  final TextEditingController upiId, cardNumber, cardExpiry, cardCvv;
  final int total;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    Widget tile(PaymentMethod m, String title, String sub, Widget? expanded) {
      final sel = method == m;
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          decoration: BoxDecoration(
            color: sel ? p.primarySoft.withValues(alpha: p.isDark ? .6 : .55) : p.surface,
            borderRadius: AppRadius.rLg,
            border: Border.all(color: sel ? p.primary : p.border, width: sel ? 1.6 : 1),
          ),
          child: Column(children: [
            TapScale(
              onTap: () => onMethod(m),
              scale: .99,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(children: [
                  Container(width: 42, height: 42, decoration: BoxDecoration(color: p.surface, borderRadius: AppRadius.rSm, border: Border.all(color: p.border)), child: Icon(paymentIcon(m), color: p.primary, size: 22)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: context.tt.titleSmall), Text(sub, style: context.tt.bodySmall)])),
                  Icon(sel ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded, color: sel ? p.primary : p.textTertiary),
                ]),
              ),
            ),
            if (sel && expanded != null) Padding(padding: const EdgeInsets.fromLTRB(14, 0, 14, 14), child: expanded),
          ]),
        ),
      );
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Choose payment method', style: context.tt.titleLarge),
      const SizedBox(height: 4),
      Text('Payable now: ${rupees(total)}  ·  100% secure (demo)', style: context.tt.bodyMedium),
      const SizedBox(height: 16),
      tile(
        PaymentMethod.upi,
        'UPI',
        'Google Pay, PhonePe, Paytm & more',
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final a in const ['Google Pay', 'PhonePe', 'Paytm', 'BHIM']) ChoicePill(label: a, selected: upiApp == a, onTap: () => onUpiApp(a)),
          ]),
          const SizedBox(height: 12),
          AppTextField(controller: upiId, hint: 'Or enter UPI ID  (name@upi)', prefixIcon: Icons.alternate_email_rounded, keyboardType: TextInputType.emailAddress),
        ]),
      ),
      tile(
        PaymentMethod.card,
        'Credit / Debit card',
        'Visa, Mastercard, RuPay',
        Column(children: [
          AppTextField(controller: cardNumber, hint: 'Card number', prefixIcon: Icons.credit_card_rounded, keyboardType: TextInputType.number, maxLength: 16, inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: AppTextField(controller: cardExpiry, hint: 'MM/YY', keyboardType: TextInputType.datetime, maxLength: 5)),
            const SizedBox(width: 10),
            Expanded(child: AppTextField(controller: cardCvv, hint: 'CVV', keyboardType: TextInputType.number, maxLength: 3, inputFormatters: [FilteringTextInputFormatter.digitsOnly])),
          ]),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () {
                cardNumber.text = '4111111111111111';
                cardExpiry.text = '12/29';
                cardCvv.text = '123';
              },
              child: Text('Fill test card', style: context.tt.labelMedium!.copyWith(color: p.primary)),
            ),
          ),
        ]),
      ),
      if (type == ConsultType.inClinic) tile(PaymentMethod.payAtClinic, 'Pay at clinic', 'Pay ${rupees(total)} at the reception', null),
    ]);
  }
}
