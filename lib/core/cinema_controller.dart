import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

/// Single source of truth for the local demo. Money is always integer cents.
class CinemaController extends ChangeNotifier {
  SharedPreferences? _preferences;
  String username = 'ACKERMAN', email = 'Ackermanlhn@gmail.com';
  bool signedIn = false, notificationsEnabled = true, promoApplied = false;
  Movie movie = Catalog.movies.first;
  int day = 19, cinemaIndex = 0, timeIndex = 2;
  final Set<String> selectedSeats = {'G7', 'G8'};
  final Map<int, int> comboQuantities = {};
  final Set<String> favorites = {};
  final List<Booking> bookings = [];
  final List<MovieReview> reviews = [
    MovieReview(
      'Standee Lee',
      'The French Revolution constituted for the conscience of the dominant aristocratic class a fall from innocence.',
    ),
    MovieReview('Jackie', 'The French Revolution constituted.'),
    MovieReview(
      'So In',
      'Chances are unless you are very lucky you will go through many different relationships.',
    ),
  ];
  Booking? currentTicket;
  String get cinema => 'Anker Cinema ${Catalog.cinemas[cinemaIndex]}';
  String get time => Catalog.times[timeIndex];
  int get ticketCents => selectedSeats.length * 1000;
  int get snackCents => comboQuantities.entries.fold(
    0,
    (sum, e) => sum + Catalog.combos[e.key].cents * e.value,
  );
  int get discountCents => promoApplied ? (ticketCents * 0.3).round() : 0;
  int get totalCents => ticketCents + snackCents - discountCents;
  String get totalLabel =>
      '${money(totalCents)} · ${selectedSeats.length} ${selectedSeats.length == 1 ? 'Item' : 'Items'}';
  static const unavailable = {
    'C6',
    'C7',
    'D3',
    'D4',
    'D5',
    'D6',
    'E6',
    'E7',
    'F5',
    'F6',
    'F7',
    'G5',
    'G6',
  };
  static bool seatExists(int row, int col) =>
      row != 0 || (col >= 2 && col <= 9 && col != 4 && col != 8);

  Future<void> restore() async {
    _preferences = await SharedPreferences.getInstance();
    username = _preferences!.getString('username') ?? username;
    email = _preferences!.getString('email') ?? email;
    signedIn = _preferences!.getBool('signedIn') ?? false;
    notificationsEnabled = _preferences!.getBool('notifications') ?? true;
    favorites.addAll(_preferences!.getStringList('favorites') ?? []);
    try {
      bookings.addAll(
        Booking.decode(_preferences!.getString('bookings') ?? '[]'),
      );
    } on FormatException {
      await _preferences!.remove('bookings');
    } on TypeError {
      await _preferences!.remove('bookings');
    }
    notifyListeners();
  }

  Future<void> _save() async {
    final p = _preferences;
    if (p == null) return;
    await Future.wait([
      p.setString('username', username),
      p.setString('email', email),
      p.setBool('signedIn', signedIn),
      p.setBool('notifications', notificationsEnabled),
      p.setStringList('favorites', favorites.toList()),
      p.setString(
        'bookings',
        jsonEncode(bookings.map((b) => b.toJson()).toList()),
      ),
    ]);
  }

  Future<void> signIn(String value, {String? name}) async {
    email = value;
    username = name?.trim().isNotEmpty == true ? name!.trim() : username;
    signedIn = true;
    notifyListeners();
    await _save();
  }

  Future<void> signOut() async {
    signedIn = false;
    notifyListeners();
    await _save();
  }

  void selectMovie(Movie value) {
    movie = value;
    selectedSeats
      ..clear()
      ..addAll({'G7', 'G8'});
    comboQuantities.clear();
    promoApplied = false;
    currentTicket = null;
    notifyListeners();
  }

  void chooseDay(int value) {
    day = value;
    notifyListeners();
  }

  void chooseCinema(int value) {
    cinemaIndex = value;
    notifyListeners();
  }

  void chooseTime(int value) {
    timeIndex = value;
    notifyListeners();
  }

  void toggleSeat(String seat) {
    final match = RegExp(r'^([A-H])([1-9]|1[0-2])$').firstMatch(seat);
    if (match == null || unavailable.contains(seat)) return;
    if (!seatExists(match[1]!.codeUnitAt(0) - 65, int.parse(match[2]!) - 1)) {
      return;
    }
    if (!selectedSeats.remove(seat)) selectedSeats.add(seat);
    notifyListeners();
  }

  void changeCombo(int index, int delta) {
    comboQuantities[index] = ((comboQuantities[index] ?? 0) + delta).clamp(
      0,
      9,
    );
    notifyListeners();
  }

  bool applyPromo(String value) {
    if (value.trim().toUpperCase() != 'ANKER30') return false;
    promoApplied = true;
    notifyListeners();
    return true;
  }

  Future<void> toggleFavorite(String id) async {
    if (!favorites.remove(id)) favorites.add(id);
    notifyListeners();
    await _save();
  }

  Future<void> setNotifications(bool value) async {
    notificationsEnabled = value;
    notifyListeners();
    await _save();
  }

  void addReview(String value) {
    if (value.trim().isEmpty) return;
    reviews.insert(0, MovieReview(username, value.trim()));
    notifyListeners();
  }

  void likeReview(MovieReview review) {
    review.liked = !review.liked;
    notifyListeners();
  }

  Future<Booking> completeBooking() async {
    if (selectedSeats.isEmpty) throw StateError('Choose at least one seat.');
    if (currentTicket != null) return currentTicket!;
    final booking = Booking(
      id: 'ANK${DateTime.now().microsecondsSinceEpoch}',
      movieId: movie.id,
      cinema: cinema,
      day: day,
      time: time,
      seats: selectedSeats.toList()..sort(),
      totalCents: totalCents,
    );
    bookings.insert(0, booking);
    currentTicket = booking;
    notifyListeners();
    await _save();
    return booking;
  }

  Future<void> clearHistory() async {
    bookings.clear();
    currentTicket = null;
    notifyListeners();
    await _save();
  }

  void openTicket(Booking booking) {
    currentTicket = booking;
    notifyListeners();
  }

  Future<void> updateProfile(String name, String address) async {
    username = name.trim();
    email = address.trim();
    notifyListeners();
    await _save();
  }
}

class CinemaScope extends InheritedNotifier<CinemaController> {
  const CinemaScope({
    super.key,
    required CinemaController controller,
    required super.child,
  }) : super(notifier: controller);
  static CinemaController of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<CinemaScope>()!.notifier!;
}
