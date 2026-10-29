import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/appointments/presentation/screens/appointment_detail_screen.dart';
import '../../features/appointments/presentation/screens/appointments_screen.dart';
import '../../features/booking/presentation/screens/booking_screen.dart';
import '../../features/booking/presentation/screens/booking_success_screen.dart';
import '../../features/chat/presentation/screens/chat_screen.dart';
import '../../features/doctor_detail/presentation/screens/doctor_detail_screen.dart';
import '../../features/doctor_mode/presentation/screens/doctor_dashboard_screen.dart';
import '../../features/doctor_mode/presentation/screens/doctor_more_screen.dart';
import '../../features/doctor_mode/presentation/screens/patient_detail_screen.dart';
import '../../features/doctor_mode/presentation/screens/queue_control_screen.dart';
import '../../features/doctor_mode/presentation/screens/rx_builder_screen.dart';
import '../../features/doctor_mode/presentation/screens/schedule_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/lab_tests/presentation/screens/lab_tests_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/onboarding/presentation/screens/login_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/onboarding/presentation/screens/otp_screen.dart';
import '../../features/onboarding/presentation/screens/profile_setup_screen.dart';
import '../../features/onboarding/presentation/screens/splash_screen.dart';
import '../../features/prescriptions/presentation/screens/prescription_detail_screen.dart';
import '../../features/prescriptions/presentation/screens/prescriptions_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/family_screen.dart';
import '../../features/profile/presentation/screens/language_screen.dart';
import '../../features/profile/presentation/screens/payment_methods_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/settings_screen.dart';
import '../../features/queue/presentation/screens/live_queue_screen.dart';
import '../../features/records/presentation/screens/record_folder_screen.dart';
import '../../features/records/presentation/screens/record_preview_screen.dart';
import '../../features/records/presentation/screens/records_screen.dart';
import '../../features/reminders/presentation/screens/reminders_screen.dart';
import '../../features/search/presentation/screens/search_screen.dart';
import '../../features/video/presentation/screens/video_call_screen.dart';
import '../../features/vitals/presentation/screens/vitals_screen.dart';
import '../widgets/main_shell.dart';
import 'routes.dart';

final _rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _shellKey = GlobalKey<NavigatorState>(debugLabel: 'shell');
final _drShellKey = GlobalKey<NavigatorState>(debugLabel: 'drShell');

/// Fade + gentle upward slide.
CustomTransitionPage<void> _page(GoRouterState s, Widget child) => CustomTransitionPage<void>(
      key: s.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 320),
      reverseTransitionDuration: const Duration(milliseconds: 260),
      transitionsBuilder: (context, anim, sec, child) {
        final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic);
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(position: Tween(begin: const Offset(0, .04), end: Offset.zero).animate(curved), child: child),
        );
      },
    );

