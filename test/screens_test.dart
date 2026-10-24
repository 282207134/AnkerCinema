import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:anker_cinema/app.dart';
import 'package:anker_cinema/core/cinema_controller.dart';
import 'package:anker_cinema/core/screens.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    for (final name in ['Futura', 'FuturaCondensed']) {
      final loader = FontLoader(name)
        ..addFont(rootBundle.load('assets/fonts/$name.ttf'));
      await loader.load();
    }
  });
  for (final size in [const Size(375, 812), const Size(320, 568)]) {
    testWidgets('all 40 routes render at ${size.width} x ${size.height}', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final state = CinemaController();
      for (final screen in AppScreen.values) {
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpWidget(
          AnkerApp(controller: state, initialScreen: screen),
        );
        await tester.pumpAndSettle();
        expect(
          tester.takeException(),
          isNull,
          reason: '${screen.number} ${screen.name}',
        );
      }
    });
  }
  testWidgets('login validates credentials and opens onboarding', (
    tester,
  ) async {
    await tester.pumpWidget(
      AnkerApp(controller: CinemaController(), initialScreen: AppScreen.login),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Log In').last);
    await tester.tap(find.text('Log In').last);
    await tester.pumpAndSettle();
    expect(find.text('Enter Password'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).last, 'demo123');
    await tester.ensureVisible(find.text('Log In').last);
    await tester.tap(find.text('Log In').last);
    await tester.pumpAndSettle();
    expect(find.text('Everything In Your Hand'), findsOneWidget);
  });
}
