import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mediq/core/router/routes.dart';
import 'package:mediq/core/widgets/widgets.dart';
import 'package:mediq/data/repositories/providers.dart';

import '../../providers/search_providers.dart';
import '../widgets/filter_sheet.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key, this.specialtyId, this.autofocus = false});
  final String? specialtyId;
  final bool autofocus;

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.specialtyId != null) ref.read(searchFilterProvider.notifier).setSpecialty(widget.specialtyId);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _openFilters() async {
    final r = await showFilterSheet(context, ref.read(searchFilterProvider));
    if (r != null) ref.read(searchFilterProvider.notifier).set(r);
  }

  Future<void> _openSort() async {
    final cur = ref.read(searchFilterProvider);
    final r = await showSortSheet(context, cur.sort);
    if (r != null) ref.read(searchFilterProvider.notifier).set(cur.copyWith(sort: r));
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final f = ref.watch(searchFilterProvider);
    final q = ref.watch(searchQueryProvider);
    final results = ref.watch(searchResultsProvider);
    final notifier = ref.read(searchFilterProvider.notifier);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(children: [
              AppIconButton(icon: Icons.arrow_back_rounded, size: 44, onTap: () => context.canPop() ? context.pop() : context.go(Routes.home)),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(color: p.surface, borderRadius: AppRadius.rMd, border: Border.all(color: p.border)),
                  child: Row(children: [
                    Icon(Icons.search_rounded, color: p.textTertiary, size: 22),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _ctrl,
                        autofocus: widget.autofocus,
                        onChanged: (v) => ref.read(searchQueryProvider.notifier).state = v,
                        style: context.tt.titleSmall!.copyWith(fontWeight: FontWeight.w600),
                        cursorColor: p.primary,
                        decoration: InputDecoration(
                          hintText: 'Doctor, specialty…',
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          hintStyle: context.tt.bodyMedium!.copyWith(color: p.textTertiary),
                        ),
                      ),
                    ),
                    if (q.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          _ctrl.clear();
                          ref.read(searchQueryProvider.notifier).state = '';
                        },
                        child: Icon(Icons.close_rounded, color: p.textTertiary, size: 20),
                      ),
                  ]),
                ),
              ),
              const SizedBox(width: 12),
              Stack(clipBehavior: Clip.none, children: [
                AppIconButton(icon: Icons.tune_rounded, size: 48, color: f.activeCount > 0 ? Colors.white : p.textPrimary, bg: f.activeCount > 0 ? p.primary : p.surface, onTap: _openFilters, tooltip: 'Filters'),
                if (f.activeCount > 0)
                  Positioned(
                    right: -2,
                    top: -4,
                    child: Container(
                      width: 20,
                      height: 20,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: p.accent, shape: BoxShape.circle, border: Border.all(color: p.bg, width: 2)),
                      child: Text('${f.activeCount}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
                    ),
                  ),
              ]),
            ]),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                ChoicePill(label: 'All', selected: f.specialtyId == null, onTap: () => notifier.setSpecialty(null)),
                for (final s in mockSpecialties) ...[const SizedBox(width: 8), ChoicePill(label: s.name, selected: f.specialtyId == s.id, onTap: () => notifier.setSpecialty(s.id))],
              ],
            ),
          ),
          _ActiveChips(filter: f, onChange: notifier.set),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 12, 4),
            child: Row(children: [
              Expanded(
                child: Text(
                  results.hasValue ? '${_filtered(results.value!, q).length} doctors found' : 'Finding doctors…',
                  style: context.tt.labelMedium!.copyWith(color: p.textSecondary),
                ),
              ),
              TextButton.icon(
                onPressed: _openSort,
                icon: Icon(Icons.swap_vert_rounded, size: 18, color: p.primary),
                label: Text(f.sort == SortOption.relevance ? 'Sort' : f.sort.label.split(':').first, style: context.tt.labelMedium!.copyWith(color: p.primary)),
              ),
            ]),
          ),
          Expanded(
            child: RefreshIndicator(
              color: p.primary,
              onRefresh: () async {
                ref.invalidate(searchResultsProvider);
                await ref.read(searchResultsProvider.future);
              },
              child: results.when(
                loading: () => const ShimmerList(itemCount: 5, itemHeight: 168, padding: EdgeInsets.fromLTRB(20, 4, 20, 24)),
                error: (e, _) => ListView(children: [SizedBox(height: 400, child: ErrorState(onRetry: () => ref.invalidate(searchResultsProvider)))]),
                data: (list) {
                  final shown = _filtered(list, q);
                  if (shown.isEmpty) {
                    return ListView(physics: const AlwaysScrollableScrollPhysics(), children: [
                      SizedBox(
                        height: 420,
                        child: EmptyState(
                          icon: Icons.person_search_rounded,
                          title: 'No doctors found',
                          message: 'Try changing your search or removing some filters to see more results.',
                          actionLabel: 'Clear filters',
                          onAction: () {
                            _ctrl.clear();
                            ref.read(searchQueryProvider.notifier).state = '';
                            notifier.reset();
                          },
                        ),
                      ),
                    ]);
                  }
                  return ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(20, 4, 20, 24 + MediaQuery.of(context).padding.bottom),
                    itemCount: shown.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (_, i) {
                      final d = shown[i];
                      return DoctorCard(
                        doctor: d,
                        onTap: () => context.push(Routes.doctor(d.id)),
                        onBook: () => context.push(Routes.book(d.id)),
                      ).animate().fadeIn(delay: (50 * (i > 6 ? 6 : i)).ms, duration: 350.ms).slideY(begin: .06, end: 0, delay: (50 * (i > 6 ? 6 : i)).ms, duration: 350.ms);
                    },
                  );
                },
              ),
            ),
          ),
        ]),
      ),
    );
  }

  List<Doctor> _filtered(List<Doctor> list, String q) {
    final s = q.trim().toLowerCase();
    if (s.isEmpty) return list;
    return list.where((d) => d.name.toLowerCase().contains(s) || d.specialty.toLowerCase().contains(s) || clinicById(d.clinicId).name.toLowerCase().contains(s)).toList();
  }
}

