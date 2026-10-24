import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';
import 'core/cinema_controller.dart';
import 'core/screens.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  final controller = CinemaController();
  await controller.restore();
  const start = int.fromEnvironment('SCREEN', defaultValue: 0);
  runApp(
    AnkerApp(
      controller: controller,
      initialScreen: start > 0
          ? AppScreen.fromNumber(start)
          : controller.signedIn
          ? AppScreen.movies
          : AppScreen.welcome,
    ),
  );
}
