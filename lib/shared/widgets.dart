import 'package:flutter/material.dart';
import '../core/cinema_controller.dart';
import '../core/models.dart';
import '../core/screens.dart';
import '../core/theme.dart';

void go(BuildContext context, AppScreen screen, {bool reset = false}) {
  if (reset) {
    Navigator.of(context).pushNamedAndRemoveUntil(screen.route, (_) => false);
  } else {
    Navigator.of(context).pushNamed(screen.route);
  }
}

void toast(BuildContext context, String text) => ScaffoldMessenger.of(context)
  ..hideCurrentSnackBar()
  ..showSnackBar(SnackBar(content: Text(text)));

class CinemaPage extends StatelessWidget {
  const CinemaPage({
    super.key,
    required this.title,
    required this.child,
    this.bottom,
    this.menu = true,
    this.trailing,
    this.background,
    this.back = true,
  });
  final String title;
  final Widget child;
  final Widget? bottom, trailing;
  final bool menu, back;
  final Color? background;
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: background,
    resizeToAvoidBottomInset: true,
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            children: [
              SizedBox(
                height: 44,
                child: Row(
                  children: [
                    if (back)
                      IconButton(
                        tooltip: 'Back',
                        icon: const Icon(Icons.arrow_back, size: 22),
                        onPressed: () {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          } else {
                            go(context, AppScreen.movies, reset: true);
                          }
                        },
                      )
                    else
                      const SizedBox(width: 16),
                    Expanded(
                      child: Text(title, style: const TextStyle(fontSize: 16)),
                    ),
                    ?trailing,
                    if (menu)
                      IconButton(
                        tooltip: 'Menu',
                        onPressed: () => go(context, AppScreen.menu),
                        icon: const Badge(
                          smallSize: 8,
                          child: Icon(Icons.menu, size: 23),
                        ),
                      ),
                    const SizedBox(width: 4),
                  ],
                ),
              ),
              Expanded(child: child),
              if (bottom != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: bottom,
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

class ActionButton extends StatelessWidget {
  const ActionButton(
    this.label, {
    super.key,
    required this.onPressed,
    this.outlined = false,
  });
  final String label;
  final VoidCallback? onPressed;
  final bool outlined;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 46,
    child: outlined
        ? OutlinedButton(
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              shape: const RoundedRectangleBorder(),
              side: const BorderSide(color: Colors.white54),
            ),
            child: Text(label),
          )
        : FilledButton(
            onPressed: onPressed,
            style: FilledButton.styleFrom(
              backgroundColor: CinemaColors.yellow,
              foregroundColor: CinemaColors.background,
              disabledBackgroundColor: CinemaColors.line,
              shape: const RoundedRectangleBorder(),
              textStyle: const TextStyle(fontFamily: 'Futura', fontSize: 16),
            ),
            child: Text(label),
          ),
  );
}

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.onViewAll});
  final String text;
  final VoidCallback? onViewAll;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 40,
    child: Row(
      children: [
        Expanded(
          child: Text(text.toUpperCase(), style: const TextStyle(fontSize: 12)),
        ),
        if (onViewAll != null)
          TextButton(
            onPressed: onViewAll,
            child: const Text(
              'VIEW ALL',
              style: TextStyle(color: CinemaColors.blue, fontSize: 12),
            ),
          ),
      ],
    ),
  );
}

/// The reference page is named "No Image" and deliberately uses empty posters.
class Poster extends StatelessWidget {
  const Poster({
    super.key,
    this.width,
    this.height,
    this.color = const Color(0xFFD8D8D8),
    this.play = false,
    this.onTap,
  });
  final double? width, height;
  final Color color;
  final bool play;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Movie artwork placeholder',
    image: true,
    child: InkWell(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        color: color,
        child: play
            ? const Center(
                child: Icon(
                  Icons.play_circle_outline,
                  size: 34,
                  color: Colors.white,
                ),
              )
            : null,
      ),
    ),
  );
}

class Rating extends StatelessWidget {
  const Rating(
    this.value, {
    super.key,
    this.detailed = false,
    this.foreground = const Color(0xFFD1D1D1),
  });
  final double value;
  final bool detailed;
  final Color foreground;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      ...List.generate(
        5,
        (i) => Icon(
          Icons.star_border,
          size: 15,
          color: i < 3 ? const Color(0xFFB6A413) : CinemaColors.muted,
        ),
      ),
      const SizedBox(width: 7),
      Text(
        detailed ? '( $value Rating)' : '$value',
        style: TextStyle(fontSize: 12, color: foreground),
      ),
    ],
  );
}

class MovieStrip extends StatelessWidget {
  const MovieStrip(this.movies, {super.key, this.height = 240});
  final List<Movie> movies;
  final double height;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: height,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: movies.length,
      separatorBuilder: (_, index) => const SizedBox(width: 16),
      itemBuilder: (context, i) => SizedBox(
        width: 127,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Poster(
              width: 127,
              height: height - 65,
              onTap: () {
                CinemaScope.of(context).selectMovie(movies[i]);
                go(context, AppScreen.movieDetail);
              },
            ),
            const SizedBox(height: 12),
            Text(movies[i].title, maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 6),
            Rating(movies[i].rating),
          ],
        ),
      ),
    ),
  );
}

