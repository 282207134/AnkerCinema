import 'package:flutter/material.dart';
import '../core/cinema_controller.dart';
import '../core/models.dart';
import '../core/screens.dart';
import '../core/theme.dart';
import '../shared/widgets.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key, required this.screen});
  final AppScreen screen;
  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  int _cameraMode = 2;
  bool _photo = false;
  CinemaController get state => CinemaScope.of(context);
  @override
  Widget build(BuildContext context) => switch (widget.screen) {
    AppScreen.menu => _menu(),
    AppScreen.profile => _profile(),
    AppScreen.settings => _settings(),
    AppScreen.notifications => _notifications(),
    AppScreen.rewards => _rewards(),
    AppScreen.camera => _camera(),
    AppScreen.history || AppScreen.historyEmpty => _history(),
    _ => const SizedBox.shrink(),
  };
  Future<void> _logout() async {
    await state.signOut();
    if (mounted) go(context, AppScreen.auth, reset: true);
  }

  Widget _menu() => Scaffold(
    body: SafeArea(
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(width: 78, color: const Color(0xFF484848)),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              child: ListView(
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      tooltip: 'Close menu',
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ),
                  _nav('Home', Icons.home_outlined, AppScreen.movies),
                  _nav('Discover', Icons.explore_outlined, AppScreen.discover),
                  _nav(
                    'Coming Soon',
                    Icons.movie_outlined,
                    AppScreen.comingSoon,
                  ),
                  _nav('Anker Member', Icons.person_outline, AppScreen.rewards),
                  _nav(
                    'Anker Cinema',
                    Icons.local_movies_outlined,
                    AppScreen.cinemas,
                  ),
                  MenuRow(
                    'Preference',
                    icon: Icons.card_giftcard,
                    onTap: _preferences,
                  ),
                  _nav(
                    'Notification',
                    Icons.notifications_none,
                    AppScreen.notifications,
                  ),
                  _nav('History', Icons.history, AppScreen.history),
                  _nav(
                    'Profile',
                    Icons.account_circle_outlined,
                    AppScreen.profile,
                  ),
                  _nav('Setting', Icons.settings_outlined, AppScreen.settings),
                  const SizedBox(height: 38),
                  TextButton(
                    onPressed: _logout,
                    child: const Text(
                      'LOG OUT   ➜',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
  Widget _nav(String label, IconData icon, AppScreen screen) =>
      MenuRow(label, icon: icon, onTap: () => go(context, screen));
  Widget _profile() => CinemaPage(
    title: 'Profile',
    menu: false,
    bottom: ActionButton('Log out', outlined: true, onPressed: _logout),
    child: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 34),
        Center(
          child: Stack(
            children: [
              const CircleAvatar(
                radius: 56,
                backgroundColor: Color(0xFFB4B4B4),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: InkWell(
                  onTap: () => go(context, AppScreen.camera),
                  child: const CircleAvatar(
                    radius: 12,
                    backgroundColor: CinemaColors.yellow,
                    child: Icon(
                      Icons.camera_alt_outlined,
                      size: 16,
                      color: CinemaColors.background,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        Text(
          state.username,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 10),
        Text(
          state.email,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14),
        ),
        TextButton(
          onPressed: _editProfile,
          child: const Text('Edit Info.', style: TextStyle(fontSize: 14)),
        ),
        const SizedBox(height: 34),
        _nav('Payment', Icons.credit_card, AppScreen.checkout),
        _nav('Notification', Icons.notifications_none, AppScreen.notifications),
        MenuRow('Preference', icon: Icons.card_giftcard, onTap: _preferences),
        _nav('Setting', Icons.settings_outlined, AppScreen.settings),
      ],
    ),
  );
  Future<void> _editProfile() async {
    final name = TextEditingController(text: state.username);
    final email = TextEditingController(text: state.email);
    final form = GlobalKey<FormState>();
    final result = await showDialog<(String, String)>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Info.'),
        content: Form(
          key: form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (v) =>
                    (v ?? '').trim().isEmpty ? 'Enter username' : null,
              ),
              TextFormField(
                controller: email,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) =>
                    RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(v ?? '')
                    ? null
                    : 'Enter a valid email',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (form.currentState!.validate()) {
                Navigator.pop(context, (name.text, email.text));
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    // Dispose after the dialog route has finished its closing animation.
    await Future<void>.delayed(const Duration(milliseconds: 250));
    name.dispose();
    email.dispose();
    if (result != null && mounted) {
      await state.updateProfile(result.$1, result.$2);
    }
  }

  void _preferences() => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Preference', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            if (state.favorites.isEmpty)
              const Text(
                'Tap the heart on a movie to save it here.',
                style: TextStyle(color: CinemaColors.muted),
              ),
            ...Catalog.movies
                .where((m) => state.favorites.contains(m.id))
                .map(
                  (m) => MenuRow(
                    m.title,
                    icon: Icons.favorite,
                    onTap: () {
                      state.selectMovie(m);
                      Navigator.pop(context);
                      go(this.context, AppScreen.movieDetail);
                    },
                  ),
                ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    ),
  );
  Widget _settings() => CinemaPage(
    title: 'Setting',
    child: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 16),
        const ProfileIdentity(),
        const SizedBox(height: 26),
        const SectionLabel('Languages'),
        MenuRow(
          'English',
          onTap: () =>
              _info('Language', 'The reference UI is available in English.'),
        ),
        const SizedBox(height: 20),
        const SectionLabel('Others'),
        MenuRow(
          'Notifications',
          onTap: () => state.setNotifications(!state.notificationsEnabled),
          trailing: Switch(
            value: state.notificationsEnabled,
            onChanged: state.setNotifications,
            activeThumbColor: Colors.white,
            activeTrackColor: Colors.orange,
          ),
        ),
        MenuRow(
          'FAQs',
          onTap: () => _info(
            'FAQs',
            'How do I book?\nChoose a movie, time and seats, then confirm your order.\n\nWhere is my ticket?\nOpen History from the menu.\n\nDemo promo: ANKER30\nDemo verification code: 5012',
          ),
        ),
        MenuRow(
          'Private Policy',
          onTap: () => _info(
            'Privacy Policy',
            'This offline demonstration saves your profile, favorites, notification preference and demo booking history on this device. Passwords, card details and verification codes are not saved.',
          ),
        ),
        MenuRow(
          'Support',
          onTap: () => _info(
            'Support',
            'Anker Cinema is a local UI demonstration. For help with this project, see the included README and architecture document.',
          ),
        ),
      ],
    ),
  );
  void _info(String title, String text) => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(child: Text(text)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    ),
  );
  Widget _notifications() => CinemaPage(
    title: 'Notifications',
    child: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 18),
        ...List.generate(
          4,
          (i) => Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: MenuRow(
              [
                'Summer In Closed Eyes will be available for sale from May 24th to Jun 20th. Only at Anker Cinema.',
                'Anker Day: Super sale for Mother’s Day. Only on 20th May.',
                'Avengers: Endgame tickets now on sale online, if you can get them',
                'Avengers: Endgame tickets now on sale online, if you can get them',
              ][i],
              icon: i < 2 ? Icons.celebration : Icons.card_giftcard,
              subtitle: [
                '3 hours ago',
                '5 hours ago',
                '5 hours ago',
                '5 days ago',
              ][i],
              onTap: () {
                if (i == 1) {
                  go(context, AppScreen.promo);
                } else {
                  state.selectMovie(Catalog.movies[i == 0 ? 4 : 1]);
                  go(context, AppScreen.movieDetail);
                }
              },
            ),
          ),
        ),
      ],
    ),
  );
  Widget _rewards() => CinemaPage(
    title: '',
    menu: false,
    bottom: ActionButton(
      'Home',
      onPressed: () => go(context, AppScreen.movies, reset: true),
    ),
    child: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 10),
        const ProfileIdentity(),
        const SizedBox(height: 40),
        SizedBox(
          height: 245,
          child: ClipRect(
            child: OverflowBox(
              maxWidth: 610,
              alignment: Alignment.centerRight,
              child: Image.asset(
                'assets/images/reward.png',
                width: 610,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'REWARDS',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 18),
        const Text(
          'Gold Member *',
          textAlign: TextAlign.center,
          style: TextStyle(color: CinemaColors.yellow),
        ),
        const SizedBox(height: 12),
        const Text(
          '40% Left Up to Diamond Member',
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
  Widget _history() {
    final empty =
        widget.screen == AppScreen.historyEmpty || state.bookings.isEmpty;
    return CinemaPage(
      title: 'History',
      bottom: ActionButton(
        empty ? 'Home' : 'Clear All',
        outlined: !empty,
        onPressed: empty
            ? () => go(context, AppScreen.movies, reset: true)
            : _clearHistory,
      ),
      child: empty
          ? SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  const SizedBox(height: 66),
                  Image.asset(
                    'assets/images/empty_history.png',
                    width: 159,
                    height: 227,
                  ),
                  const SizedBox(height: 36),
                  const Text('No Transactions', style: TextStyle(fontSize: 20)),
                  const SizedBox(height: 24),
                  const Text(
                    'Your movie nights will appear here. Book a ticket to get started.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const SectionLabel('Recent Transactions'),
                _historyTile(state.bookings.first),
                if (state.bookings.length > 1) ...[
                  const SizedBox(height: 22),
                  const SectionLabel('Other Transactions'),
                  ...state.bookings.skip(1).map(_historyTile),
                ],
              ],
            ),
    );
  }

  Widget _historyTile(Booking booking) => InkWell(
    onTap: () {
      state.openTicket(booking);
      go(context, AppScreen.ticket);
    },
    child: Container(
      height: 110,
      margin: const EdgeInsets.only(bottom: 24),
      color: CinemaColors.purple,
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.all(12),
            child: Icon(Icons.qr_code, size: 56),
          ),
          Container(height: 70, width: 1, color: CinemaColors.muted),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Catalog.movie(booking.movieId).title.toUpperCase(),
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 8),
                Text(
                  'THUS, 05.${booking.day}.2019',
                  style: const TextStyle(fontSize: 10),
                ),
                const SizedBox(height: 8),
                Text(
                  'TOTAL PRICE: ${money(booking.totalCents)}',
                  style: const TextStyle(fontSize: 11),
                ),
              ],
            ),
          ),
          Container(
            color: CinemaColors.yellow,
            width: 30,
            height: 70,
            child: const Icon(
              Icons.chevron_right,
              color: CinemaColors.background,
            ),
          ),
        ],
      ),
    ),
  );
  Future<void> _clearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear history?'),
        content: const Text('Remove all demo bookings from this device?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) await state.clearHistory();
  }

  Widget _camera() => Scaffold(
    body: SafeArea(
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              tooltip: 'Close camera',
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close),
            ),
          ),
          Expanded(
            child: Center(
              child: _photo
                  ? const CircleAvatar(
                      radius: 90,
                      backgroundColor: Color(0xFFB4B4B4),
                      child: Icon(Icons.person, size: 100, color: Colors.white),
                    )
                  : const Text(
                      'Camera preview',
                      style: TextStyle(fontSize: 12, color: CinemaColors.muted),
                    ),
            ),
          ),
          const Text(
            'Photo demo · camera hardware is not connected',
            style: TextStyle(fontSize: 10, color: CinemaColors.muted),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  tooltip: 'Retake',
                  onPressed: () => setState(() => _photo = false),
                  icon: const Icon(Icons.photo_outlined),
                ),
                IconButton(
                  tooltip: _photo ? 'Use photo' : 'Take photo',
                  iconSize: 62,
                  onPressed: () {
                    if (_photo) {
                      Navigator.pop(context);
                      toast(context, 'Demo profile photo selected');
                    } else {
                      setState(() => _photo = true);
                    }
                  },
                  icon: Icon(
                    _photo ? Icons.check_circle : Icons.radio_button_checked,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  tooltip: 'Switch camera',
                  onPressed: () => toast(context, 'Front camera preview'),
                  icon: const Icon(Icons.cameraswitch_outlined),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['SLO-MO', 'NORMAL', 'NATURE', 'ZOOM', 'TIME-LAPSE']
                  .asMap()
                  .entries
                  .map(
                    (e) => TextButton(
                      onPressed: () => setState(() => _cameraMode = e.key),
                      child: Text(
                        e.value,
                        style: TextStyle(
                          color: _cameraMode == e.key
                              ? CinemaColors.yellow
                              : Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    ),
  );
}
