import 'package:flutter/material.dart';
import 'package:mediq/core/widgets/widgets.dart';
import 'package:mediq/data/repositories/providers.dart';

import 'map_snapshot.dart';

class StatTile extends StatelessWidget {
  const StatTile({super.key, required this.icon, required this.value, required this.label, required this.color, required this.bg});
  final IconData icon;
  final String value, label;
  final Color color, bg;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(color: p.surface, borderRadius: AppRadius.rLg, border: Border.all(color: p.border)),
      child: Column(children: [
        Container(width: 38, height: 38, decoration: BoxDecoration(color: bg, shape: BoxShape.circle), child: Icon(icon, size: 20, color: color)),
        const SizedBox(height: 8),
        FittedBox(fit: BoxFit.scaleDown, child: Text(value, style: context.tt.titleMedium)),
        Text(label, style: context.tt.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
      ]),
    );
  }
}

/// In-clinic / Video segmented toggle.
class ConsultToggle extends StatelessWidget {
  const ConsultToggle({super.key, required this.value, required this.onChanged, required this.doctor});
  final ConsultType value;
  final ValueChanged<ConsultType> onChanged;
  final Doctor doctor;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    Widget seg(ConsultType t, IconData icon, String label) {
      final sel = value == t;
      return Expanded(
        child: TapScale(
          onTap: () => onChanged(t),
          scale: .98,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: sel ? p.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              boxShadow: sel ? [BoxShadow(color: p.primary.withValues(alpha: .3), blurRadius: 12, offset: const Offset(0, 4))] : null,
            ),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(icon, size: 18, color: sel ? p.onPrimary : p.textSecondary),
                const SizedBox(width: 6),
                Flexible(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.tt.labelMedium!.copyWith(color: sel ? p.onPrimary : p.textPrimary))),
              ]),
              const SizedBox(height: 2),
              Text(rupees(doctor.feeFor(t)), style: context.tt.labelSmall!.copyWith(color: sel ? p.onPrimary.withValues(alpha: .85) : p.textSecondary)),
            ]),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(18)),
      child: Row(children: [
        seg(ConsultType.inClinic, Icons.local_hospital_rounded, 'In-clinic'),
        const SizedBox(width: 4),
        seg(ConsultType.video, Icons.videocam_rounded, 'Video call'),
      ]),
    );
  }
}

class ExpandableText extends StatefulWidget {
  const ExpandableText(this.text, {super.key});
  final String text;
  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool _open = false;
  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      AnimatedSize(
        duration: const Duration(milliseconds: 250),
        alignment: Alignment.topCenter,
        child: Text(widget.text, style: context.tt.bodyMedium!.copyWith(height: 1.6), maxLines: _open ? null : 3, overflow: _open ? TextOverflow.visible : TextOverflow.ellipsis),
      ),
      const SizedBox(height: 6),
      GestureDetector(
        onTap: () => setState(() => _open = !_open),
        behavior: HitTestBehavior.opaque,
        child: Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Text(_open ? 'Read less' : 'Read more', style: context.tt.labelMedium!.copyWith(color: p.primary))),
      ),
    ]);
  }
}

