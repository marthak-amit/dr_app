import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mediq/app.dart';
import 'package:mediq/core/router/app_router.dart';
import 'package:mediq/data/repositories/providers.dart';

/// Pumps every route at small (360x640) and large (430x932) phone sizes and fails on
/// any framework exception (RenderFlex overflow, build errors, ...).
const _routes = <String>[
  '/onboarding',
  '/login',
  '/otp?phone=9876543210',
  '/profile-setup',
  '/home',
  '/appointments',
  '/records',
  '/profile',
  '/search',
  '/search?specialty=cardio',
  '/doc/d1',
  '/doc/d4',
  '/book/d2',
  '/book/d1?type=video',
  '/booking-success/a1',
  '/appointment/a1',
  '/appointment/a4',
  '/queue',
  '/video/a2',
  '/prescriptions',
  '/prescription/rx1',
  '/reminders',
  '/records/folder/lab',
  '/records/folder/xray',
  '/records/file/r1',
  '/records/file/r4',
  '/lab-tests',
  '/vitals',
  '/chat',
  '/notifications',
  '/profile/family',
  '/profile/payments',
  '/profile/language',
  '/profile/settings',
  '/profile/edit',
  '/dr/dashboard',
  '/dr/queue',
  '/dr/schedule',
  '/dr/more',
  '/dr/patient/q1',
  '/dr/rx/q1',
];

Future<void> _loadFonts() async {
  final loader = FontLoader('PlusJakartaSans');
  for (final w in [400, 500, 600, 700, 800]) {
    loader.addFont(rootBundle.load('assets/fonts/PlusJakartaSans-$w.ttf'));
  }
  await loader.load();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(_loadFonts);

  for (final size in const [Size(360, 640), Size(430, 932)]) {
    for (final dark in [false, true]) {
      if (dark && size.width > 400) continue;
      group('${size.width.toInt()}x${size.height.toInt()}${dark ? ' dark' : ''}', () {
        for (final route in _routes) {
          testWidgets(route, (tester) async {
            tester.view.physicalSize = size;
            tester.view.devicePixelRatio = 1;
            addTearDown(tester.view.reset);
            FlutterErrorDetails? first;
            FlutterError.onError = (d) {
              if (first == null) FlutterError.dumpErrorToConsole(d);
              first ??= d;
            };
            final container = ProviderContainer();
            addTearDown(container.dispose);
            await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const MediQApp()));
            await tester.pump(const Duration(milliseconds: 100));
            if (dark) container.read(themeModeProvider.notifier).state = ThemeMode.dark;
            container.read(routerProvider).go(route);
            for (var i = 0; i < 14; i++) {
              await tester.pump(const Duration(milliseconds: 250));
            }
            final ex = tester.takeException();
            if (first != null) {
              final t = first!.toString() + (first!.informationCollector?.call().map((e) => e.toStringDeep()).join('\n') ?? '');
              // ignore: avoid_print
              print('FIRST ERROR on $route:\n${t.substring(0, t.length > 4000 ? 4000 : t.length)}');
            }
            expect(ex, isNull, reason: 'Exception on $route: $ex');
            await tester.pumpWidget(const SizedBox());
            await tester.pump(const Duration(seconds: 3));
            tester.takeException();
          });
        }
      });
    }
  }
}
