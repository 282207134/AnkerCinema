import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:anker_cinema/core/cinema_controller.dart';
import 'package:anker_cinema/core/models.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  test('money uses cents; promotion discounts tickets only', () {
    final state = CinemaController();
    state.changeCombo(1, 1);
    expect(state.totalCents, 2800);
    expect(state.applyPromo(' anker30 '), isTrue);
    expect(state.discountCents, 600);
    expect(state.totalCents, 2200);
    expect(state.applyPromo('INVALID'), isFalse);
    expect(state.totalCents, 2200);
  });
  test(
    'occupied seats cannot be selected and zero seats cannot checkout',
    () async {
      final state = CinemaController();
      state.toggleSeat('C6');
      state.toggleSeat('Z0');
      state.toggleSeat('A1');
      expect(state.selectedSeats, {'G7', 'G8'});
      expect(state.selectedSeats, isNot(contains('C6')));
      state.toggleSeat('G7');
      state.toggleSeat('G8');
      expect(state.totalCents, 0);
      await expectLater(state.completeBooking(), throwsStateError);
    },
  );
  test('quantities are bounded', () {
    final state = CinemaController();
    state.changeCombo(1, -10);
    expect(state.snackCents, 0);
    state.changeCombo(1, 100);
    expect(state.comboQuantities[1], 9);
  });
  test('completion is idempotent and history survives restart', () async {
    final state = CinemaController();
    await state.restore();
    state.changeCombo(3, 1);
    final first = await state.completeBooking();
    expect(await state.completeBooking(), same(first));
    expect(state.bookings.length, 1);
    final restored = CinemaController();
    await restored.restore();
    expect(restored.bookings.single.totalCents, 3050);
    expect(restored.bookings.single.seats, ['G7', 'G8']);
    await restored.clearHistory();
    final empty = CinemaController();
    await empty.restore();
    expect(empty.bookings, isEmpty);
  });
  test('profile and preferences persist; new movie resets draft', () async {
    final state = CinemaController();
    await state.restore();
    await state.signIn('demo@example.com', name: 'Demo');
    await state.toggleFavorite('shape');
    await state.setNotifications(false);
    state.applyPromo('ANKER30');
    state.changeCombo(1, 1);
    state.selectMovie(Catalog.movies[1]);
    expect(state.promoApplied, isFalse);
    expect(state.snackCents, 0);
    final restored = CinemaController();
    await restored.restore();
    expect(restored.username, 'Demo');
    expect(restored.email, 'demo@example.com');
    expect(restored.notificationsEnabled, isFalse);
    expect(restored.favorites, {'shape'});
    await restored.signOut();
    expect(restored.signedIn, isFalse);
  });
  test('corrupt saved bookings recover to empty history', () async {
    SharedPreferences.setMockInitialValues({'bookings': '{broken'});
    final state = CinemaController();
    await state.restore();
    expect(state.bookings, isEmpty);
  });
}