/// Tab switches: plain cross-fade.
NoTransitionPage<void> _tab(GoRouterState s, Widget child) => NoTransitionPage<void>(key: s.pageKey, child: child);

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: Routes.splash,
    routes: [
      GoRoute(path: Routes.splash, pageBuilder: (c, s) => _page(s, const SplashScreen())),
      GoRoute(path: Routes.onboarding, pageBuilder: (c, s) => _page(s, const OnboardingScreen())),
      GoRoute(path: Routes.login, pageBuilder: (c, s) => _page(s, const LoginScreen())),
      GoRoute(path: '/otp', pageBuilder: (c, s) => _page(s, OtpScreen(phone: s.uri.queryParameters['phone'] ?? ''))),
      GoRoute(path: Routes.profileSetup, pageBuilder: (c, s) => _page(s, const ProfileSetupScreen())),

      // ── Patient shell ──
      ShellRoute(
        navigatorKey: _shellKey,
        builder: (c, s, child) => MainShell(child: child),
        routes: [
          GoRoute(path: Routes.home, pageBuilder: (c, s) => _tab(s, const HomeScreen())),
          GoRoute(path: Routes.appointments, pageBuilder: (c, s) => _tab(s, const AppointmentsScreen())),
          GoRoute(path: Routes.records, pageBuilder: (c, s) => _tab(s, const RecordsScreen())),
          GoRoute(path: Routes.profile, pageBuilder: (c, s) => _tab(s, const ProfileScreen())),
        ],
      ),

      // ── Patient pushed screens (above the shell) ──
      GoRoute(
        path: '/search',
        parentNavigatorKey: _rootKey,
        pageBuilder: (c, s) => _page(s, SearchScreen(specialtyId: s.uri.queryParameters['specialty'], autofocus: s.uri.queryParameters['focus'] == '1')),
      ),
      GoRoute(
        path: '/doc/:id',
        parentNavigatorKey: _rootKey,
        pageBuilder: (c, s) => _page(s, DoctorDetailScreen(doctorId: s.pathParameters['id']!, heroSuffix: s.uri.queryParameters['hero'] ?? '')),
      ),
      GoRoute(
        path: '/book/:id',
        parentNavigatorKey: _rootKey,
        pageBuilder: (c, s) => _page(s, BookingScreen(doctorId: s.pathParameters['id']!, type: s.uri.queryParameters['type'], rescheduleId: s.uri.queryParameters['reschedule'])),
      ),
      GoRoute(path: '/booking-success/:id', parentNavigatorKey: _rootKey, pageBuilder: (c, s) => _page(s, BookingSuccessScreen(appointmentId: s.pathParameters['id']!))),
      GoRoute(path: '/appointment/:id', parentNavigatorKey: _rootKey, pageBuilder: (c, s) => _page(s, AppointmentDetailScreen(appointmentId: s.pathParameters['id']!))),
      GoRoute(path: Routes.queue, parentNavigatorKey: _rootKey, pageBuilder: (c, s) => _page(s, const LiveQueueScreen())),
      GoRoute(path: '/video/:id', parentNavigatorKey: _rootKey, pageBuilder: (c, s) => _page(s, VideoCallScreen(appointmentId: s.pathParameters['id']!))),
      GoRoute(path: Routes.prescriptions, parentNavigatorKey: _rootKey, pageBuilder: (c, s) => _page(s, const PrescriptionsScreen())),
      GoRoute(path: '/prescription/:id', parentNavigatorKey: _rootKey, pageBuilder: (c, s) => _page(s, PrescriptionDetailScreen(prescriptionId: s.pathParameters['id']!))),
      GoRoute(path: Routes.reminders, parentNavigatorKey: _rootKey, pageBuilder: (c, s) => _page(s, const RemindersScreen())),
      GoRoute(path: '/records/folder/:kind', parentNavigatorKey: _rootKey, pageBuilder: (c, s) => _page(s, RecordFolderScreen(kind: s.pathParameters['kind']!))),
      GoRoute(path: '/records/file/:id', parentNavigatorKey: _rootKey, pageBuilder: (c, s) => _page(s, RecordPreviewScreen(recordId: s.pathParameters['id']!))),
      GoRoute(path: Routes.labTests, parentNavigatorKey: _rootKey, pageBuilder: (c, s) => _page(s, const LabTestsScreen())),
      GoRoute(path: Routes.vitals, parentNavigatorKey: _rootKey, pageBuilder: (c, s) => _page(s, const VitalsScreen())),
      GoRoute(path: Routes.chat, parentNavigatorKey: _rootKey, pageBuilder: (c, s) => _page(s, const ChatScreen())),
      GoRoute(path: Routes.notifications, parentNavigatorKey: _rootKey, pageBuilder: (c, s) => _page(s, const NotificationsScreen())),
      GoRoute(path: Routes.family, parentNavigatorKey: _rootKey, pageBuilder: (c, s) => _page(s, const FamilyScreen())),
      GoRoute(path: Routes.payments, parentNavigatorKey: _rootKey, pageBuilder: (c, s) => _page(s, const PaymentMethodsScreen())),
      GoRoute(path: Routes.language, parentNavigatorKey: _rootKey, pageBuilder: (c, s) => _page(s, const LanguageScreen())),
      GoRoute(path: Routes.settings, parentNavigatorKey: _rootKey, pageBuilder: (c, s) => _page(s, const SettingsScreen())),
      GoRoute(path: Routes.editProfile, parentNavigatorKey: _rootKey, pageBuilder: (c, s) => _page(s, const EditProfileScreen())),

      // ── Doctor mode ──
      ShellRoute(
        navigatorKey: _drShellKey,
        builder: (c, s, child) => DoctorShell(child: child),
        routes: [
          GoRoute(path: Routes.drDashboard, pageBuilder: (c, s) => _tab(s, const DoctorDashboardScreen())),
          GoRoute(path: Routes.drQueue, pageBuilder: (c, s) => _tab(s, const QueueControlScreen())),
          GoRoute(path: Routes.drSchedule, pageBuilder: (c, s) => _tab(s, const ScheduleScreen())),
          GoRoute(path: Routes.drMore, pageBuilder: (c, s) => _tab(s, const DoctorMoreScreen())),
        ],
      ),
      GoRoute(path: '/dr/patient/:id', parentNavigatorKey: _rootKey, pageBuilder: (c, s) => _page(s, PatientDetailScreen(patientId: s.pathParameters['id']!))),
      GoRoute(path: '/dr/rx/:id', parentNavigatorKey: _rootKey, pageBuilder: (c, s) => _page(s, RxBuilderScreen(patientId: s.pathParameters['id']!))),
    ],
  );
});

