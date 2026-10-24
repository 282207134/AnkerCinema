import 'package:flutter/material.dart';
import '../core/cinema_controller.dart';
import '../core/models.dart';
import '../core/screens.dart';
import '../core/theme.dart';
import '../shared/widgets.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key, required this.screen});
  final AppScreen screen;
  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _promo = TextEditingController();
  final _cardNumber = TextEditingController();
  final _expiry = TextEditingController();
  final _cvv = TextEditingController();
  final _holder = TextEditingController();
  final _cardForm = GlobalKey<FormState>();
  String _code = '';
  String? _promoError;
  bool _busy = false;
  int _method = 0;
  CinemaController get state => CinemaScope.of(context);
  @override
  void dispose() {
    for (final c in [_promo, _cardNumber, _expiry, _cvv, _holder]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => switch (widget.screen) {
    AppScreen.showtimes => _showtimes(),
    AppScreen.seats => _seats(),
    AppScreen.combos => _combos(),
    AppScreen.ticket => _ticket(),
    AppScreen.promo => _promoPage(),
    AppScreen.promoSuccess => _promoSuccess(),
    AppScreen.payment => _payment(),
    AppScreen.checkout => _payment(checkout: true),
    AppScreen.card => _card(),
    AppScreen.verify => _verify(),
    AppScreen.verifyCode => _verifyCode(),
    AppScreen.paymentSuccess => _success(),
    _ => const SizedBox.shrink(),
  };
  Widget _movieHeader() => Container(
    height: 110,
    width: double.infinity,
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF525258), CinemaColors.background],
      ),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          state.movie.title.toUpperCase(),
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 14),
        Text(
          '2D English | ${state.movie.genre.split(' / ').first} | 120 Mins',
          style: const TextStyle(fontSize: 11, color: Color(0xFFD1D1D1)),
        ),
      ],
    ),
  );
  Widget _showtimes() => CinemaPage(
    title: 'Movie Booking',
    bottom: ActionButton(
      'Continue',
      onPressed: () => go(context, AppScreen.seats),
    ),
    child: ListView(
      children: [
        _movieHeader(),
        Container(
          color: const Color(0xFF111017),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              7,
              (i) => InkWell(
                onTap: () => state.chooseDay(i + 16),
                child: Container(
                  width: 42,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: state.day == i + 16
                            ? CinemaColors.yellow
                            : Colors.transparent,
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        ['THUR', 'FRI', 'SAT', 'SUN', 'MON', 'TUE', 'WED'][i],
                        style: TextStyle(
                          fontSize: 8,
                          color: state.day == i + 16
                              ? Colors.white
                              : CinemaColors.muted,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${i + 16}',
                        style: TextStyle(
                          fontSize: 18,
                          color: state.day == i + 16
                              ? Colors.white
                              : CinemaColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionLabel('Choose Location'),
              ...List.generate(
                3,
                (i) => Column(
                  children: [
                    MenuRow(
                      'Anker Cinema ${Catalog.cinemas[i]}',
                      subtitle: '21 W.46th St, New York, United States · 112km',
                      trailing: Icon(
                        state.cinemaIndex == i
                            ? Icons.expand_more
                            : Icons.chevron_right,
                        size: 20,
                      ),
                      onTap: () => state.chooseCinema(i),
                    ),
                    if (state.cinemaIndex == i)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: List.generate(
                            Catalog.times.length,
                            (t) => InkWell(
                              onTap: () => state.chooseTime(t),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: state.timeIndex == t
                                      ? CinemaColors.yellow
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: state.timeIndex == t
                                        ? CinemaColors.yellow
                                        : CinemaColors.muted,
                                    width: .7,
                                  ),
                                ),
                                child: Text(
                                  Catalog.times[t],
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: state.timeIndex == t
                                        ? CinemaColors.background
                                        : Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
  Widget _seatMap() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Column(
      children: [
        const Text('SCREEN', style: TextStyle(fontSize: 10)),
        const SizedBox(height: 7),
        Container(height: 1, width: 186, color: CinemaColors.muted),
        const SizedBox(height: 26),
        Row(
          children: [
            const SizedBox(width: 24),
            ...List.generate(
              12,
              (col) => Expanded(
                child: Center(
                  child: Text(
                    '${col + 1}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: CinemaColors.muted,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...List.generate(
          8,
          (row) => Padding(
            padding: EdgeInsets.only(bottom: row == 3 ? 22 : 6),
            child: Row(
              children: [
                SizedBox(
                  width: 24,
                  child: Text(
                    String.fromCharCode(65 + row),
                    style: const TextStyle(
                      fontSize: 10,
                      color: CinemaColors.muted,
                    ),
                  ),
                ),
                ...List.generate(12, (col) {
                  final seat = '${String.fromCharCode(65 + row)}${col + 1}';
                  final exists = CinemaController.seatExists(row, col);
                  final occupied = CinemaController.unavailable.contains(seat);
                  final selected = state.selectedSeats.contains(seat);
                  return Expanded(
                    child: Semantics(
                      label: 'Seat $seat',
                      selected: selected,
                      enabled: exists && !occupied,
                      button: true,
                      child: InkWell(
                        key: ValueKey('seat-$seat'),
                        onTap: exists && !occupied
                            ? () => state.toggleSeat(seat)
                            : null,
                        child: SizedBox(
                          height: 20,
                          child: Center(
                            child: Container(
                              width: 15,
                              height: 15,
                              color: !exists
                                  ? Colors.transparent
                                  : selected
                                  ? CinemaColors.selected
                                  : row == 7
                                  ? CinemaColors.couple
                                  : CinemaColors.seat,
                              child: occupied
                                  ? const Center(
                                      child: Text(
                                        '×',
                                        style: TextStyle(
                                          fontSize: 13,
                                          height: 1,
                                          color: Colors.white,
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _legend(CinemaColors.seat, 'Available'),
            _legend(CinemaColors.selected, 'Your Choose'),
            _legend(CinemaColors.couple, 'Couple'),
          ],
        ),
      ],
    ),
  );
  Widget _legend(Color color, String label) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
      const SizedBox(width: 6),
      Text(label, style: const TextStyle(fontSize: 9)),
    ],
  );
  Widget _seatSummary() => Container(
    margin: const EdgeInsets.all(16),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      border: Border.all(color: CinemaColors.muted, width: .7),
    ),
    child: Row(
      children: [
        Column(
          children: [
            const Text('SUN', style: TextStyle(fontSize: 8)),
            Text('${state.day}', style: const TextStyle(fontSize: 18)),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(state.cinema, style: const TextStyle(fontSize: 12)),
              const SizedBox(height: 8),
              Text(
                'SEAT: ${(state.selectedSeats.toList()..sort()).join(' + ')}  (${state.time})',
                style: const TextStyle(fontSize: 10, color: Color(0xFFD1D1D1)),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'X${state.selectedSeats.length} TICKETS',
          style: const TextStyle(fontSize: 11),
        ),
      ],
    ),
  );
  Widget _seats() => CinemaPage(
    title: 'Movie Booking',
    bottom: ActionButton(
      state.totalLabel,
      onPressed: state.selectedSeats.isEmpty
          ? null
          : () => go(context, AppScreen.combos),
    ),
    child: ListView(
      children: [
        _movieHeader(),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 14, 16, 26),
          child: Text('CHOOSE SEAT', style: TextStyle(fontSize: 12)),
        ),
        _seatMap(),
        const SizedBox(height: 14),
        _seatSummary(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: InkWell(
            onTap: () => go(context, AppScreen.promo),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Icon(
                    state.promoApplied
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    size: 17,
                    color: state.promoApplied
                        ? CinemaColors.yellow
                        : CinemaColors.muted,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    state.promoApplied
                        ? 'ANKER30 applied · 30% off tickets'
                        : 'Apply My Promote Code',
                    style: const TextStyle(fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
  Widget _combos() => CinemaPage(
    title: 'Movie Booking',
    background: const Color(0xFF1C1C1C),
    bottom: ActionButton(
      state.totalLabel,
      onPressed: () => go(context, AppScreen.ticket),
    ),
    child: ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 16),
      itemCount: Catalog.combos.length,
      separatorBuilder: (_, i) => const SizedBox(height: 20),
      itemBuilder: (context, i) {
        final item = Catalog.combos[i];
        final count = state.comboQuantities[i] ?? 0;
        return SizedBox(
          height: 82,
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: CinemaColors.line),
                ),
                child: Image.asset('assets/images/popcorn.png'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name),
                    const SizedBox(height: 12),
                    const Text(
                      '1 Small Popcorn + 1 Drink',
                      style: TextStyle(fontSize: 10, color: CinemaColors.muted),
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(money(item.cents), style: const TextStyle(fontSize: 16)),
                  Row(
                    children: [
                      InkWell(
                        key: ValueKey('combo-$i-minus'),
                        onTap: count > 0
                            ? () => state.changeCombo(i, -1)
                            : null,
                        child: const Padding(
                          padding: EdgeInsets.all(6),
                          child: Icon(Icons.remove, size: 16),
                        ),
                      ),
                      SizedBox(
                        width: 16,
                        child: Text('$count', textAlign: TextAlign.center),
                      ),
                      InkWell(
                        key: ValueKey('combo-$i-plus'),
                        onTap: () => state.changeCombo(i, 1),
                        child: const Padding(
                          padding: EdgeInsets.all(6),
                          child: Icon(Icons.add, size: 16),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    ),
  );
  Widget _ticketCard() {
    final ticket = state.currentTicket;
    final seats = ticket?.seats ?? (state.selectedSeats.toList()..sort());
    final movie = ticket == null ? state.movie : Catalog.movie(ticket.movieId);
    return Container(
      decoration: const BoxDecoration(
        color: CinemaColors.purple,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Poster(
            height: 190,
            width: double.infinity,
            color: Color(0xFF484848),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const AgeBadge(),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text('${movie.title.toUpperCase()} (2018)'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Padding(
                  padding: EdgeInsets.only(left: 64),
                  child: Text(
                    '#Biography  #Crime  #Drama',
                    style: TextStyle(fontSize: 10, color: CinemaColors.muted),
                  ),
                ),
                const SizedBox(height: 28),
                _ticketInfo(
                  'Date & Time',
                  'May ${ticket?.day ?? state.day}, 2019',
                  second: ticket?.time ?? state.time,
                ),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _ticketColumn('Hall', '3'),
                    _ticketColumn('Row', seats.isEmpty ? '—' : seats.first[0]),
                    _ticketColumn('Seat', seats.join(', ')),
                    _ticketColumn('Status', 'Adults'),
                  ],
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: _ticketColumn(
                        'Ticket ID',
                        ticket == null
                            ? 'ABC123456789'
                            : ticket.id.substring(ticket.id.length - 12),
                      ),
                    ),
                    _ticketColumn(
                      'Price',
                      money(ticket?.totalCents ?? state.totalCents),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Container(
                  height: 48,
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: CustomPaint(
                    size: const Size(double.infinity, 48),
                    painter: _BarcodePainter(),
                  ),
                ),
                const SizedBox(height: 8),
                const Center(
                  child: Text(
                    'DEMO TICKET · NOT VALID FOR ENTRY',
                    style: TextStyle(fontSize: 8, color: CinemaColors.muted),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _ticketColumn(String label, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(fontSize: 11, color: CinemaColors.muted),
      ),
      const SizedBox(height: 10),
      Text(value, style: const TextStyle(fontSize: 13)),
    ],
  );
  Widget _ticketInfo(String label, String value, {required String second}) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: CinemaColors.muted),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text(value), Text(second)],
          ),
        ],
      );
  Widget _ticket() => CinemaPage(
    title: 'Check out',
    bottom: ActionButton(
      state.currentTicket == null ? 'Confirm' : 'Home',
      onPressed: () => go(
        context,
        state.currentTicket == null ? AppScreen.payment : AppScreen.movies,
        reset: state.currentTicket != null,
      ),
    ),
    child: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: _ticketCard(),
    ),
  );
  Widget _promoPage() => CinemaPage(
    title: 'Movie Booking',
    menu: false,
    child: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              color: CinemaColors.purple,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SectionLabel('Promote Code'),
                  TextField(
                    controller: _promo,
                    decoration: InputDecoration(
                      hintText: 'Enter Promote Code',
                      errorText: _promoError,
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                  const SizedBox(height: 26),
                  Container(
                    width: double.infinity,
                    color: CinemaColors.panel,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Container(
                          color: CinemaColors.yellow,
                          padding: const EdgeInsets.all(8),
                          child: const Text(
                            'WESTERN UNION',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        const Text('Get Flat'),
                        const Text(
                          '30%',
                          style: TextStyle(
                            fontSize: 60,
                            color: CinemaColors.selected,
                          ),
                        ),
                        const Text('CASH BACK'),
                        const SizedBox(height: 8),
                        const Text(
                          'With your Western Union Bank Credit Card',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            color: CinemaColors.muted,
                          ),
                        ),
                        const SizedBox(height: 26),
                        TextButton(
                          onPressed: () => setState(() {
                            _promo.text = 'ANKER30';
                            _promoError = null;
                          }),
                          child: const Text(
                            '○  REDEEM CODE',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Demo code: ANKER30 · 30% off tickets',
                    style: TextStyle(fontSize: 11, color: CinemaColors.muted),
                  ),
                  const SizedBox(height: 24),
                  ActionButton(
                    'Apply',
                    onPressed: () {
                      if (state.applyPromo(_promo.text)) {
                        go(context, AppScreen.promoSuccess);
                      } else {
                        setState(
                          () => _promoError = 'Use the demo code ANKER30',
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            IconButton(
              tooltip: 'Close promo',
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.cancel,
                color: CinemaColors.yellow,
                size: 36,
              ),
            ),
          ],
        ),
      ),
    ),
  );
  Widget _promoSuccess() => CinemaPage(
    title: '',
    menu: false,
    bottom: ActionButton(
      'Continue Booking',
      onPressed: () {
        var found = false;
        Navigator.popUntil(context, (route) {
          found = route.settings.name == AppScreen.seats.route;
          return found || route.isFirst;
        });
        if (!found) go(context, AppScreen.seats);
      },
    ),
    child: Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'ENTER THE CODE SUCCESSFULLY',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          Text(
            'Your promotion has been applied. You saved ${money(state.discountCents)} on your tickets.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 32),
          const Text(
            'Get more transactions…',
            style: TextStyle(color: CinemaColors.yellow, fontSize: 14),
          ),
        ],
      ),
    ),
  );
  Widget _orderSummary({bool yellow = false}) => Container(
    color: yellow ? CinemaColors.yellow : Colors.transparent,
    padding: EdgeInsets.all(yellow ? 20 : 0),
    child: DefaultTextStyle(
      style: TextStyle(
        fontFamily: 'Futura',
        color: yellow ? CinemaColors.background : Colors.white,
        fontSize: 12,
      ),
      child: Row(
        children: [
          if (!yellow) ...[
            const Poster(width: 115, height: 160),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AgeBadge(),
                const SizedBox(height: 12),
                Text(
                  state.movie.title.toUpperCase(),
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 10),
                Text('THUS, 05.${state.day}.2019'),
                const SizedBox(height: 6),
                Text(state.time),
                if (yellow) ...[
                  const SizedBox(height: 8),
                  Text(state.cinema),
                  const SizedBox(height: 8),
                  Text(
                    '${state.selectedSeats.length} Seats · ${(state.selectedSeats.toList()..sort()).join(', ')}',
                  ),
                ],
                const SizedBox(height: 18),
                Text('TOTAL PRICE: ${money(state.totalCents)}'),
                if (state.promoApplied)
                  Text(
                    'Includes ${money(state.discountCents)} ticket discount',
                    style: const TextStyle(fontSize: 10),
                  ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
  Widget _payment({bool checkout = false}) => CinemaPage(
    title: checkout ? 'Checkout Process' : 'Payment',
    bottom: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ActionButton(
          checkout ? 'Processed Payment' : state.totalLabel,
          onPressed: () =>
              go(context, _method == 0 ? AppScreen.verify : AppScreen.card),
        ),
        const SizedBox(height: 10),
        const Text(
          'Local demo · No charge will be made',
          style: TextStyle(fontSize: 10, color: CinemaColors.muted),
        ),
      ],
    ),
    child: ListView(
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 16),
      children: [
        _orderSummary(yellow: checkout),
        const SizedBox(height: 26),
        const SectionLabel('Payment Method'),
        MenuRow(
          'VISA **** **** **** 1234',
          icon: Icons.credit_card,
          onTap: () => setState(() => _method = 0),
          trailing: Icon(
            _method == 0
                ? Icons.radio_button_checked
                : Icons.radio_button_unchecked,
            size: 18,
          ),
        ),
        if (checkout) ...[
          TextButton(
            onPressed: () => go(context, AppScreen.card),
            child: const Text(
              'Add New ⊕',
              style: TextStyle(color: CinemaColors.selected),
            ),
          ),
          SizedBox(
            height: 194,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              separatorBuilder: (_, i) => const SizedBox(width: 10),
              itemBuilder: (context, i) => InkWell(
                onTap: () => setState(() => _method = i + 1),
                child: Container(
                  width: 140,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: CinemaColors.panel,
                    border: Border.all(
                      color: _method == i + 1
                          ? CinemaColors.yellow
                          : CinemaColors.line,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            ['●●', '▰', 'VISA'][i],
                            style: TextStyle(
                              color: i == 0
                                  ? Colors.orange
                                  : CinemaColors.selected,
                              fontSize: 20,
                            ),
                          ),
                          Icon(
                            _method == i + 1
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                            size: 16,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Valid\n02/30',
                        style: TextStyle(fontSize: 10),
                      ),
                      const Spacer(),
                      const Icon(Icons.sim_card_outlined),
                      const Text(
                        'Credit\nXXXX 9834',
                        style: TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
        MenuRow(
          'Other Card',
          subtitle: 'ATM / International card',
          onTap: () => go(context, AppScreen.card),
        ),
        if (!checkout)
          MenuRow(
            'View all payment methods',
            icon: Icons.account_balance_wallet_outlined,
            onTap: () => go(context, AppScreen.checkout),
          ),
      ],
    ),
  );
  Widget _card() => CinemaPage(
    title: 'Payment',
    bottom: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ActionButton(
          'Continue',
          onPressed: () {
            if (_cardForm.currentState!.validate()) {
              FocusScope.of(context).unfocus();
              go(context, AppScreen.verify);
            }
          },
        ),
        const SizedBox(height: 12),
        const Text(
          'Demo card: 4242 4242 4242 4242',
          style: TextStyle(fontSize: 10, color: CinemaColors.muted),
        ),
      ],
    ),
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _cardForm,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Brand(yellow: true),
            const SizedBox(height: 26),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: CinemaColors.line),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('SERI'),
                      const Text(
                        'MD-5525951110449297',
                        style: TextStyle(
                          fontSize: 10,
                          color: CinemaColors.muted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('PRICES'),
                      Text(money(state.totalCents)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: CinemaColors.line),
              ),
              child: Column(
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'VISA',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextFormField(
                    controller: _cardNumber,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Card number'),
                    validator: (v) =>
                        (v ?? '').replaceAll(' ', '') == '4242424242424242'
                        ? null
                        : 'Use demo card 4242 4242 4242 4242',
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _expiry,
                          keyboardType: TextInputType.datetime,
                          decoration: const InputDecoration(
                            labelText: 'Expired Date (MM/YY)',
                          ),
                          validator: (v) {
                            final match = RegExp(
                              r'^(0[1-9]|1[0-2])/(\d{2})$',
                            ).firstMatch(v ?? '');
                            if (match == null) return 'Use MM/YY';
                            final now = DateTime.now();
                            final until = DateTime(
                              2000 + int.parse(match[2]!),
                              int.parse(match[1]!) + 1,
                            );
                            return until.isAfter(now) ? null : 'Card expired';
                          },
                        ),
                      ),
                      const SizedBox(width: 20),
                      SizedBox(
                        width: 90,
                        child: TextFormField(
                          controller: _cvv,
                          keyboardType: TextInputType.number,
                          obscureText: true,
                          decoration: const InputDecoration(labelText: 'CVV'),
                          validator: (v) => RegExp(r'^\d{3}$').hasMatch(v ?? '')
                              ? null
                              : '3 digits',
                        ),
                      ),
                    ],
                  ),
                  TextFormField(
                    controller: _holder,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(labelText: 'Card holder'),
                    validator: (v) =>
                        (v ?? '').trim().isEmpty ? 'Enter card holder' : null,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Card details stay in this form and are never stored.',
              style: TextStyle(fontSize: 11, color: CinemaColors.muted),
            ),
          ],
        ),
      ),
    ),
  );
  Widget _verify() => CinemaPage(
    title: '',
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          const Text('VERIFY', style: TextStyle(fontSize: 30)),
          const Spacer(),
          const Center(
            child: Text('Verify with Phone', style: TextStyle(fontSize: 12)),
          ),
          const SizedBox(height: 24),
          Center(
            child: SizedBox(
              width: 215,
              child: ActionButton(
                'Send code',
                onPressed: () => go(context, AppScreen.verifyCode),
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Center(
            child: Text(
              'Demo verification code: 5012',
              style: TextStyle(fontSize: 11, color: CinemaColors.muted),
            ),
          ),
          const Spacer(),
          const Center(
            child: Text(
              'Or confirm your demo order',
              style: TextStyle(fontSize: 12),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: IconButton(
              tooltip: 'Confirm demo order',
              onPressed: _busy ? null : _finish,
              icon: const Icon(
                Icons.fingerprint,
                size: 56,
                color: CinemaColors.muted,
              ),
            ),
          ),
          const Spacer(),
        ],
      ),
    ),
  );
  Future<void> _finish() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await state.completeBooking();
      if (!mounted) return;
      go(context, AppScreen.paymentSuccess, reset: true);
    } on StateError catch (error) {
      if (mounted) toast(context, error.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _typeDigit(String digit) {
    if (_code.length >= 4 || _busy) return;
    setState(() => _code += digit);
    if (_code.length == 4) {
      if (_code == '5012') {
        _finish();
      } else {
        toast(context, 'Use the demo code 5012');
        setState(() => _code = '');
      }
    }
  }

  Widget _verifyCode() => CinemaPage(
    title: '',
    child: LayoutBuilder(
      builder: (context, box) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: box.maxHeight),
          child: IntrinsicHeight(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 30, 16, 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('VERIFY', style: TextStyle(fontSize: 30)),
                  ),
                ),
                const Spacer(),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 60),
                  child: Text(
                    'Please type the verification code sent to (+501) 425 906 ****',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    4,
                    (i) => Container(
                      width: 52,
                      height: 58,
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(color: CinemaColors.muted),
                      ),
                      child: Text(
                        i < _code.length ? _code[i] : '',
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'I didn’t receive a code!',
                  style: TextStyle(fontSize: 12),
                ),
                TextButton(
                  onPressed: () {
                    setState(() => _code = '');
                    toast(context, 'Demo code: 5012');
                  },
                  child: const Text('Resend'),
                ),
                const Spacer(),
                Container(
                  color: const Color(0xFF16151B),
                  padding: const EdgeInsets.all(6),
                  child: Column(
                    children: [
                      for (int row = 0; row < 3; row++)
                        Row(
                          children: List.generate(3, (col) {
                            final digit = '${row * 3 + col + 1}';
                            return Expanded(
                              child: _key(digit, () => _typeDigit(digit)),
                            );
                          }),
                        ),
                      Row(
                        children: [
                          const Expanded(child: SizedBox()),
                          Expanded(child: _key('0', () => _typeDigit('0'))),
                          Expanded(
                            child: _key(
                              '⌫',
                              () => setState(
                                () => _code = _code.isEmpty
                                    ? ''
                                    : _code.substring(0, _code.length - 1),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  Widget _key(String label, VoidCallback tap) => Padding(
    padding: const EdgeInsets.all(4),
    child: Material(
      color: const Color(0xFF696D70),
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        key: ValueKey('digit-$label'),
        onTap: _busy ? null : tap,
        child: SizedBox(
          height: 54,
          child: Center(
            child: Text(label, style: const TextStyle(fontSize: 28)),
          ),
        ),
      ),
    ),
  );
  Widget _success() => CinemaPage(
    title: 'Payment Success',
    bottom: ActionButton(
      'Home',
      onPressed: () => go(context, AppScreen.movies, reset: true),
    ),
    child: SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          const SizedBox(height: 100),
          Image.asset('assets/images/popcorn.png', width: 160, height: 195),
          const SizedBox(height: 42),
          const Text(
            'TICKET BOOKED SUCCESSFULLY',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          const Text(
            'Congratulations! Your ticket has been booked successfully. You can find it in your booking history.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () => go(context, AppScreen.ticket),
            child: const Text('View Ticket'),
          ),
        ],
      ),
    ),
  );
}

class _BarcodePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black;
    double x = 0;
    int n = 7;
    while (x < size.width) {
      n = (n * 13 + 11) % 97;
      final w = (n % 3 + 1).toDouble();
      canvas.drawRect(Rect.fromLTWH(x, 0, w, size.height), paint);
      x += w + (n % 2 + 1);
    }
  }

  @override
  bool shouldRepaint(_BarcodePainter oldDelegate) => false;
}
