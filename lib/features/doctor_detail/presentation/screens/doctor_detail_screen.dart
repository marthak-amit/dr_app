import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mediq/core/router/routes.dart';
import 'package:mediq/core/widgets/widgets.dart';
import 'package:mediq/data/repositories/providers.dart';

import '../widgets/detail_sections.dart';

class DoctorDetailScreen extends ConsumerStatefulWidget {
  const DoctorDetailScreen({super.key, required this.doctorId, this.heroSuffix = ''});
  final String doctorId;
  final String heroSuffix;

  @override
  ConsumerState<DoctorDetailScreen> createState() => _DoctorDetailScreenState();
}

class _DoctorDetailScreenState extends ConsumerState<DoctorDetailScreen> {
  ConsultType _type = ConsultType.inClinic;
  bool _fav = false;

  String _k(int n) => n >= 1000 ? '${(n / 1000).toStringAsFixed(n >= 10000 ? 0 : 1)}k+' : '$n';

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final d = ref.watch(doctorProvider(widget.doctorId)); // sync → Hero can fly immediately
    final detail = ref.watch(doctorDetailProvider(widget.doctorId));
    final loaded = detail.hasValue;
    final clinic = clinicById(d.clinicId);

    return Scaffold(
      body: Stack(children: [
        RefreshIndicator(
          edgeOffset: 280,
          color: p.primary,
          onRefresh: () async {
            ref.invalidate(doctorDetailProvider(widget.doctorId));
            await ref.read(doctorDetailProvider(widget.doctorId).future);
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 330,
                backgroundColor: p.surface,
                surfaceTintColor: Colors.transparent,
                automaticallyImplyLeading: false,
                toolbarHeight: 64,
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  background: Hero(
                    tag: '${d.heroTag}${widget.heroSuffix}',
                    child: Container(
                      color: p.primarySoft,
                      child: Stack(fit: StackFit.expand, children: [
                        Image.asset(d.photo, fit: BoxFit.cover, alignment: const Alignment(0, -.2), cacheWidth: 1000),
                        const DecoratedBox(
                          decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x66000000), Color(0x00000000), Color(0x00000000)], stops: [0, .35, 1])),
                        ),
                      ]),
                    ),
                  ),
                ),
                leadingWidth: 0,
                titleSpacing: 16,
                title: Row(children: [
                  AppIconButton(icon: Icons.arrow_back_rounded, size: 42, bg: p.surface.withValues(alpha: .92), onTap: () => context.canPop() ? context.pop() : context.go(Routes.home)),
                  const Spacer(),
                  AppIconButton(
                    icon: _fav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    size: 42,
                    color: _fav ? p.accent : null,
                    bg: p.surface.withValues(alpha: .92),
                    onTap: () {
                      setState(() => _fav = !_fav);
                      showAppSnack(context, _fav ? '${d.name} added to favourites' : 'Removed from favourites', icon: _fav ? Icons.favorite_rounded : Icons.heart_broken_rounded);
                    },
                  ),
                  const SizedBox(width: 10),
                  AppIconButton(icon: Icons.ios_share_rounded, size: 42, bg: p.surface.withValues(alpha: .92), onTap: () => showAppSnack(context, 'Profile link copied to clipboard', icon: Icons.link_rounded)),
                ]),
              ),
              SliverToBoxAdapter(
                child: Container(
                  transform: Matrix4.translationValues(0, -1, 0),
                  decoration: BoxDecoration(color: p.bg),
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 140),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    // name block
                    Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(d.name, style: context.tt.headlineMedium),
                          const SizedBox(height: 2),
                          Text(d.specialty, style: context.tt.titleSmall!.copyWith(color: p.primary)),
                          const SizedBox(height: 4),
                          Text(d.qualification, style: context.tt.bodySmall),
                        ]),
                      ),
                      if (d.availableToday) StatusChip(label: 'Available today', color: p.success, bg: p.successSoft, icon: Icons.circle, dense: true),
                    ]).animate().fadeIn(duration: 350.ms).slideY(begin: .05, end: 0),
                    const SizedBox(height: 18),
                    Row(children: [
                      Expanded(child: StatTile(icon: Icons.groups_rounded, value: _k(d.patients), label: 'Patients', color: p.primary, bg: p.primarySoft)),
                      const SizedBox(width: 10),
                      Expanded(child: StatTile(icon: Icons.workspace_premium_rounded, value: '${d.experienceYears} yrs', label: 'Experience', color: p.accent, bg: p.accentSoft)),
                      const SizedBox(width: 10),
                      Expanded(child: StatTile(icon: Icons.star_rounded, value: d.rating.toStringAsFixed(1), label: '${d.reviewCount} reviews', color: p.warning, bg: p.warningSoft)),
                    ]).animate().fadeIn(delay: 80.ms, duration: 350.ms).slideY(begin: .05, end: 0),
                    const SizedBox(height: 22),
                    Text('Consultation type', style: context.tt.titleMedium),
                    const SizedBox(height: 10),
                    ConsultToggle(value: _type, doctor: d, onChanged: (t) => setState(() => _type = t)).animate().fadeIn(delay: 140.ms, duration: 350.ms),
                    const SizedBox(height: 8),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: Text(
                        _type == ConsultType.video ? 'Join from home — no travel, link shared 10 min before.' : 'Visit ${clinic.name}. Token-based queue with live tracking.',
                        key: ValueKey(_type),
                        style: context.tt.bodySmall,
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (!loaded) _bodyShimmer(detail.hasError, () => ref.invalidate(doctorDetailProvider(widget.doctorId))) else ..._body(context, d, clinic),
                  ]),
                ),
              ),
            ],
          ),
        ),
        // sticky bottom bar
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: EdgeInsets.fromLTRB(20, 14, 20, 14 + MediaQuery.of(context).padding.bottom),
            decoration: BoxDecoration(
              color: p.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [BoxShadow(color: p.shadow, blurRadius: 24, offset: const Offset(0, -6))],
            ),
            child: Row(children: [
              Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Consultation fee', style: context.tt.bodySmall),
                AnimatedSwitcher(duration: const Duration(milliseconds: 200), child: Text(rupees(d.feeFor(_type)), key: ValueKey(_type), style: context.tt.headlineSmall)),
              ]),
              const SizedBox(width: 16),
              Expanded(
                child: AppButton(
                  label: 'Book appointment',
                  variant: AppButtonVariant.accent,
                  trailingIcon: Icons.arrow_forward_rounded,
                  onPressed: () => context.push(Routes.book(d.id, type: _type == ConsultType.video ? 'video' : 'clinic')),
                ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _bodyShimmer(bool error, VoidCallback retry) {
    if (error) return SizedBox(height: 300, child: ErrorState(onRetry: retry));
    return const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ShimmerBox(width: 90, height: 20),
      SizedBox(height: 12),
      ShimmerBox(height: 14),
      SizedBox(height: 8),
      ShimmerBox(height: 14),
      SizedBox(height: 8),
      ShimmerBox(width: 220, height: 14),
      SizedBox(height: 28),
      ShimmerBox(height: 260, radius: 24),
      SizedBox(height: 24),
      ShimmerBox(height: 120, radius: 20),
    ]);
  }

  List<Widget> _body(BuildContext context, Doctor d, Clinic clinic) {
    final p = context.pal;
    Widget sec(int i, Widget w) => w.animate().fadeIn(delay: (60 * i).ms, duration: 380.ms).slideY(begin: .05, end: 0, delay: (60 * i).ms, duration: 380.ms);
    return [
      sec(0, Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('About ${d.shortName.split(' ').first}', style: context.tt.titleMedium),
        const SizedBox(height: 8),
        ExpandableText(d.about),
      ])),
      const SizedBox(height: 18),
      sec(1, Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Speaks', style: context.tt.titleMedium),
        const SizedBox(height: 10),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final l in d.languages)
            StatusChip(label: l, color: p.primary, bg: p.primarySoft, icon: Icons.translate_rounded),
        ]),
      ])),
      const SizedBox(height: 26),
      sec(2, Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Clinic', style: context.tt.titleMedium),
        const SizedBox(height: 12),
        ClinicCard(clinic: clinic),
      ])),
      const SizedBox(height: 26),
      sec(3, Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SectionHeader(title: 'Patient reviews', action: 'See all', onAction: () => _allReviews(context, d), padding: EdgeInsets.zero),
        const SizedBox(height: 14),
        AppCard(
          child: Column(children: [
            RatingSummary(doctor: d),
            Divider(color: p.border, height: 28),
            for (var i = 0; i < d.reviews.length.clamp(0, 2); i++) ...[
              if (i > 0) Divider(color: p.border, height: 1),
              ReviewTile(review: d.reviews[i]),
            ],
            const SizedBox(height: 4),
            AppButton(label: 'See all ${d.reviews.length} reviews', variant: AppButtonVariant.secondary, size: AppButtonSize.medium, onPressed: () => _allReviews(context, d)),
          ]),
        ),
      ])),
    ];
  }

  void _allReviews(BuildContext context, Doctor d) {
    showAppBottomSheet<void>(
      context,
      title: 'Reviews for ${d.name}',
      fullHeight: true,
      builder: (ctx) => Column(children: [
        for (var i = 0; i < d.reviews.length; i++) ...[
          if (i > 0) Divider(color: ctx.pal.border, height: 1),
          ReviewTile(review: d.reviews[i]),
        ],
      ]),
    );
  }
}
