import 'package:flutter/material.dart';
import '../core/screens.dart';
import 'auth_screens.dart';
import 'booking_screens.dart';
import 'browse_screens.dart';
import 'account_screens.dart';

class ScreenView extends StatelessWidget {
  const ScreenView({super.key, required this.screen});
  final AppScreen screen;
  @override
  Widget build(BuildContext context) => switch (screen) {
    AppScreen.welcome ||
    AppScreen.ticketIntro ||
    AppScreen.auth ||
    AppScreen.login ||
    AppScreen.signup ||
    AppScreen.onboardingBooking ||
    AppScreen.onboardingEasy ||
    AppScreen.onboardingStart => AuthScreen(screen: screen),
    AppScreen.showtimes ||
    AppScreen.seats ||
    AppScreen.combos ||
    AppScreen.ticket ||
    AppScreen.promo ||
    AppScreen.promoSuccess ||
    AppScreen.payment ||
    AppScreen.paymentSuccess ||
    AppScreen.card ||
    AppScreen.verify ||
    AppScreen.verifyCode ||
    AppScreen.checkout => BookingScreen(screen: screen),
    AppScreen.search ||
    AppScreen.comingSoon ||
    AppScreen.actor ||
    AppScreen.movies ||
    AppScreen.movieDetail ||
    AppScreen.reviews ||
    AppScreen.cinemas ||
    AppScreen.cinemaSearch ||
    AppScreen.location ||
    AppScreen.trailer ||
    AppScreen.movieList ||
    AppScreen.discover => BrowseScreen(screen: screen),
    _ => AccountScreen(screen: screen),
  };
}
