import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:anker_cinema/app.dart';
import 'package:anker_cinema/core/cinema_controller.dart';
import 'package:anker_cinema/core/models.dart';
import 'package:anker_cinema/core/screens.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('booking flow and 40 simulator screenshots', (tester) async {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    final state = CinemaController();
    await state.restore();
    await state.clearHistory();
    await tester.pumpWidget(
      AnkerApp(controller: state, initialScreen: AppScreen.movies),
    );
    await tester.pumpAndSettle();
    Future<void> tapText(String label) async {
      final target = find.text(label).last;
      await tester.ensureVisible(target);
      await tester.tap(target);
      await tester.pumpAndSettle();
    }

    await tapText('Book Ticket');
    await tapText('Book Now');
    await tapText('Continue');
    expect(state.selectedSeats, {'G7', 'G8'});
    await tester.tap(find.byKey(const ValueKey('seat-G7')));
    await tester.pumpAndSettle();
    expect(state.totalCents, 1000);
    await tester.tap(find.byKey(const ValueKey('seat-G7')));
    await tester.pumpAndSettle();
    await tapText('Apply My Promote Code');
    await tapText('○  REDEEM CODE');
    await tapText('Apply');
    await tapText('Continue Booking');
    expect(state.totalCents, 1400);
    await tapText(state.totalLabel);
    await tester.tap(find.byKey(const ValueKey('combo-1-plus')));
    await tester.pumpAndSettle();
    expect(state.totalCents, 2200);
    await tapText(state.totalLabel);
    await tapText('Confirm');
    await tapText(state.totalLabel);
    await tapText('Send code');
    for (final digit in ['5', '0', '1', '2']) {
      await tester.tap(find.byKey(ValueKey('digit-$digit')));
      await tester.pumpAndSettle();
    }
    expect(find.text('TICKET BOOKED SUCCESSFULLY'), findsOneWidget);
    expect(state.bookings.single.totalCents, 2200);
    final restored = CinemaController();
    await restored.restore();
    expect(restored.bookings.single.totalCents, 2200);
    await tapText('View Ticket');
    expect(find.text('DEMO TICKET · NOT VALID FOR ENTRY'), findsOneWidget);

    // Deterministic demonstration data for the screenshot catalog only.
    state.selectMovie(Catalog.movies.first);
    state.bookings
      ..clear()
      ..addAll(
        List.generate(
          3,
          (i) => Booking(
            id: 'ABC12345678$i',
            movieId: 'shape',
            cinema: 'Anker Cinema New York',
            day: 19,
            time: '11:05 PM',
            seats: ['G7', 'G8'],
            totalCents: 2000,
          ),
        ),
      );
    for (final screen in AppScreen.values) {
      cinemaNavigator.currentState!.pushNamedAndRemoveUntil(
        screen.route,
        (_) => false,
      );
      await tester.pumpAndSettle();
      if (screen == AppScreen.verifyCode) {
        await tester.tap(find.byKey(const ValueKey('digit-5')));
        await tester.pumpAndSettle();
      }
      await tester.pump(const Duration(milliseconds: 350));
      expect(tester.takeException(), isNull, reason: screen.name);
      await binding.takeScreenshot(
        '${screen.number.toString().padLeft(2, '0')}-${screen.name}',
      );
      // Long views get an additional lower-content screenshot.
      if ([
        AppScreen.search,
        AppScreen.actor,
        AppScreen.movieDetail,
        AppScreen.discover,
        AppScreen.checkout,
      ].contains(screen)) {
        await tester.drag(find.byType(Scrollable).first, const Offset(0, -650));
        await tester.pumpAndSettle();
        await binding.takeScreenshot(
          '${screen.number.toString().padLeft(2, '0')}-${screen.name}-detail',
        );
      }
    }
    binding.reportData ??= <String, dynamic>{};
    binding.reportData!['validation'] = {
      'screens': 40,
      'flowTotalCents': 2200,
      'persistence': true,
    };
  });
}