class ClinicCard extends StatelessWidget {
  const ClinicCard({super.key, required this.clinic});
  final Clinic clinic;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return AppCard(
      padding: EdgeInsets.zero,
      radius: AppRadius.xl,
      child: ClipRRect(
        borderRadius: AppRadius.rXl,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Stack(children: [
            SizedBox(height: 120, width: double.infinity, child: Image.asset(clinic.image, fit: BoxFit.cover, cacheWidth: 900)),
            Positioned(
              right: 12,
              top: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: p.surface.withValues(alpha: .92), borderRadius: AppRadius.rPill),
                child: RatingBadge(rating: clinic.rating),
              ),
            ),
          ]),
          Stack(children: [
            MapSnapshot(height: 130, seed: clinic.id.hashCode),
            Positioned(
              left: 12,
              bottom: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: p.surface.withValues(alpha: .95), borderRadius: AppRadius.rPill),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.directions_walk_rounded, size: 14, color: p.primary),
                  const SizedBox(width: 4),
                  Text('${clinic.distanceKm} km away', style: context.tt.labelSmall!.copyWith(color: p.textPrimary)),
                ]),
              ),
            ),
          ]),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(clinic.name, style: context.tt.titleMedium),
              const SizedBox(height: 8),
              _row(context, Icons.location_on_outlined, clinic.address),
              const SizedBox(height: 6),
              _row(context, Icons.schedule_rounded, clinic.openHours),
              const SizedBox(height: 6),
              _row(context, Icons.call_outlined, clinic.phone),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(child: AppButton(label: 'Call', icon: Icons.call_rounded, size: AppButtonSize.small, variant: AppButtonVariant.secondary, onPressed: () => showAppSnack(context, 'Calling ${clinic.phone}…', icon: Icons.call_rounded))),
                const SizedBox(width: 10),
                Expanded(child: AppButton(label: 'Get directions', icon: Icons.near_me_rounded, size: AppButtonSize.small, onPressed: () => showAppSnack(context, 'Opening directions to ${clinic.name}…', icon: Icons.near_me_rounded))),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _row(BuildContext context, IconData i, String t) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(i, size: 16, color: context.pal.textTertiary),
        const SizedBox(width: 8),
        Expanded(child: Text(t, style: context.tt.bodySmall!.copyWith(color: context.pal.textSecondary))),
      ]);
}

class ReviewTile extends StatelessWidget {
  const ReviewTile({super.key, required this.review});
  final Review review;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(radius: 18, backgroundColor: p.primarySoft, child: Text(review.author[0], style: context.tt.labelMedium!.copyWith(color: p.primary))),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(review.author, style: context.tt.titleSmall),
              Text('${review.daysAgo} days ago', style: context.tt.bodySmall),
            ]),
          ),
          RatingBadge(rating: review.rating),
        ]),
        const SizedBox(height: 8),
        Text(review.text, style: context.tt.bodyMedium!.copyWith(height: 1.5)),
      ]),
    );
  }
}

class RatingSummary extends StatelessWidget {
  const RatingSummary({super.key, required this.doctor});
  final Doctor doctor;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    // Mock distribution derived from the rating.
    final r = doctor.rating;
    final dist = [for (var i = 5; i >= 1; i--) i == 5 ? (r - 3.5) / 1.5 : i == 4 ? (5 - r) * .7 + .1 : i == 3 ? .05 : i == 2 ? .02 : .01];
    final total = dist.fold<double>(0, (a, b) => a + b);
    return Row(children: [
      Column(children: [
        Text(doctor.rating.toStringAsFixed(1), style: context.tt.displayMedium),
        Row(mainAxisSize: MainAxisSize.min, children: [for (var i = 0; i < 5; i++) Icon(i < doctor.rating.round() ? Icons.star_rounded : Icons.star_outline_rounded, size: 16, color: AppColors.star)]),
        const SizedBox(height: 4),
        Text('${doctor.reviewCount} reviews', style: context.tt.bodySmall),
      ]),
      const SizedBox(width: 20),
      Expanded(
        child: Column(children: [
          for (var i = 0; i < 5; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(children: [
                Text('${5 - i}', style: context.tt.labelSmall),
                const SizedBox(width: 8),
                Expanded(
                  child: ClipRRect(
                    borderRadius: AppRadius.rPill,
                    child: LinearProgressIndicator(value: (dist[i] / total).clamp(0, 1), minHeight: 6, backgroundColor: p.surfaceAlt, valueColor: const AlwaysStoppedAnimation(AppColors.star)),
                  ),
                ),
              ]),
            ),
        ]),
      ),
    ]);
  }
}
