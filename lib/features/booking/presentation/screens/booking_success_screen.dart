import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/utils/app_config.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../data/repositories/providers.dart';
import '../../../appointments/presentation/widgets/appointment_utils.dart';
import '../../../appointments/providers/appointment_providers.dart';

class BookingSuccessScreen extends ConsumerWidget {
  const BookingSuccessScreen({super.key, required this.appointmentId});
  final String appointmentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.pal;
    final a = ref.watch(appointmentByIdProvider(appointmentId));
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.go(Routes.home);
      },
      child: Scaffold(
        body: SafeArea(
          child: a == null
              ? const ShimmerList(itemCount: 2, itemHeight: 220)
              : Column(children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(AppSpacing.screenH, 16, AppSpacing.screenH, 16),
                      child: Column(children: [
                        const _Hero(),
                        const SizedBox(height: 4),
                        Text('Appointment confirmed!', style: context.tt.headlineMedium, textAlign: TextAlign.center)
                            .animate(delay: 700.ms)
                            .fadeIn(duration: 400.ms)
                            .slideY(begin: .3, curve: Curves.easeOutCubic),
                        const SizedBox(height: 6),
                        Text(
                          a.type == ConsultType.video ? 'We will remind you before your video consult.' : 'Show this ticket at the clinic reception.',
                          style: context.tt.bodyMedium,
                          textAlign: TextAlign.center,
                        ).animate(delay: 800.ms).fadeIn(duration: 400.ms),
                        const SizedBox(height: 24),
                        _Ticket(a: a).animate(delay: 900.ms).fadeIn(duration: 450.ms).slideY(begin: .12, curve: Curves.easeOutCubic),
                        const SizedBox(height: 16),
                        Row(children: [
                          Expanded(
                            child: AppButton(
                              label: 'Add to calendar',
                              icon: Icons.event_available_rounded,
                              variant: AppButtonVariant.secondary,
                              size: AppButtonSize.medium,
                              onPressed: () => _calendarSheet(context, a),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppButton(
                              label: 'Share',
                              icon: Icons.ios_share_rounded,
                              variant: AppButtonVariant.outline,
                              size: AppButtonSize.medium,
                              onPressed: () => showAppSnack(context, 'Booking details copied – ready to share', icon: Icons.ios_share_rounded),
                            ),
                          ),
                        ]).animate(delay: 1000.ms).fadeIn(duration: 400.ms),
                      ]),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(AppSpacing.screenH, 12, AppSpacing.screenH, 12 + MediaQuery.of(context).padding.bottom * .3),
                    decoration: BoxDecoration(color: p.bg),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      AppButton(
                        label: 'View appointment',
                        onPressed: () {
                          context.go(Routes.home);
                          context.push(Routes.appointment(a.id));
                        },
                      ),
                      const SizedBox(height: 4),
                      AppButton(label: 'Back to home', variant: AppButtonVariant.text, size: AppButtonSize.medium, onPressed: () => context.go(Routes.home)),
                    ]),
                  ),
                ]),
        ),
      ),
    );
  }

  void _calendarSheet(BuildContext context, Appointment a) {
    showAppBottomSheet<void>(context, title: 'Add to calendar', builder: (ctx) {
      final p = ctx.pal;
      Widget opt(IconData i, String label, Color c) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: TapScale(
              onTap: () {
                showAppSnack(ctx, 'Added to $label – reminder 1 hour before', icon: Icons.event_available_rounded);
                Navigator.pop(ctx);
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: p.surface, borderRadius: AppRadius.rMd, border: Border.all(color: p.border)),
                child: Row(children: [
                  Container(width: 40, height: 40, decoration: BoxDecoration(color: c.withValues(alpha: .12), borderRadius: AppRadius.rSm), child: Icon(i, color: c, size: 22)),
                  const SizedBox(width: 12),
                  Expanded(child: Text(label, style: ctx.tt.titleSmall)),
                  Icon(Icons.add_rounded, color: p.textTertiary),
                ]),
              ),
            ),
          );
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('${doctorById(a.doctorId).name} · ${fmtWhen(a.dateTime)}', style: ctx.tt.bodyMedium),
        const SizedBox(height: 14),
        opt(Icons.calendar_month_rounded, 'Google Calendar', const Color(0xFF3B82F6)),
        opt(Icons.apple_rounded, 'Apple Calendar', const Color(0xFF8E8E93)),
        opt(Icons.mail_rounded, 'Outlook', const Color(0xFF0EA5E9)),
      ]);
    });
  }
}

/// Success Lottie with a burst of coral/teal dots behind it.
class _Hero extends StatelessWidget {
  const _Hero();
  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final colors = [p.primary, p.accent, p.warning, p.success];
    return SizedBox(
      height: 190,
      width: 240,
      child: Stack(alignment: Alignment.center, children: [
        for (var i = 0; i < 12; i++)
          Builder(builder: (_) {
            final ang = i * math.pi / 6;
            final r = 86.0 + (i.isEven ? 6 : -4);
            return Transform.translate(
              offset: Offset(math.cos(ang) * r, math.sin(ang) * r * .9),
              child: Container(width: i % 3 == 0 ? 10 : 7, height: i % 3 == 0 ? 10 : 7, decoration: BoxDecoration(shape: BoxShape.circle, color: colors[i % 4])),
            ).animate(delay: (350 + i * 30).ms).fadeIn(duration: 250.ms).scale(begin: const Offset(.2, .2), duration: 500.ms, curve: Curves.easeOutBack);
          }),
        SizedBox(
          width: 170,
          height: 170,
          child: Lottie.asset(
            'assets/lottie/success.json',
            repeat: false,
            errorBuilder: (_, __, ___) => Container(decoration: BoxDecoration(color: p.success, shape: BoxShape.circle), child: const Icon(Icons.check_rounded, color: Colors.white, size: 80)),
          ),
        ),
      ]),
    );
  }
}

