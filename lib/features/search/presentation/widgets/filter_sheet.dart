import 'package:flutter/material.dart';
import 'package:mediq/core/widgets/widgets.dart';
import 'package:mediq/data/repositories/providers.dart';

import '../../providers/search_providers.dart';

/// Opens the filter sheet; returns the applied filter (or null if dismissed).
Future<SearchFilter?> showFilterSheet(BuildContext context, SearchFilter initial) {
  return showAppBottomSheet<SearchFilter>(
    context,
    title: 'Filters',
    fullHeight: true,
    builder: (ctx) => _FilterBody(initial: initial),
  );
}

class _FilterBody extends StatefulWidget {
  const _FilterBody({required this.initial});
  final SearchFilter initial;
  @override
  State<_FilterBody> createState() => _FilterBodyState();
}

class _FilterBodyState extends State<_FilterBody> {
  late SearchFilter f = widget.initial;

  Widget _label(String t) => Padding(padding: const EdgeInsets.only(top: 22, bottom: 10), child: Text(t, style: context.tt.titleSmall));

  Widget _wrap(List<Widget> c) => Wrap(spacing: 8, runSpacing: 8, children: c);

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final specs = mockSpecialties;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _label('Specialty'),
      _wrap([
        ChoicePill(label: 'All', selected: f.specialtyId == null, onTap: () => setState(() => f = f.copyWith(clearSpecialty: true))),
        for (final s in specs) ChoicePill(label: s.name, selected: f.specialtyId == s.id, onTap: () => setState(() => f = f.copyWith(specialtyId: s.id))),
      ]),
      _label('Minimum rating'),
      _wrap([
        ChoicePill(label: 'Any', selected: f.minRating == null, onTap: () => setState(() => f = f.copyWith(clearRating: true))),
        for (final r in [4.0, 4.5, 4.8]) ChoicePill(label: '$r+', icon: Icons.star_rounded, selected: f.minRating == r, onTap: () => setState(() => f = f.copyWith(minRating: r))),
      ]),
      _label('Consultation fee'),
      Row(children: [
        Text(rupees(f.fee.start), style: context.tt.labelMedium),
        const Spacer(),
        Text(f.fee.end >= kMaxFee ? '${rupees(kMaxFee)}+' : rupees(f.fee.end), style: context.tt.labelMedium),
      ]),
      RangeSlider(
        values: f.fee,
        min: 0,
        max: kMaxFee,
        divisions: 15,
        activeColor: p.primary,
        inactiveColor: p.border,
        onChanged: (v) => setState(() => f = f.copyWith(fee: v)),
      ),
      _label('Distance'),
      _wrap([
        ChoicePill(label: 'Any', selected: f.maxDistance == null, onTap: () => setState(() => f = f.copyWith(clearDistance: true))),
        for (final d in [3.0, 5.0, 10.0]) ChoicePill(label: '< ${d.toInt()} km', selected: f.maxDistance == d, onTap: () => setState(() => f = f.copyWith(maxDistance: d))),
      ]),
      _label('Doctor gender'),
      _wrap([
        ChoicePill(label: 'Any', selected: f.gender == null, onTap: () => setState(() => f = f.copyWith(clearGender: true))),
        ChoicePill(label: 'Male', icon: Icons.male_rounded, selected: f.gender == Gender.male, onTap: () => setState(() => f = f.copyWith(gender: Gender.male))),
        ChoicePill(label: 'Female', icon: Icons.female_rounded, selected: f.gender == Gender.female, onTap: () => setState(() => f = f.copyWith(gender: Gender.female))),
      ]),
      _label('Language'),
      _wrap([
        ChoicePill(label: 'Any', selected: f.language == null, onTap: () => setState(() => f = f.copyWith(clearLanguage: true))),
        for (final l in kLanguages) ChoicePill(label: l, selected: f.language == l, onTap: () => setState(() => f = f.copyWith(language: l))),
      ]),
      const SizedBox(height: 18),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: AppRadius.rMd),
        child: Row(children: [
          Icon(Icons.bolt_rounded, color: p.success),
          const SizedBox(width: 10),
          Expanded(child: Text('Available today', style: context.tt.titleSmall)),
          Switch(value: f.availableToday, onChanged: (v) => setState(() => f = f.copyWith(availableToday: v))),
        ]),
      ),
      const SizedBox(height: 24),
      Row(children: [
        Expanded(child: AppButton(label: 'Reset', variant: AppButtonVariant.outline, onPressed: () => setState(() => f = SearchFilter(sort: f.sort)))),
        const SizedBox(width: 12),
        Expanded(flex: 2, child: AppButton(label: f.activeCount == 0 ? 'Apply' : 'Apply (${f.activeCount})', onPressed: () => Navigator.pop(context, f))),
      ]),
    ]);
  }
}

Future<SortOption?> showSortSheet(BuildContext context, SortOption current) {
  return showAppBottomSheet<SortOption>(
    context,
    title: 'Sort by',
    builder: (ctx) {
      final p = ctx.pal;
      return Column(children: [
        for (final s in SortOption.values)
          InkWell(
            borderRadius: AppRadius.rMd,
            onTap: () => Navigator.pop(ctx, s),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
              child: Row(children: [
                Expanded(child: Text(s.label, style: ctx.tt.titleSmall!.copyWith(color: s == current ? p.primary : p.textPrimary))),
                if (s == current) Icon(Icons.check_circle_rounded, color: p.primary),
              ]),
            ),
          ),
      ]);
    },
  );
}
