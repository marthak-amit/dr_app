import 'package:flutter/material.dart';

import '../../data/repositories/providers.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import 'app_card.dart';
import 'tap_scale.dart';

/// Doctor portrait with Hero tag `doctor-<id>` (list → detail).
class DoctorAvatar extends StatelessWidget {
  const DoctorAvatar({super.key, required this.doctor, this.size = 72, this.radius, this.hero = true, this.heroSuffix = ''});
  final Doctor doctor;
  final double size;
  final double? radius;
  final bool hero;
  final String heroSuffix;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final img = ClipRRect(
      borderRadius: BorderRadius.circular(radius ?? size * .28),
      child: Container(
        width: size,
        height: size,
        color: p.primarySoft,
        child: Image.asset(doctor.photo, fit: BoxFit.cover, alignment: Alignment.topCenter, cacheWidth: (size * 3).round()),
      ),
    );
    return hero ? Hero(tag: '${doctor.heroTag}$heroSuffix', child: img) : img;
  }
}

/// Horizontal list card.
class DoctorCard extends StatelessWidget {
  const DoctorCard({super.key, required this.doctor, required this.onTap, this.onBook, this.heroSuffix = '', this.showClinic = true});
  final Doctor doctor;
  final VoidCallback onTap;
  final VoidCallback? onBook;
  final String heroSuffix;
  final bool showClinic;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final clinic = clinicById(doctor.clinicId);
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Column(children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          DoctorAvatar(doctor: doctor, size: 84, heroSuffix: heroSuffix),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(doctor.name, style: context.tt.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text(doctor.specialty, style: context.tt.labelMedium!.copyWith(color: p.primary)),
              const SizedBox(height: 6),
              Row(children: [
                RatingBadge(rating: doctor.rating, count: doctor.reviewCount),
                const SizedBox(width: 10),
                Flexible(child: Text('${doctor.experienceYears} yrs exp', style: context.tt.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis)),
              ]),
              if (showClinic) ...[
                const SizedBox(height: 6),
                Row(children: [
                  Icon(Icons.location_on_rounded, size: 14, color: p.textTertiary),
                  const SizedBox(width: 3),
                  Expanded(child: Text('${clinic.name} · ${clinic.distanceKm} km', style: context.tt.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis)),
                ]),
              ],
            ]),
          ),
        ]),
        const SizedBox(height: 12),
        Divider(color: p.border),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Consultation fee', style: context.tt.bodySmall),
              Text(rupees(doctor.fee), style: context.tt.titleMedium),
            ]),
          ),
          if (doctor.availableToday)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: StatusChip(label: 'Available today', color: p.success, bg: p.successSoft, icon: Icons.circle, dense: true),
            )
          else
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: StatusChip(label: doctor.nextAvailable.split(',').first, color: p.warning, bg: p.warningSoft, dense: true),
            ),
          TapScale(
            onTap: onBook ?? onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(gradient: AppColors.gradientAccent, borderRadius: AppRadius.rSm),
              child: Text('Book', style: context.tt.labelMedium!.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ),
        ]),
      ]),
    );
  }
}

/// Compact vertical card for the "Top doctors" carousel.
class DoctorCardVertical extends StatelessWidget {
  const DoctorCardVertical({super.key, required this.doctor, required this.onTap, this.width = 168});
  final Doctor doctor;
  final VoidCallback onTap;
  final double width;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return SizedBox(
      width: width,
      child: AppCard(
        onTap: onTap,
        padding: const EdgeInsets.all(10),
        radius: AppRadius.xl,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Stack(children: [
            Hero(
              tag: '${doctor.heroTag}-top',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  height: 132,
                  width: double.infinity,
                  color: p.primarySoft,
                  child: Image.asset(doctor.photo, fit: BoxFit.cover, alignment: Alignment.topCenter, cacheWidth: 480),
                ),
              ),
            ),
            Positioned(
              left: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: p.surface.withValues(alpha: .92), borderRadius: AppRadius.rPill),
                child: RatingBadge(rating: doctor.rating),
              ),
            ),
          ]),
          const SizedBox(height: 10),
          Text(doctor.name, style: context.tt.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(doctor.specialty, style: context.tt.bodySmall!.copyWith(color: p.primary), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 6),
          Row(children: [
            Text(rupees(doctor.fee), style: context.tt.labelMedium),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: p.primarySoft, shape: BoxShape.circle),
              child: Icon(Icons.arrow_outward_rounded, size: 14, color: p.primary),
            ),
          ]),
        ]),
      ),
    );
  }
}
