import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mediq/core/router/routes.dart';
import 'package:mediq/core/widgets/widgets.dart';
import 'package:mediq/data/repositories/providers.dart';

import '../widgets/home_header.dart';
import '../widgets/home_sections.dart';
import '../widgets/live_queue_card.dart';
import '../widgets/upcoming_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final top = MediaQuery.of(context).padding.top;
    final appts = ref.watch(appointmentsProvider);
    final next = ref.watch(nextAppointmentProvider);
    final doctors = ref.watch(doctorsProvider);
    final specialties = ref.watch(specialtiesProvider);
    const h = EdgeInsets.symmetric(horizontal: AppSpacing.screenH);

    Widget stagger(int i, Widget w) => w.animate().fadeIn(delay: (70 * i).ms, duration: 420.ms).slideY(begin: .08, end: 0, delay: (70 * i).ms, duration: 420.ms, curve: Curves.easeOutCubic);

    final showQueue = next != null && next.isToday && next.type == ConsultType.inClinic;

    return RefreshIndicator(
      color: context.pal.primary,
      onRefresh: () async {
        ref.invalidate(doctorsProvider);
        ref.invalidate(appointmentsProvider);
        await Future.wait([ref.read(doctorsProvider.future), ref.read(appointmentsProvider.future)]);
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(top: top + 12, bottom: 120),
        children: [
          stagger(0, const Padding(padding: h, child: HomeHeader())),
          const SizedBox(height: 18),
          stagger(1, const Padding(padding: h, child: HomeSearchBar())),
          const SizedBox(height: 22),
          if (appts.isLoading && !appts.hasValue)
            const Padding(padding: h, child: ShimmerBox(height: 150, radius: 24))
          else if (showQueue) ...[
            stagger(2, Padding(padding: h, child: LiveQueueCard(appointment: next))),
            const SizedBox(height: 16),
          ],
          if (appts.hasError)
            Padding(padding: h, child: AppCard(child: Row(children: [
              Icon(Icons.cloud_off_rounded, color: context.pal.accent),
              const SizedBox(width: 12),
              const Expanded(child: Text('Couldn\'t load your appointments')),
              TextButton(onPressed: () => ref.invalidate(appointmentsProvider), child: const Text('Retry')),
            ])))
          else if (appts.hasValue) ...[
            SectionHeader(title: 'Upcoming appointment', action: 'View all', onAction: () => context.go(Routes.appointments)),
            const SizedBox(height: 12),
            stagger(3, Padding(padding: h, child: next == null ? const NoUpcomingCard() : UpcomingAppointmentCard(appointment: next))),
          ],
          const SizedBox(height: 26),
          stagger(4, const QuickActions()),
          const SizedBox(height: 26),
          SectionHeader(title: 'Find by specialty', action: 'See all', onAction: () => showAllSpecialties(context, specialties)),
          const SizedBox(height: 16),
          stagger(5, SpecialtyGrid(specialties: specialties)),
          const SizedBox(height: 26),
          SectionHeader(title: 'Top doctors', subtitle: 'Highly rated near you', action: 'See all', onAction: () => context.push(Routes.search())),
          const SizedBox(height: 14),
          SizedBox(
            height: 268,
            child: doctors.when(
              loading: () => ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                padding: h,
                itemCount: 3,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (_, __) => const ShimmerBox(width: 168, height: 262, radius: 24),
              ),
              error: (e, _) => ErrorState(onRetry: () => ref.invalidate(doctorsProvider)),
              data: (list) {
                final top = list.where((d) => d.isTop).toList();
                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: h,
                  itemCount: top.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 14),
                  itemBuilder: (_, i) => DoctorCardVertical(doctor: top[i], onTap: () => context.push(Routes.doctor(top[i].id, heroSuffix: '-top'))),
                ).animate().fadeIn(duration: 400.ms);
              },
            ),
          ),
          const SizedBox(height: 26),
          stagger(7, const Padding(padding: h, child: HealthTipBanner())),
        ],
      ),
    );
  }
}
