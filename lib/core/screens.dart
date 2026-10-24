enum AppScreen {
  welcome('Welcome'),
  ticketIntro('Ticket'),
  auth('Anker Cinema'),
  login('Log In'),
  signup('Sign up'),
  onboardingBooking('Everything In Your Hand'),
  onboardingEasy('Easy To Use'),
  onboardingStart('Let’s Start With Us'),
  search('Search'),
  comingSoon('Coming Soon'),
  actor('PhuongAnhDao'),
  movies('Movies'),
  movieDetail('Movie Booking'),
  showtimes('Movie Booking'),
  seats('Movie Booking'),
  combos('Movie Booking'),
  ticket('Check out'),
  notifications('Notifications'),
  settings('Setting'),
  reviews('Reviews'),
  promo('Promote Code'),
  promoSuccess('Code Applied'),
  cinemas('Anker Cinema'),
  rewards('Rewards'),
  cinemaSearch('Search Cinema'),
  historyEmpty('History'),
  history('History'),
  location('Location'),
  payment('Payment'),
  menu('Menu'),
  trailer('Trailer'),
  paymentSuccess('Payment Success'),
  card('Payment'),
  verify('Verify'),
  verifyCode('Verify'),
  profile('Profile'),
  camera('Photo'),
  movieList('Now Showing'),
  discover('Discover'),
  checkout('Checkout Process');

  const AppScreen(this.title);
  final String title;
  int get number => index + 1;
  String get route => '/$name';
  static AppScreen fromNumber(int value) => values[value.clamp(1, 40) - 1];
}