class _ActiveChips extends StatelessWidget {
  const _ActiveChips({required this.filter, required this.onChange});
  final SearchFilter filter;
  final ValueChanged<SearchFilter> onChange;

  @override
  Widget build(BuildContext context) {
    final f = filter;
    final chips = <(String, SearchFilter)>[
      if (f.minRating != null) ('${f.minRating}+ rating', f.copyWith(clearRating: true)),
      if (f.feeActive) ('${rupees(f.fee.start)} – ${rupees(f.fee.end)}', f.copyWith(fee: const RangeValues(0, kMaxFee))),
      if (f.maxDistance != null) ('< ${f.maxDistance!.toInt()} km', f.copyWith(clearDistance: true)),
      if (f.availableToday) ('Available today', f.copyWith(availableToday: false)),
      if (f.gender != null) (f.gender == Gender.male ? 'Male' : 'Female', f.copyWith(clearGender: true)),
      if (f.language != null) (f.language!, f.copyWith(clearLanguage: true)),
    ];
    if (chips.isEmpty) return const SizedBox.shrink();
    final p = context.pal;
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
        itemCount: chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) => TapScale(
          onTap: () => onChange(chips[i].$2),
          child: Container(
            padding: const EdgeInsets.only(left: 12, right: 8),
            decoration: BoxDecoration(color: p.primarySoft, borderRadius: AppRadius.rPill),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(chips[i].$1, style: context.tt.labelSmall!.copyWith(color: p.primary, fontWeight: FontWeight.w700)),
              const SizedBox(width: 4),
              Icon(Icons.close_rounded, size: 14, color: p.primary),
            ]),
          ),
        ),
      ),
    );
  }
}