class MovieTile extends StatelessWidget {
  const MovieTile(this.movie, {super.key, this.light = false});
  final Movie movie;
  final bool light;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () {
      CinemaScope.of(context).selectMovie(movie);
      go(context, AppScreen.movieDetail);
    },
    child: Container(
      height: 138,
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: light ? Colors.white : CinemaColors.panel,
        border: Border.all(color: CinemaColors.line, width: .7),
      ),
      child: Row(
        children: [
          const Poster(width: 93, height: 138, play: true),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: DefaultTextStyle(
                style: TextStyle(
                  fontFamily: 'Futura',
                  color: light ? CinemaColors.background : Colors.white,
                  fontSize: 11,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(movie.title.toUpperCase(), maxLines: 2),
                        ),
                        const AgeBadge(),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'THUS, 05.22.2019',
                      style: TextStyle(fontSize: 10),
                    ),
                    const SizedBox(height: 16),
                    FittedBox(
                      child: Rating(
                        movie.rating,
                        detailed: true,
                        foreground: light
                            ? const Color(0xFF686C71)
                            : const Color(0xFFD1D1D1),
                      ),
                    ),
                    const SizedBox(height: 13),
                    const Text(
                      'At Anker Cinema',
                      style: TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class AgeBadge extends StatelessWidget {
  const AgeBadge({super.key});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
    decoration: BoxDecoration(
      border: Border.all(color: CinemaColors.muted, width: .7),
    ),
    child: const Text('C18', style: TextStyle(fontSize: 9)),
  );
}

class MenuRow extends StatelessWidget {
  const MenuRow(
    this.label, {
    super.key,
    this.icon,
    required this.onTap,
    this.subtitle,
    this.trailing,
  });
  final String label;
  final IconData? icon;
  final String? subtitle;
  final VoidCallback onTap;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Container(
      constraints: const BoxConstraints(minHeight: 64),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: CinemaColors.line, width: .6)),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 22, color: CinemaColors.muted),
            const SizedBox(width: 20),
          ],
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label),
                  if (subtitle != null) ...[
                    const SizedBox(height: 5),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        color: CinemaColors.muted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          trailing ?? const Icon(Icons.chevron_right, size: 20),
        ],
      ),
    ),
  );
}

class ProfileIdentity extends StatelessWidget {
  const ProfileIdentity({super.key});
  @override
  Widget build(BuildContext context) {
    final state = CinemaScope.of(context);
    return InkWell(
      onTap: () => go(context, AppScreen.profile),
      child: Row(
        children: [
          const CircleAvatar(radius: 28, backgroundColor: Color(0xFFD8D8D8)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(state.username),
                const SizedBox(height: 5),
                Text(
                  state.email,
                  style: const TextStyle(
                    fontSize: 12,
                    color: CinemaColors.muted,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, size: 20),
        ],
      ),
    );
  }
}

class SearchBox extends StatelessWidget {
  const SearchBox({
    super.key,
    this.onChanged,
    this.hint = 'Search…',
    this.autofocus = false,
  });
  final ValueChanged<String>? onChanged;
  final String hint;
  final bool autofocus;
  @override
  Widget build(BuildContext context) => TextField(
    autofocus: autofocus,
    onChanged: onChanged,
    style: const TextStyle(fontSize: 16),
    decoration: InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.black,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      suffixIcon: const Icon(Icons.search, color: Colors.white),
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: CinemaColors.line),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: CinemaColors.yellow),
      ),
    ),
  );
}

class Brand extends StatelessWidget {
  const Brand({super.key, this.large = false, this.yellow = false});
  final bool large, yellow;
  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        large ? 'ANKER CINEMA' : 'ANKER',
        style: TextStyle(
          fontFamily: 'FuturaCondensed',
          fontSize: large ? 48 : 23,
          color: yellow ? CinemaColors.yellow : Colors.white,
          height: 1.1,
        ),
      ),
      if (!large)
        Text(
          'C I N E M A',
          style: TextStyle(
            fontSize: 9,
            color: yellow ? CinemaColors.yellow : Colors.white,
          ),
        ),
    ],
  );
}

class PaginationDots extends StatelessWidget {
  const PaginationDots(this.selected, {super.key, this.count = 4});
  final int selected, count;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: List.generate(
      count,
      (i) => Container(
        width: i == selected ? 18 : 7,
        height: 7,
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: i == selected ? CinemaColors.yellow : Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
  );
}

const story =
    'In this third installment of the adrenaline-fueled action franchise, super-assassin John Wick returns with a \$14 million price tag on his head and an army of bounty hunters on his trail.';