class _Ticket extends StatelessWidget {
  const _Ticket({required this.a});
  final Appointment a;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final doc = doctorById(a.doctorId);
    final clinic = clinicById(a.clinicId);
    final video = a.type == ConsultType.video;
    final token = tokenFor(a);
    Widget cell(String l, String v) => Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l, style: context.tt.bodySmall),
            const SizedBox(height: 2),
            Text(v, style: context.tt.titleSmall, maxLines: 2, overflow: TextOverflow.ellipsis),
          ]),
        );
    return Container(
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: AppRadius.rXl,
        border: Border.all(color: p.border),
        boxShadow: p.isDark ? null : [BoxShadow(color: p.shadow, blurRadius: 28, offset: const Offset(0, 10))],
      ),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.all(18),
          child: Column(children: [
            Row(children: [
              DoctorAvatar(doctor: doc, size: 60, hero: false),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(doc.name, style: context.tt.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(doc.specialty, style: context.tt.labelMedium!.copyWith(color: p.primary)),
                Text(video ? 'Video consultation' : clinic.name, style: context.tt.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
              ])),
            ]),
            const SizedBox(height: 18),
            Row(children: [cell('Date', fmtDate(a.dateTime)), cell('Time', fmtTime(a.dateTime))]),
            const SizedBox(height: 14),
            Row(children: [cell('Patient', a.patientName), cell(video ? 'Mode' : 'Token', video ? 'Video call' : '#${token ?? '-'}')]),
            const SizedBox(height: 14),
            Row(children: [cell('Booking ID', bookingCode(a)), cell(a.paid ? 'Paid' : 'To pay at clinic', rupees(a.fee + platformFee + gstOn(platformFee)))]),
          ]),
        ),
        _Perforation(color: p.bg, border: p.border),
        Padding(
          padding: const EdgeInsets.all(18),
          child: Row(children: [
            Container(
              width: 84,
              height: 84,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: Colors.white, borderRadius: AppRadius.rSm, border: Border.all(color: p.border)),
              child: CustomPaint(painter: _QrPainter(seed: a.id.hashCode)),
            ),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Check-in code', style: context.tt.bodySmall),
              const SizedBox(height: 2),
              Text(bookingCode(a), style: context.tt.titleLarge!.copyWith(letterSpacing: 1.5)),
              const SizedBox(height: 4),
              Text(video ? 'Join from Visits tab when it is time.' : 'Scan at ${AppConfig.appName} kiosk or share with reception.', style: context.tt.bodySmall),
            ])),
          ]),
        ),
      ]),
    );
  }
}

class _Perforation extends StatelessWidget {
  const _Perforation({required this.color, required this.border});
  final Color color, border;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20,
      child: Stack(clipBehavior: Clip.none, children: [
        Positioned.fill(child: CustomPaint(painter: _DashPainter(border))),
        Positioned(left: -10, top: 0, child: Container(width: 20, height: 20, decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(color: border)))),
        Positioned(right: -10, top: 0, child: Container(width: 20, height: 20, decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(color: border)))),
      ]),
    );
  }
}

class _DashPainter extends CustomPainter {
  _DashPainter(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5;
    for (double x = 18; x < size.width - 18; x += 9) {
      canvas.drawLine(Offset(x, size.height / 2), Offset(x + 4, size.height / 2), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DashPainter old) => old.color != color;
}

/// Decorative QR-like pattern (deterministic from [seed]).
class _QrPainter extends CustomPainter {
  _QrPainter({required this.seed});
  final int seed;
  @override
  void paint(Canvas canvas, Size size) {
    const n = 21;
    final cell = size.width / n;
    final rnd = math.Random(seed);
    final paint = Paint()..color = const Color(0xFF10303A);
    bool finder(int x, int y) => (x < 7 && y < 7) || (x > n - 8 && y < 7) || (x < 7 && y > n - 8);
    for (var y = 0; y < n; y++) {
      for (var x = 0; x < n; x++) {
        if (finder(x, y)) continue;
        if (rnd.nextDouble() > .52) canvas.drawRect(Rect.fromLTWH(x * cell, y * cell, cell, cell), paint);
      }
    }
    void eye(int ox, int oy) {
      canvas.drawRect(Rect.fromLTWH(ox * cell, oy * cell, 7 * cell, 7 * cell), paint);
      canvas.drawRect(Rect.fromLTWH((ox + 1) * cell, (oy + 1) * cell, 5 * cell, 5 * cell), Paint()..color = Colors.white);
      canvas.drawRect(Rect.fromLTWH((ox + 2) * cell, (oy + 2) * cell, 3 * cell, 3 * cell), paint);
    }

    eye(0, 0);
    eye(n - 7, 0);
    eye(0, n - 7);
  }

  @override
  bool shouldRepaint(covariant _QrPainter old) => old.seed != seed;
}
