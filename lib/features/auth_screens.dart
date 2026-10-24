import 'package:flutter/material.dart';
import '../core/cinema_controller.dart';
import '../core/screens.dart';
import '../core/theme.dart';
import '../shared/widgets.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.screen});
  final AppScreen screen;
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController(text: 'satiago@gmail.com');
  final _password = TextEditingController();
  final _name = TextEditingController(text: 'Ackermanlhn');
  final _phone = TextEditingController();
  final _dob = TextEditingController();
  bool _obscure = true;
  @override
  void dispose() {
    for (final c in [_email, _password, _name, _phone, _dob]) {
      c.dispose();
    }
    super.dispose();
  }

  void _next() =>
      go(context, AppScreen.values[widget.screen.index + 1], reset: true);
  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    await CinemaScope.of(context).signIn(
      _email.text.trim(),
      name: widget.screen == AppScreen.signup ? _name.text : null,
    );
    if (!mounted) return;
    go(context, AppScreen.onboardingBooking, reset: true);
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.screen;
    if (s == AppScreen.login || s == AppScreen.signup) {
      return _formPage(s == AppScreen.signup);
    }
    final welcome = s == AppScreen.welcome;
    final intro = s == AppScreen.ticketIntro;
    final auth = s == AppScreen.auth;
    final tour = s.index >= AppScreen.onboardingBooking.index;
    return Scaffold(
      backgroundColor: welcome
          ? const Color(0xFF484848)
          : (intro || auth)
          ? const Color(0xFF999999)
          : CinemaColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: LayoutBuilder(
              builder: (context, box) => GestureDetector(
                onHorizontalDragEnd: (d) {
                  if ((d.primaryVelocity ?? 0) < -30) _next();
                },
                child: Column(
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          if (tour)
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              bottom: box.maxHeight * .36,
                              child: Container(color: const Color(0xFF101015)),
                            ),
                          if (!tour)
                            Positioned(
                              top: 80,
                              left: 0,
                              right: 0,
                              child: Column(
                                children: [
                                  if (welcome) ...[
                                    const Text(
                                      'WELCOME TO',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                  const Brand(large: true),
                                ],
                              ),
                            ),
                          if (intro || tour)
                            Positioned(
                              bottom: tour ? 88 : 104,
                              left: 40,
                              right: 40,
                              child: Column(
                                children: [
                                  Text(
                                    s.title,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  const SizedBox(height: 28),
                                  Text(
                                    intro
                                        ? 'Book your next cinema experience with Anker Cinema.'
                                        : s == AppScreen.onboardingBooking
                                        ? 'Let’s book tickets on Anker Cinema’s app to receive special deals'
                                        : 'Anker Cinema app is great in design and incredibly simple to use',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  if (s != AppScreen.onboardingStart) ...[
                                    const SizedBox(height: 28),
                                    IconButton(
                                      tooltip: 'Next',
                                      onPressed: _next,
                                      icon: const Icon(
                                        Icons.east,
                                        color: CinemaColors.yellow,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          if (auth)
                            Positioned(
                              bottom: 30,
                              left: 0,
                              right: 0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Or login with',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  const SizedBox(width: 12),
                                  for (final provider in ['f', 'G+'])
                                    IconButton(
                                      onPressed: () => toast(
                                        context,
                                        'Use the demo email login below.',
                                      ),
                                      icon: Container(
                                        width: 30,
                                        height: 30,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                          ),
                                        ),
                                        child: Text(provider),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: auth
                          ? Column(
                              children: [
                                ActionButton(
                                  'Log In',
                                  onPressed: () => go(context, AppScreen.login),
                                ),
                                const SizedBox(height: 16),
                                ActionButton(
                                  'Sign in',
                                  onPressed: () =>
                                      go(context, AppScreen.signup),
                                  outlined: true,
                                ),
                              ],
                            )
                          : s == AppScreen.onboardingStart
                          ? ActionButton(
                              'Get Started',
                              onPressed: () =>
                                  go(context, AppScreen.movies, reset: true),
                            )
                          : InkWell(
                              onTap: _next,
                              child: SizedBox(
                                height: 52,
                                child: PaginationDots(
                                  welcome || intro
                                      ? 0
                                      : s.index -
                                            AppScreen.onboardingBooking.index,
                                  count: tour ? 3 : 4,
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    bool password = false,
    TextInputType? type,
  }) => TextFormField(
    controller: controller,
    obscureText: password && _obscure,
    style: const TextStyle(fontSize: 16),
    keyboardType: type,
    textInputAction: TextInputAction.next,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.white54),
      ),
      suffixIcon: password
          ? IconButton(
              tooltip: 'Show password',
              onPressed: () => setState(() => _obscure = !_obscure),
              icon: Icon(
                _obscure
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 20,
              ),
            )
          : null,
    ),
    validator: (value) {
      if (value == null || value.trim().isEmpty) return 'Enter $label';
      if (type == TextInputType.emailAddress &&
          !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value.trim())) {
        return 'Enter a valid email';
      }
      if (password && value.length < 6) return 'Use at least 6 characters';
      return null;
    },
  );
  Widget _formPage(bool signup) => Scaffold(
    backgroundColor: signup ? const Color(0xFF999999) : const Color(0xFF0A091A),
    body: SafeArea(
      child: Form(
        key: _form,
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - 32,
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!signup)
                      Container(
                        height: 185,
                        color: const Color(0xFF999999),
                        child: const Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: PaginationDots(0, count: 3),
                          ),
                        ),
                      ),
                    SizedBox(height: signup ? 40 : 32),
                    Text(
                      signup ? 'SIGN UP' : 'LOG IN',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 28),
                    ),
                    const SizedBox(height: 32),
                    if (signup) _field('Username', _name),
                    _field('Email', _email, type: TextInputType.emailAddress),
                    if (signup) ...[
                      _field('Phone', _phone, type: TextInputType.phone),
                      TextFormField(
                        controller: _dob,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Date of birth',
                          labelStyle: TextStyle(color: Colors.white70),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white54),
                          ),
                        ),
                        validator: (v) => v == null || v.isEmpty
                            ? 'Choose date of birth'
                            : null,
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime(1995, 1, 1),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            _dob.text =
                                '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                          }
                        },
                      ),
                    ],
                    _field('Password', _password, password: true),
                    if (!signup)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => toast(
                            context,
                            'Demo account: enter any valid email and a 6-character password.',
                          ),
                          child: const Text(
                            'Forgot password?',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ),
                    const Spacer(),
                    const SizedBox(height: 36),
                    ActionButton(
                      signup ? 'Create Now' : 'Log In',
                      onPressed: _submit,
                    ),
                    const SizedBox(height: 16),
                    if (signup)
                      const Text(
                        'By clicking Create Now, you agree with our Privacy Terms',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12),
                      )
                    else
                      ActionButton(
                        'Sign in',
                        outlined: true,
                        onPressed: () => go(context, AppScreen.signup),
                      ),
                    if (signup)
                      TextButton(
                        onPressed: () => go(context, AppScreen.login),
                        child: const Text(
                          'Already have an account?  Log In',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
