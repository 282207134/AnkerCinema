import 'package:flutter/material.dart';
import 'core/cinema_controller.dart';
import 'core/screens.dart';
import 'core/theme.dart';
import 'features/screen_view.dart';

final cinemaNavigator = GlobalKey<NavigatorState>();

class AnkerApp extends StatelessWidget {
  const AnkerApp({
    super.key,
    required this.controller,
    this.initialScreen = AppScreen.welcome,
  });
  final CinemaController controller;
  final AppScreen initialScreen;
  @override
  Widget build(BuildContext context) => CinemaScope(
    controller: controller,
    child: MaterialApp(
      title: 'Anker Cinema',
      debugShowCheckedModeBanner: false,
      theme: cinemaTheme(),
      navigatorKey: cinemaNavigator,
      onGenerateInitialRoutes: (_) => [_route(initialScreen)],
      onGenerateRoute: (settings) => _route(
        AppScreen.values.firstWhere(
          (screen) => screen.route == settings.name,
          orElse: () => AppScreen.movies,
        ),
      ),
    ),
  );
  MaterialPageRoute<void> _route(AppScreen screen) => MaterialPageRoute(
    settings: RouteSettings(name: screen.route),
    builder: (_) => ScreenView(screen: screen),
  );
}
