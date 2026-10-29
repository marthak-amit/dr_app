import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../data/repositories/providers.dart';
import '../../providers/fee.dart';
import '../widgets/booking_stepper.dart';
import '../widgets/booking_steps.dart';
import '../widgets/slot_picker.dart';

const _stepLabels = ['Time slot', 'Patient', 'Reason', 'Summary', 'Payment'];

class BookingScreen extends ConsumerStatefulWidget {
  const BookingScreen({super.key, required this.doctorId, this.type, this.rescheduleId});
  final String doctorId;
  final String? type; // 'clinic' | 'video'
  final String? rescheduleId;

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  int _step = 0;
  late ConsultType _type = widget.type == 'video' ? ConsultType.video : ConsultType.inClinic;
  DateTime _date = dateOnly(DateTime.now());
  DateTime? _slot;
  Patient? _patient;
  final Set<String> _symptoms = {};
  final _note = TextEditingController();
  final _coupon = TextEditingController();
  bool _couponApplied = false;
  PaymentMethod _method = PaymentMethod.upi;
  String? _upiApp;
  final _upiId = TextEditingController();
  final _cardNumber = TextEditingController();
  final _cardExpiry = TextEditingController();
  final _cardCvv = TextEditingController();
  bool _processing = false;
  bool _forward = true;

  bool get _isReschedule => widget.rescheduleId != null;
  int get _lastStep => _isReschedule ? 0 : 4;
  Doctor get _doctor => doctorById(widget.doctorId);

  @override
  void dispose() {
    for (final c in [_note, _coupon, _upiId, _cardNumber, _cardExpiry, _cardCvv]) {
      c.dispose();
    }
    super.dispose();
  }

  String get _reason {
    final parts = [..._symptoms, if (_note.text.trim().isNotEmpty) _note.text.trim()];
    return parts.isEmpty ? 'General consultation' : parts.join(', ');
  }

  FeeBreakdown get _fee {
    final consult = _doctor.feeFor(_type);
    return FeeBreakdown(consult: consult, discount: _couponApplied ? FeeBreakdown.couponDiscount(consult) : 0);
  }

  bool get _canContinue => switch (_step) {
        0 => _slot != null,
        1 => _patient != null,
        _ => true,
      };

  String get _ctaLabel => switch (_step) {
        0 => _isReschedule ? 'Confirm new time' : (_slot == null ? 'Select a time slot' : 'Continue'),
        1 => 'Continue',
        2 => 'Review summary',
        3 => 'Proceed to payment',
        _ => _method == PaymentMethod.payAtClinic ? 'Confirm booking' : 'Pay ${rupees(_fee.total)}',
      };

  void _goStep(int s) => setState(() {
        _forward = s > _step;
        _step = s;
      });

  void _back() {
    if (_processing) return;
    if (_step > 0) {
      _goStep(_step - 1);
    } else {
      context.canPop() ? context.pop() : context.go(Routes.home);
    }
  }

  void _applyCoupon() {
    final code = _coupon.text.trim().toUpperCase();
    if (code == FeeBreakdown.couponCode) {
      setState(() => _couponApplied = true);
      showAppSnack(context, 'Coupon applied – you save ${rupees(FeeBreakdown.couponDiscount(_doctor.feeFor(_type)))}', icon: Icons.local_offer_rounded);
    } else {
      showAppSnack(context, code.isEmpty ? 'Enter a coupon code' : 'Invalid coupon. Try ${FeeBreakdown.couponCode}', error: true);
    }
  }

  Future<void> _next() async {
    if (!_canContinue || _processing) return;
    if (_isReschedule) return _reschedule();
    if (_step < 4) return _goStep(_step + 1);
    return _pay();
  }

  Future<void> _reschedule() async {
    setState(() => _processing = true);
    await fakeLatency(600, 900);
    if (!mounted) return;
    final id = widget.rescheduleId!;
    ref.read(appointmentsProvider.notifier).reschedule(id, _slot!);
    showAppSnack(context, 'Rescheduled to ${fmtWhen(_slot!)}', icon: Icons.event_available_rounded);
    context.pop();
  }

  String? _validatePayment() {
    switch (_method) {
      case PaymentMethod.upi:
        if (_upiApp == null && !_upiId.text.contains('@')) return 'Pick a UPI app or enter a valid UPI ID';
      case PaymentMethod.card:
        if (_cardNumber.text.length < 12 || _cardExpiry.text.length < 4 || _cardCvv.text.length < 3) return 'Enter complete card details (tap “Fill test card”)';
      case PaymentMethod.payAtClinic:
        break;
    }
    return null;
  }

