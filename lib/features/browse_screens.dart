import 'package:flutter/material.dart';
import '../core/cinema_controller.dart';
import '../core/models.dart';
import '../core/screens.dart';
import '../core/theme.dart';
import '../shared/widgets.dart';

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key, required this.screen});
  final AppScreen screen;
  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  int _tab = 1, _movieIndex = 1;
  String _query = '';
  final _comment = TextEditingController();
  final _posterController = PageController(initialPage: 1);
  final _listController = PageController();
  @override
  void initState() {
    super.initState();
    if (widget.screen == AppScreen.movieList) _movieIndex = 0;
  }

  bool _expandedStory = false, _showAllReviews = false, _playing = false;
  double _position = 2;
  @override
  void dispose() {
    _comment.dispose();
    _posterController.dispose();
    _listController.dispose();
    super.dispose();
  }

  CinemaController get state => CinemaScope.of(context);
  @override
  Widget build(BuildContext context) => switch (widget.screen) {
    AppScreen.movies => _movies(),
    AppScreen.search => _search(),
    AppScreen.comingSoon => _comingSoon(),
    AppScreen.movieList => _movieList(),
    AppScreen.discover => _discover(),
    AppScreen.movieDetail => _detail(),
    AppScreen.actor => _actor(),
    AppScreen.reviews => _reviews(),
    AppScreen.cinemas || AppScreen.cinemaSearch => _cinemas(),
    AppScreen.location => _location(),
    AppScreen.trailer => _trailer(),
    _ => const SizedBox.shrink(),
  };
  Widget _tabs() => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: ['SNEAK SHOW', 'NOW SHOWING', 'UPCOMING']
        .asMap()
        .entries
        .map(
          (e) => Flexible(
            child: InkWell(
              onTap: () {
                setState(() {
                  _tab = e.key;
                  _movieIndex = 0;
                });
                if (_posterController.hasClients) {
                  _posterController.jumpToPage(0);
                }
                if (_listController.hasClients) _listController.jumpToPage(0);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: _tab == e.key
                          ? CinemaColors.yellow
                          : Colors.transparent,
                    ),
                  ),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    e.value,
                    style: TextStyle(
                      fontSize: 12,
                      color: _tab == e.key ? Colors.white : CinemaColors.muted,
                    ),
                  ),
                ),
              ),
            ),
          ),
        )
        .toList(),
  );
  List<Movie> get _tabMovies => _tab == 2
      ? Catalog.movies.sublist(4)
      : _tab == 0
      ? Catalog.movies.sublist(2, 5)
      : Catalog.movies.take(4).toList();
  Widget _movies() {
    final movies = _tabMovies;
    final selected = movies[_movieIndex % movies.length];
    return CinemaPage(
      title: 'Hi, ${state.username}',
      back: false,
      trailing: IconButton(
        tooltip: 'Search',
        onPressed: () => go(context, AppScreen.search),
        icon: const Icon(Icons.search),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
        children: [
          const Text('Movies', style: TextStyle(fontSize: 28)),
          const SizedBox(height: 12),
          _tabs(),
          const SizedBox(height: 34),
          SizedBox(
            height: 395,
            child: LayoutBuilder(
              builder: (context, box) => Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: box.maxWidth,
                    height: 249,
                    color: const Color(0xFF5B627D),
                  ),
                  Container(
                    width: box.maxWidth * .86,
                    height: 313,
                    color: const Color(0xFF4D5673),
                  ),
                  PageView.builder(
                    controller: _posterController,
                    itemCount: movies.length,
                    onPageChanged: (i) => setState(() => _movieIndex = i),
                    itemBuilder: (context, i) => Center(
                      child: Poster(
                        width: box.maxWidth * .70,
                        height: 395,
                        color: const Color(0xFF424B68),
                        onTap: () {
                          state.selectMovie(movies[i]);
                          go(context, AppScreen.movieDetail);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            selected.title.toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            '120 minutes · 04.23.2019',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: CinemaColors.muted),
          ),
          const SizedBox(height: 30),
          Center(
            child: SizedBox(
              width: 140,
              child: ActionButton(
                'Book Ticket',
                onPressed: () {
                  state.selectMovie(selected);
                  go(context, AppScreen.movieDetail);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _search() {
    final matches = Catalog.movies
        .where((m) => m.title.toLowerCase().contains(_query.toLowerCase()))
        .toList();
    return CinemaPage(
      title: 'Search',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
        children: [
          SearchBox(onChanged: (v) => setState(() => _query = v)),
          const SizedBox(height: 30),
          if (_query.isEmpty) ...[
            SectionLabel(
              'Recent',
              onViewAll: () => go(context, AppScreen.movieList),
            ),
            const SizedBox(height: 16),
            MovieStrip(Catalog.movies.sublist(2, 4)..add(Catalog.movies[1])),
            const SizedBox(height: 22),
            SectionLabel(
              'Popular',
              onViewAll: () => go(context, AppScreen.movieList),
            ),
            const SizedBox(height: 14),
          ] else
            SectionLabel('${matches.length} results'),
          if (matches.isEmpty)
            const Padding(
              padding: EdgeInsets.all(36),
              child: Text(
                'No movies found. Try another title.',
                textAlign: TextAlign.center,
              ),
            ),
          ...(_query.isEmpty ? Catalog.movies.sublist(4, 6) : matches).map(
            (m) => MovieTile(m),
          ),
        ],
      ),
    );
  }

  Widget _comingSoon() => CinemaPage(
    title: 'ANKER CINEMA',
    child: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SectionLabel(
          'Recent',
          onViewAll: () => go(context, AppScreen.movieList),
        ),
        const Text(
          '⌖  New Delhi, NCR',
          style: TextStyle(fontSize: 12, color: CinemaColors.muted),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 310,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 2,
            separatorBuilder: (_, i) => const SizedBox(width: 16),
            itemBuilder: (context, i) {
              final m = Catalog.movies[i + 6];
              return SizedBox(
                width: 182,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Poster(
                          height: 245,
                          width: 182,
                          onTap: () {
                            state.selectMovie(m);
                            go(context, AppScreen.movieDetail);
                          },
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: IconButton(
                            tooltip: 'Favorite',
                            onPressed: () => state.toggleFavorite(m.id),
                            icon: Icon(
                              state.favorites.contains(m.id)
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(m.title, maxLines: 1),
                    const SizedBox(height: 6),
                    Rating(m.rating),
                  ],
                ),
              );
            },
          ),
        ),
        SectionLabel(
          'Coming Soon',
          onViewAll: () => go(context, AppScreen.movieList),
        ),
        const SectionLabel('Next Week'),
        MovieStrip([Catalog.movies[2], Catalog.movies[3], Catalog.movies[1]]),
        TextButton(
          onPressed: () => go(context, AppScreen.movieList),
          child: const Text(
            'Get more…',
            style: TextStyle(color: CinemaColors.blue),
          ),
        ),
      ],
    ),
  );
  Widget _movieList() => CinemaPage(
    title: 'ANKER CINEMA',
    background: const Color(0xFF484848),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _tabs(),
          const Spacer(),
          SizedBox(
            height: 155,
            child: PageView.builder(
              controller: _listController,
              itemCount: _tabMovies.length,
              onPageChanged: (i) => setState(() => _movieIndex = i),
              itemBuilder: (context, i) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: MovieTile(_tabMovies[i], light: true),
              ),
            ),
          ),
          const SizedBox(height: 16),
          PaginationDots(
            _movieIndex % _tabMovies.length,
            count: _tabMovies.length,
          ),
          const SizedBox(height: 20),
        ],
      ),
    ),
  );
  Widget _discover() => CinemaPage(
    title: 'Discover',
    back: false,
    trailing: IconButton(
      tooltip: 'Search',
      onPressed: () => go(context, AppScreen.search),
      icon: const Icon(Icons.search),
    ),
    child: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          height: 245,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF525258), CinemaColors.background],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: IconButton(
                  tooltip: 'Play trailer',
                  onPressed: () => go(context, AppScreen.trailer),
                  icon: const Icon(Icons.play_circle_outline, size: 36),
                ),
              ),
              const Spacer(),
              const Text('SPIDER MAN: HOMECOMING'),
              const SizedBox(height: 8),
              const Text(
                'UPCOMING ON MAY - 24TH - 2019',
                style: TextStyle(fontSize: 11, color: CinemaColors.muted),
              ),
              TextButton(
                onPressed: () {
                  state.selectMovie(Catalog.movies[1]);
                  go(context, AppScreen.movieDetail);
                },
                child: const Text(
                  'Get detailed',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
              const PaginationDots(1),
              const SizedBox(height: 12),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const SectionLabel('Best popular films and serials'),
        MovieStrip([Catalog.movies[2], Catalog.movies[3], Catalog.movies[1]]),
        const SizedBox(height: 22),
        InkWell(
          onTap: () => go(context, AppScreen.location),
          child: Container(
            height: 195,
            decoration: const BoxDecoration(
              color: Color(0xFF111114),
              image: DecorationImage(
                image: AssetImage('assets/images/map.png'),
                fit: BoxFit.cover,
                opacity: .35,
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Check Movie Showtimes', style: TextStyle(fontSize: 18)),
                Spacer(),
                Text('Get detailed  ›'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        const SectionLabel('Showcases'),
        MovieStrip([Catalog.movies[1], Catalog.movies[2]], height: 210),
      ],
    ),
  );
  Widget _detail() => CinemaPage(
    title: 'Movie Booking',
    trailing: IconButton(
      tooltip: 'Favorite movie',
      onPressed: () => state.toggleFavorite(state.movie.id),
      icon: Icon(
        state.favorites.contains(state.movie.id)
            ? Icons.favorite
            : Icons.favorite_border,
        size: 20,
      ),
    ),
    bottom: ActionButton(
      'Book Now',
      onPressed: () => go(context, AppScreen.showtimes),
    ),
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        Container(
          height: 295,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF525258), CinemaColors.background],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 24,
                left: 0,
                right: 0,
                child: Center(
                  child: IconButton(
                    tooltip: 'Play trailer',
                    onPressed: () => go(context, AppScreen.trailer),
                    icon: const Icon(Icons.play_circle_outline, size: 44),
                  ),
                ),
              ),
              const Positioned(
                left: 16,
                bottom: 0,
                child: Poster(
                  width: 115,
                  height: 160,
                  color: Color(0xFF484848),
                ),
              ),
              Positioned(
                left: 147,
                bottom: 12,
                right: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AgeBadge(),
                    const SizedBox(height: 14),
                    Text(state.movie.title.toUpperCase()),
                    const SizedBox(height: 12),
                    const Text(
                      'THUS, 05.22.2019',
                      style: TextStyle(fontSize: 11),
                    ),
                    const SizedBox(height: 4),
                    const Text('23:00 - 01:07', style: TextStyle(fontSize: 11)),
                    const SizedBox(height: 14),
                    FittedBox(
                      child: Rating(state.movie.rating, detailed: true),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionLabel('Story Line'),
              Text(
                _expandedStory
                    ? '$story A story about courage, connection and finding a place in the world.'
                    : story,
                style: const TextStyle(color: CinemaColors.muted, fontSize: 14),
              ),
              TextButton(
                onPressed: () =>
                    setState(() => _expandedStory = !_expandedStory),
                child: Text(
                  _expandedStory ? 'Less' : 'More',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SectionLabel('Director'),
              const Text(
                'Guillermo del Torro',
                style: TextStyle(color: CinemaColors.muted),
              ),
              const SizedBox(height: 18),
              const SectionLabel('Release Date'),
              const Text(
                '17 May 2019 (USA)',
                style: TextStyle(color: CinemaColors.muted),
              ),
              const SizedBox(height: 18),
              const SectionLabel('Genres'),
              Text(
                state.movie.genre,
                style: const TextStyle(color: CinemaColors.muted),
              ),
              const SizedBox(height: 20),
              const SectionLabel('Cast List'),
              SizedBox(
                height: 165,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: 4,
                  separatorBuilder: (_, i) => const SizedBox(width: 10),
                  itemBuilder: (context, i) => SizedBox(
                    width: 98,
                    child: InkWell(
                      onTap: () => go(context, AppScreen.actor),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Poster(width: 98, height: 112),
                          const SizedBox(height: 8),
                          Text(
                            [
                              'Darkest Hour',
                              'Eliza',
                              'Zelda',
                              'Richard Jenkin',
                            ][i],
                            style: const TextStyle(fontSize: 13),
                          ),
                          Text(
                            [
                              'Doug Jones',
                              'Sally Hawkins',
                              'Octavia Spencer',
                              'Guillermo del',
                            ][i],
                            style: const TextStyle(
                              fontSize: 11,
                              color: CinemaColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              MenuRow(
                'Reviews',
                onTap: () => go(context, AppScreen.reviews),
                subtitle: '${state.reviews.length} audience reviews',
              ),
            ],
          ),
        ),
      ],
    ),
  );
  Widget _actor() => CinemaPage(
    title: '',
    trailing: IconButton(
      tooltip: 'Favorite actor',
      onPressed: () => toast(context, 'Actor added to your preferences'),
      icon: const Icon(Icons.favorite_border),
    ),
    child: ListView(
      children: [
        Container(
          height: 255,
          color: const Color(0xFFD8D8D8),
          padding: const EdgeInsets.all(16),
          alignment: Alignment.bottomLeft,
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('PhuongAnhDao', style: TextStyle(fontSize: 24)),
              Text('#Actress #Producer'),
              Text(
                '21 W.46th St, New York, United States',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionLabel('Biography'),
              const Text(story, style: TextStyle(color: CinemaColors.muted)),
              const SizedBox(height: 24),
              SectionLabel(
                'Known For',
                onViewAll: () => go(context, AppScreen.movieList),
              ),
              MovieStrip(Catalog.movies.sublist(4, 7)),
              SectionLabel(
                'Photo Gallery',
                onViewAll: () => go(context, AppScreen.trailer),
              ),
              const Row(
                children: [
                  Expanded(child: Poster(height: 160)),
                  SizedBox(width: 16),
                  Expanded(child: Poster(height: 160)),
                ],
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Expanded(child: Poster(height: 175)),
                  SizedBox(width: 16),
                  Expanded(child: Poster(height: 175)),
                  SizedBox(width: 16),
                  Expanded(child: Poster(height: 175)),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
  Widget _reviews() => CinemaPage(
    title: 'Reviews',
    bottom: Row(
      children: [
        const Icon(Icons.add_circle, color: CinemaColors.yellow, size: 24),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: _comment,
            decoration: const InputDecoration(
              hintText: 'Say something…',
              isDense: true,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            state.addReview(_comment.text);
            _comment.clear();
            FocusScope.of(context).unfocus();
          },
          child: const Text('SEND', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
    child: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ...state.reviews
            .take(_showAllReviews ? state.reviews.length : 3)
            .map(
              (review) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                      radius: 17,
                      backgroundColor: Color(0xFFD8D8D8),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            review.author,
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            review.message,
                            style: const TextStyle(
                              color: CinemaColors.muted,
                              fontSize: 15,
                            ),
                          ),
                          IconButton(
                            tooltip: 'Like review',
                            onPressed: () => state.likeReview(review),
                            icon: Icon(
                              review.liked
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              size: 16,
                              color: review.liked
                                  ? Colors.red
                                  : CinemaColors.muted,
                            ),
                          ),
                          const Divider(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        TextButton(
          onPressed: () => setState(() => _showAllReviews = !_showAllReviews),
          child: Text(
            _showAllReviews ? 'Show fewer comments' : 'See more comments…',
            style: const TextStyle(color: CinemaColors.blue),
          ),
        ),
      ],
    ),
  );
  Widget _cinemas() {
    final search = widget.screen == AppScreen.cinemaSearch;
    final indices = [0, 1, 2].where(
      (i) => Catalog.cinemas[i].toLowerCase().contains(_query.toLowerCase()),
    );
    return CinemaPage(
      title: search ? 'Search Cinema' : 'Anker Cinema',
      trailing: search
          ? null
          : IconButton(
              tooltip: 'Search cinemas',
              onPressed: () => go(context, AppScreen.cinemaSearch),
              icon: const Icon(Icons.search),
            ),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (search) ...[
            SearchBox(
              hint: 'Anker Cine…',
              onChanged: (v) => setState(() => _query = v),
            ),
            const SizedBox(height: 18),
            const SectionLabel('Recent Search'),
          ],
          if (indices.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text('No cinemas found.'),
            ),
          ...indices.map(
            (i) => InkWell(
              onTap: () {
                state.chooseCinema(i);
                go(context, AppScreen.location);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: CinemaColors.line, width: .6),
                  ),
                ),
                child: Row(
                  children: [
                    if (!search) ...[
                      const Poster(
                        width: 90,
                        height: 90,
                        color: Color(0xFF424B68),
                      ),
                      const SizedBox(width: 16),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Anker Cinema ${Catalog.cinemas[i]}'),
                          const SizedBox(height: 8),
                          const Text(
                            '21 W.46th St, New York, United States · 12km',
                            style: TextStyle(
                              fontSize: 10,
                              color: CinemaColors.muted,
                            ),
                          ),
                          if (!search) ...[
                            const SizedBox(height: 8),
                            const Text(
                              'Rate: 7.1',
                              style: TextStyle(
                                fontSize: 10,
                                color: CinemaColors.muted,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, size: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _location() => CinemaPage(
    title: 'Location',
    child: Stack(
      children: [
        Positioned.fill(
          child: Image.asset('assets/images/map.png', fit: BoxFit.cover),
        ),
        Positioned(
          top: 20,
          left: 16,
          right: 16,
          child: SearchBox(
            hint: 'Search cinema…',
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
        for (final (i, alignment) in [
          Alignment(-.5, -.2),
          Alignment(.6, -.45),
          Alignment(.75, .1),
        ].indexed)
          Align(
            alignment: alignment,
            child: IconButton(
              tooltip: 'Select ${Catalog.cinemas[i]}',
              onPressed: () => state.chooseCinema(i),
              icon: Icon(
                Icons.location_on,
                color: state.cinemaIndex == i
                    ? CinemaColors.yellow
                    : Colors.white,
                size: 28,
              ),
            ),
          ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 24,
          child: Container(
            color: Colors.black,
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Poster(width: 110, height: 135),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(state.cinema.toUpperCase()),
                      const SizedBox(height: 12),
                      const FittedBox(child: Rating(7.8, detailed: true)),
                      const SizedBox(height: 10),
                      const Text(
                        '231 Glenholme Road Allentown, New York City',
                        style: TextStyle(fontSize: 11),
                      ),
                      TextButton(
                        onPressed: () => showModalBottomSheet<void>(
                          context: context,
                          builder: (context) => Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  state.cinema,
                                  style: const TextStyle(fontSize: 18),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  '231 Glenholme Road Allentown, New York City',
                                ),
                                const SizedBox(height: 16),
                                ActionButton(
                                  'View Showtimes',
                                  onPressed: () {
                                    Navigator.pop(context);
                                    go(this.context, AppScreen.showtimes);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        child: const Text(
                          'Get direction ›',
                          style: TextStyle(fontSize: 12, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
  Widget _trailer() => CinemaPage(
    title: state.movie.title,
    menu: false,
    background: const Color(0xFF484848),
    child: Column(
      children: [
        const Spacer(),
        IconButton(
          tooltip: _playing ? 'Pause preview' : 'Play preview',
          onPressed: () => setState(() => _playing = !_playing),
          icon: Icon(
            _playing ? Icons.pause_circle_outline : Icons.play_circle_outline,
            size: 64,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          _playing ? 'Trailer preview' : 'Tap to preview',
          style: const TextStyle(color: Color(0xFFDDDDDD)),
        ),
        const Text(
          'No video asset in the reference file',
          style: TextStyle(fontSize: 11, color: Color(0xFFDDDDDD)),
        ),
        const Spacer(),
        Slider(
          value: _position,
          min: 0,
          max: 12,
          onChanged: (v) => setState(() => _position = v),
          activeColor: Colors.red,
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text('${_position.floor()}:00'), const Text('12:00')],
          ),
        ),
      ],
    ),
  );
}
