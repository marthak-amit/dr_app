import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/utils/app_config.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../data/repositories/providers.dart';
import '../widgets/dosage_view.dart';
import '../widgets/signature_painter.dart';

class PrescriptionDetailScreen extends ConsumerStatefulWidget {
  const PrescriptionDetailScreen({super.key, required this.prescriptionId});
  final String prescriptionId;

  @override
  ConsumerState<PrescriptionDetailScreen> createState() => _PrescriptionDetailScreenState();
}

class _PrescriptionDetailScreenState extends ConsumerState<PrescriptionDetailScreen> {
  bool _downloading = false;

  Future<void> _download() async {
    setState(() => _downloading = true);
    await Future<void>.delayed(const Duration(milliseconds: 1100));
    if (!mounted) return;
    setState(() => _downloading = false);
    showAppSnack(context, 'Prescription saved to Downloads (PDF)', icon: Icons.picture_as_pdf_rounded);
  }

  void _order(Prescription rx) {
    final total = rx.medicines.length * 118;
    showAppBottomSheet<void>(context, title: 'Order medicines', builder: (ctx) {
      final p = ctx.pal;
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: p.primarySoft, borderRadius: AppRadius.rMd),
          child: Row(children: [
            Icon(Icons.local_shipping_rounded, color: p.primary),
            const SizedBox(width: 12),
            Expanded(child: Text('${AppConfig.appName} Pharmacy · Delivery in 2 hours', style: ctx.tt.titleSmall!.copyWith(color: p.primary))),
          ]),
        ),
        const SizedBox(height: 14),
        for (final m in rx.medicines)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(children: [
              Icon(Icons.medication_rounded, size: 20, color: p.textTertiary),
              const SizedBox(width: 10),
              Expanded(child: Text('${m.name} ${m.strength}'.trim(), style: ctx.tt.bodyLarge, maxLines: 1, overflow: TextOverflow.ellipsis)),
              Text(rupees(118), style: ctx.tt.labelMedium),
            ]),
          ),
        const Divider(height: 28),
        Row(children: [Text('Total (free delivery)', style: ctx.tt.titleSmall), const Spacer(), Text(rupees(total), style: ctx.tt.titleLarge)]),
        const SizedBox(height: 18),
        AppButton(
          label: 'Place order',
          variant: AppButtonVariant.accent,
          onPressed: () {
            Navigator.pop(ctx);
            showAppSnack(context, 'Order placed! Arriving in about 2 hours.', icon: Icons.shopping_bag_rounded);
          },
        ),
      ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(prescriptionsProvider);
    final p = context.pal;
    return Scaffold(
      appBar: AppTopBar(title: 'Prescription', actions: [
        AppIconButton(icon: Icons.share_outlined, size: 42, onTap: () => showAppSnack(context, 'Share sheet opened (mock)', icon: Icons.ios_share_rounded), tooltip: 'Share'),
      ]),
      body: async.when(
        loading: () => const Padding(padding: EdgeInsets.all(20), child: ShimmerBox(height: 520, radius: 24)),
        error: (_, __) => ErrorState(onRetry: () => ref.invalidate(prescriptionsProvider)),
        data: (list) {
          final rx = list.where((e) => e.id == widget.prescriptionId).firstOrNull;
          if (rx == null) {
            return EmptyState(icon: Icons.description_outlined, title: 'Prescription not found', message: 'It may have been removed.', actionLabel: 'Back to list', onAction: () => context.pop());
          }
          final d = doctorById(rx.doctorId);
          final clinic = clinicById(d.clinicId);
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
            children: [
              Container(
                decoration: BoxDecoration(color: p.surface, borderRadius: AppRadius.rXl, border: Border.all(color: p.border), boxShadow: p.isDark ? null : [BoxShadow(color: p.shadow, blurRadius: 30, offset: const Offset(0, 12))]),
                clipBehavior: Clip.antiAlias,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // letterhead
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: const BoxDecoration(gradient: AppColors.gradientPrimary),
                    child: Row(children: [
                      Container(width: 46, height: 46, decoration: BoxDecoration(color: Colors.white.withValues(alpha: .2), borderRadius: AppRadius.rSm), child: const Icon(Icons.local_hospital_rounded, color: Colors.white, size: 26)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(clinic.name, style: context.tt.titleMedium!.copyWith(color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
                          Text(clinic.address, style: context.tt.bodySmall!.copyWith(color: Colors.white70, fontSize: 11), maxLines: 2, overflow: TextOverflow.ellipsis),
                        ]),
                      ),
                    ]),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        DoctorAvatar(doctor: d, size: 52, hero: false),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(d.name, style: context.tt.titleMedium),
                            Text(d.qualification, style: context.tt.bodySmall, maxLines: 2),
                            Text(d.specialty, style: context.tt.labelMedium!.copyWith(color: p.primary)),
                          ]),
                        ),
                      ]),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: AppRadius.rMd),
                        child: Row(children: [
                          Expanded(child: _Info(label: 'Patient', value: rx.patientName)),
                          Expanded(child: _Info(label: 'Date', value: fmtDateShort(rx.date))),
                          Expanded(child: _Info(label: 'Rx ID', value: rx.id.toUpperCase())),
                        ]),
                      ),
                      const SizedBox(height: 18),
                      Text('DIAGNOSIS', style: context.tt.labelSmall!.copyWith(letterSpacing: 1.2)),
                      const SizedBox(height: 4),
                      Text(rx.diagnosis, style: context.tt.titleMedium),
                      const SizedBox(height: 18),
                      Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Text('℞', style: TextStyle(fontSize: 38, fontWeight: FontWeight.w800, color: p.primary, height: 1)),
                        const SizedBox(width: 8),
                        Padding(padding: const EdgeInsets.only(bottom: 4), child: Text('Medicines', style: context.tt.titleMedium)),
                      ]),
                      const SizedBox(height: 10),
                      for (var i = 0; i < rx.medicines.length; i++) _MedicineTile(index: i + 1, m: rx.medicines[i]).animate().fadeIn(delay: (80 * i).ms).slideX(begin: .05),
                      if (rx.advice.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(color: p.warningSoft, borderRadius: AppRadius.rMd),
                          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Icon(Icons.lightbulb_rounded, color: p.warning, size: 20),
                            const SizedBox(width: 10),
                            Expanded(child: Text(rx.advice, style: context.tt.bodyMedium!.copyWith(color: p.textPrimary))),
                          ]),
                        ),
                      ],
                      if (rx.followUp != null) ...[
                        const SizedBox(height: 12),
                        Row(children: [
                          Icon(Icons.event_repeat_rounded, size: 18, color: p.primary),
                          const SizedBox(width: 8),
                          Expanded(child: Text('Follow-up: ${fmtDateLong(rx.followUp!)}', style: context.tt.labelLarge)),
                        ]),
                      ],
                      const SizedBox(height: 22),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [
                          SizedBox(width: 140, height: 46, child: CustomPaint(painter: SignaturePainter(p.primary, seed: d.name.length))),
                          Container(width: 150, height: 1, color: p.border),
                          const SizedBox(height: 4),
                          Text(d.name, style: context.tt.labelMedium),
                          Text('Digitally signed', style: context.tt.labelSmall),
                        ]),
                      ),
                    ]),
                  ),
                ]),
              ).animate().fadeIn(duration: 350.ms).slideY(begin: .06),
              const SizedBox(height: 20),
              AppButton(label: _downloading ? 'Preparing PDF…' : 'Download PDF', icon: Icons.download_rounded, loading: _downloading, onPressed: _download),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: AppButton(label: 'Reminders', icon: Icons.alarm_rounded, variant: AppButtonVariant.secondary, size: AppButtonSize.medium, onPressed: () => context.push(Routes.reminders))),
                const SizedBox(width: 12),
                Expanded(child: AppButton(label: 'Order meds', icon: Icons.shopping_bag_outlined, variant: AppButtonVariant.outline, size: AppButtonSize.medium, onPressed: () => _order(rx))),
              ]),
            ],
          );
        },
      ),
    );
  }
}

class _Info extends StatelessWidget {
  const _Info({required this.label, required this.value});
  final String label, value;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: context.tt.labelSmall),
        const SizedBox(height: 2),
        Text(value, style: context.tt.labelMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
      ]);
}

class _MedicineTile extends StatelessWidget {
  const _MedicineTile({required this.index, required this.m});
  final int index;
  final Medicine m;
  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(borderRadius: AppRadius.rMd, border: Border.all(color: p.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 26, height: 26, alignment: Alignment.center, decoration: BoxDecoration(color: p.primarySoft, shape: BoxShape.circle), child: Text('$index', style: context.tt.labelMedium!.copyWith(color: p.primary))),
          const SizedBox(width: 10),
          Expanded(child: Text('${m.name} ${m.strength}'.trim(), style: context.tt.titleSmall, maxLines: 2, overflow: TextOverflow.ellipsis)),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          DosageView(dosage: m.dosage),
          const Spacer(),
          Icon(Icons.timelapse_rounded, size: 16, color: p.textTertiary),
          const SizedBox(width: 4),
          Text(m.duration, style: context.tt.labelMedium),
        ]),
        const SizedBox(height: 8),
        Text(m.instructions, style: context.tt.bodySmall),
      ]),
    );
  }
}
