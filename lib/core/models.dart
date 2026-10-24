import 'dart:convert';

class Movie {
  const Movie(
    this.id,
    this.title,
    this.rating, {
    this.genre = 'Romantic / Action',
  });
  final String id, title, genre;
  final double rating;
}

class SnackCombo {
  const SnackCombo(this.name, this.cents);
  final String name;
  final int cents;
}

abstract final class Catalog {
  static const movies = [
    Movie('shape', 'Shape of Water', 7.8),
    Movie('iron', 'Iron Man 3: Civil War', 7.8, genre: 'Action / Adventure'),
    Movie('captain', 'Captain America', 8.8, genre: 'Action / Adventure'),
    Movie('strange', 'Doctor Strange', 7.8, genre: 'Fantasy / Adventure'),
    Movie('summer', 'Summer In Closed Eyes', 7.8),
    Movie('aladin', 'Aladin', 7.8, genre: 'Fantasy / Family'),
    Movie('autumn', 'Autumn In Love', 8.8),
    Movie('beauty', 'Beauty In The Forest', 7.8),
  ];
  static const cinemas = ['New York', 'New Jersey', 'Los Angeles'];
  static const times = ['4:25 PM', '7:35 PM', '11:05 PM', '12:00 PM'];
  static const combos = [
    SnackCombo('Lovely Combo', 0),
    SnackCombo('Single Combo', 800),
    SnackCombo('Couple Combo', 1000),
    SnackCombo('Spring Combo', 1050),
    SnackCombo('Family Combo', 1200),
    SnackCombo('Master Combo', 1600),
  ];
  static Movie movie(String id) =>
      movies.firstWhere((m) => m.id == id, orElse: () => movies.first);
}

String money(int cents) => '\$${(cents / 100).toStringAsFixed(2)}';

class Booking {
  const Booking({
    required this.id,
    required this.movieId,
    required this.cinema,
    required this.day,
    required this.time,
    required this.seats,
    required this.totalCents,
  });
  final String id, movieId, cinema, time;
  final int day, totalCents;
  final List<String> seats;
  Map<String, dynamic> toJson() => {
    'id': id,
    'movieId': movieId,
    'cinema': cinema,
    'day': day,
    'time': time,
    'seats': seats,
    'totalCents': totalCents,
  };
  factory Booking.fromJson(Map<String, dynamic> j) => Booking(
    id: j['id'] as String,
    movieId: j['movieId'] as String,
    cinema: j['cinema'] as String,
    day: j['day'] as int,
    time: j['time'] as String,
    seats: List<String>.from(j['seats'] as List),
    totalCents: j['totalCents'] as int,
  );
  static List<Booking> decode(String value) => (jsonDecode(value) as List)
      .map((j) => Booking.fromJson(j as Map<String, dynamic>))
      .toList();
}

class MovieReview {
  MovieReview(this.author, this.message);
  final String author, message;
  bool liked = false;
}
