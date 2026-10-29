import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/widgets.dart';
import '../../../../data/repositories/providers.dart';
import '../../providers/lab_cart_provider.dart';
import '../widgets/lab_booking_flow.dart';
import '../widgets/lab_test_card.dart';

class LabTestsScreen extends ConsumerStatefulWidget {
  const LabTestsScreen({super.key});

  @override
  ConsumerState<LabTestsScreen> createState() => _LabTestsScreenState();
}

class _LabTestsScreenState extends ConsumerState<LabTestsScreen> {
  String _q = '';
  String _cat = 'All';
  static const _cats = ['All', 'Popular', 'Packages', 'Fasting'];

  Future<void> _refresh() async {
    ref.invalidate(labTestsProvider);
    await ref.read(labTestsProvider.future);
  }

  List<LabTest> _filter(List<LabTest> all) => all.where((t) {
        final okQ = _q.trim().isEmpty || t.name.toLowerCase().contains(_q.trim().toLowerCase()) || t.description.toLowerCase().contains(_q.trim().toLowerCase());
        final okC = switch (_cat) { 'Popular' => t.popular, 'Packages' => t.testsCount >= 10, 'Fasting' => t.fasting, _ => true };
        return okQ && okC;
      }).toList();

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final async = ref.watch(labTestsProvider);
    final cart = ref.watch(labCartProvider);
    final tests = async.valueOrNull ?? const <LabTest>[];
    final sum = summarize(tests, cart);
    return Scaffold(
      appBar: AppTopBar(title: 'Lab tests', actions: [AppIconButton(icon: Icons.history_rounded, size: 40, tooltip: 'Past orders', onTap: () => showAppSnack(context, 'No previous lab orders yet', icon: Icons.inbox_rounded))]),
      bottomNavigationBar: AnimatedSize(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        child: sum.count == 0 ? const SizedBox(width: double.infinity) : _CartBar(sum: sum, onBook: () => showLabBookingFlow(context, cart: sum, onDone: () => ref.read(labCartProvider.notifier).clear())),
      ),
      body: RefreshIndicator(
        color: p.primary,
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(AppSpacing.screenH, 4, AppSpacing.screenH, 24),
          children: [
            const _PromoBanner().animate().fadeIn(duration: 350.ms).slideY(begin: .1, curve: Curves.easeOutCubic),
            const SizedBox(height: 16),
            AppTextField(hint: 'Search tests, e.g. thyroid, CBC', prefixIcon: Icons.search_rounded, onChanged: (v) => setState(() => _q = v)),
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _cats.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) => ChoicePill(label: _cats[i], selected: _cat == _cats[i], onTap: () => setState(() => _cat = _cats[i])),
              ),
            ),
            const SizedBox(height: 16),
            ...async.when(
              loading: () => [const ShimmerList(itemCount: 4, itemHeight: 168, padding: EdgeInsets.zero, shrink: true)],
              error: (e, _) => [SizedBox(height: 420, child: ErrorState(onRetry: _refresh))],
              data: (all) {
                final list = _filter(all);
                if (list.isEmpty) return [SizedBox(height: 360, child: EmptyState(icon: Icons.science_outlined, title: 'No tests found', message: 'Try a different keyword or category.', actionLabel: 'Clear filters', onAction: () => setState(() { _q = ''; _cat = 'All'; }) ))];
                return [
                  for (var i = 0; i < list.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: LabTestCard(
                        test: list[i],
                        index: i,
                        qty: cart[list[i].id] ?? 0,
                        onAdd: () {
                          ref.read(labCartProvider.notifier).add(list[i].id);
                        },
                        onInc: () => ref.read(labCartProvider.notifier).inc(list[i].id),
                        onDec: () => ref.read(labCartProvider.notifier).dec(list[i].id),
                      ),
                    ),
                ];
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PromoBanner extends StatelessWidget {
  const _PromoBanner();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(gradient: AppColors.gradientPrimary, borderRadius: AppRadius.rXl, boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: .3), blurRadius: 20, offset: const Offset(0, 8))]),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: .2), borderRadius: AppRadius.rPill),
              child: Text('FREE PICKUP', style: context.tt.labelSmall!.copyWith(color: Colors.white, letterSpacing: .8)),
            ),
            const SizedBox(height: 10),
            Text('Home sample collection', style: context.tt.titleLarge!.copyWith(color: Colors.white)),
            const SizedBox(height: 4),
            Text('Certified phlebotomist at your door.\nReports in as little as 6 hours.', style: context.tt.bodySmall!.copyWith(color: Colors.white.withValues(alpha: .9))),
          ]),
        ),
        const SizedBox(width: 10),
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: .18), shape: BoxShape.circle),
          child: const Center(child: SvgIcon('syringe', size: 32, color: Colors.white)),
        ),
      ]),
    );
  }
}

class _CartBar extends StatelessWidget {
  const _CartBar({required this.sum, required this.onBook});
  final CartSummary sum;
  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(color: p.surface, borderRadius: const BorderRadius.vertical(top: Radius.circular(24)), border: Border(top: BorderSide(color: p.border)), boxShadow: [BoxShadow(color: p.shadow, blurRadius: 24, offset: const Offset(0, -6))]),
      child: Row(children: [
        Expanded(
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${sum.count} ${sum.count == 1 ? 'test' : 'tests'} added', style: context.tt.bodySmall),
            Row(children: [
              Text(rupees(sum.total), style: context.tt.titleLarge),
              const SizedBox(width: 8),
              Flexible(child: Text('Save ${rupees(sum.saved)}', style: context.tt.labelSmall!.copyWith(color: p.success), maxLines: 1, overflow: TextOverflow.ellipsis)),
            ]),
          ]),
        ),
        const SizedBox(width: 12),
        Flexible(child: AppButton(label: 'Book home collection', expand: false, variant: AppButtonVariant.accent, size: AppButtonSize.medium, onPressed: onBook)),
      ]),
    );
  }
}