  Future<void> _pay() async {
    final err = _validatePayment();
    if (err != null) {
      showAppSnack(context, err, error: true);
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _processing = true);
    await Future<void>.delayed(const Duration(milliseconds: 1600));
    if (!mounted) return;
    final d = _doctor;
    final appt = ref.read(appointmentsProvider.notifier).add(
          doctorId: d.id,
          clinicId: d.clinicId,
          dateTime: _slot!,
          type: _type,
          patientName: _patient!.name,
          reason: _reason,
          fee: _fee.consult - _fee.discount,
          payment: _method,
        );
    context.pushReplacement(Routes.bookingSuccess(appt.id));
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    // Preselect first family member once loaded.
    final family = ref.watch(familyProvider).valueOrNull;
    if (_patient == null && family != null && family.isNotEmpty) _patient = family.first;

    final doc = _doctor;
    final fee = _fee;
    final steps = <Widget>[
      SlotStep(
        doctor: doc,
        type: _type,
        onType: (t) => setState(() {
          _type = t;
          if (t == ConsultType.video && _method == PaymentMethod.payAtClinic) _method = PaymentMethod.upi;
        }),
        date: _date,
        onDate: (d) => setState(() {
          _date = d;
          _slot = null;
        }),
        slot: _slot,
        onSlot: (s) => setState(() => _slot = s),
      ),
      PatientStep(selected: _patient, onSelect: (m) => setState(() => _patient = m)),
      ReasonStep(
        symptoms: _symptoms,
        onToggle: (s) => setState(() => _symptoms.contains(s) ? _symptoms.remove(s) : _symptoms.add(s)),
        note: _note,
      ),
      if (_slot != null && _patient != null)
        SummaryStep(
          doctor: doc,
          type: _type,
          slot: _slot!,
          patient: _patient!,
          reason: _reason,
          fee: fee,
          couponApplied: _couponApplied,
          coupon: _coupon,
          onApplyCoupon: _applyCoupon,
          onRemoveCoupon: () => setState(() {
            _couponApplied = false;
            _coupon.clear();
          }),
        )
      else
        const SizedBox.shrink(),
      PaymentStep(
        type: _type,
        method: _method,
        onMethod: (m) => setState(() => _method = m),
        upiApp: _upiApp,
        onUpiApp: (a) => setState(() => _upiApp = a),
        upiId: _upiId,
        cardNumber: _cardNumber,
        cardExpiry: _cardExpiry,
        cardCvv: _cardCvv,
        total: fee.total,
      ),
    ];

    return PopScope(
      canPop: _step == 0 && !_processing,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Stack(children: [
        Scaffold(
          appBar: AppTopBar(title: _isReschedule ? 'Reschedule' : 'Book appointment', onBack: _back),
          body: Column(children: [
            if (!_isReschedule) BookingStepper(step: _step, labels: _stepLabels),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                switchInCurve: Curves.easeOutCubic,
                transitionBuilder: (child, anim) {
                  final incoming = child.key == ValueKey(_step);
                  final dx = (_forward ? 1 : -1) * (incoming ? .08 : -.08);
                  return FadeTransition(
                    opacity: anim,
                    child: SlideTransition(position: Tween(begin: Offset(dx, 0), end: Offset.zero).animate(anim), child: child),
                  );
                },
                child: SingleChildScrollView(
                  key: ValueKey(_step),
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(AppSpacing.screenH, 12, AppSpacing.screenH, 24),
                  child: steps[_step],
                ),
              ),
            ),
            _BottomBar(
              label: _ctaLabel,
              enabled: _canContinue,
              total: fee.total,
              showTotal: _step >= 1 && !_isReschedule,
              onTap: _next,
              accent: _step == _lastStep && !_isReschedule,
            ),
          ]),
        ),
        if (_processing && !_isReschedule) _ProcessingOverlay(method: _method),
        if (_processing && _isReschedule) Positioned.fill(child: ColoredBox(color: p.bg.withValues(alpha: .6), child: const Center(child: CircularProgressIndicator()))),
      ]),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.label, required this.enabled, required this.onTap, required this.total, required this.showTotal, required this.accent});
  final String label;
  final bool enabled, showTotal, accent;
  final VoidCallback onTap;
  final int total;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Container(
      padding: EdgeInsets.fromLTRB(AppSpacing.screenH, 14, AppSpacing.screenH, 14 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(color: p.surface, border: Border(top: BorderSide(color: p.border)), boxShadow: [BoxShadow(color: p.shadow, blurRadius: 20, offset: const Offset(0, -4))]),
      child: Row(children: [
        if (showTotal) ...[
          Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            Text('Total', style: context.tt.bodySmall),
            Text(rupees(total), style: context.tt.titleLarge),
          ]),
          const SizedBox(width: 16),
        ],
        Expanded(child: AppButton(label: label, onPressed: enabled ? onTap : null, variant: accent ? AppButtonVariant.accent : AppButtonVariant.primary, trailingIcon: enabled ? Icons.arrow_forward_rounded : null)),
      ]),
    );
  }
}

class _ProcessingOverlay extends StatelessWidget {
  const _ProcessingOverlay({required this.method});
  final PaymentMethod method;
  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Positioned.fill(
      child: Material(
        color: Colors.black.withValues(alpha: .55),
        child: Center(
          child: Container(
            width: 240,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: p.surface, borderRadius: AppRadius.rXl),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              SizedBox(
                width: 96,
                height: 96,
                child: Lottie.asset('assets/lottie/loading.json', repeat: true, errorBuilder: (_, __, ___) => const Center(child: CircularProgressIndicator())),
              ),
              const SizedBox(height: 8),
              Text(method == PaymentMethod.payAtClinic ? 'Confirming booking…' : 'Processing payment…', style: context.tt.titleSmall, textAlign: TextAlign.center),
              const SizedBox(height: 4),
              Text('Please do not close the app', style: context.tt.bodySmall, textAlign: TextAlign.center),
            ]),
          ),
        ),
      ),
    );
  }
}
