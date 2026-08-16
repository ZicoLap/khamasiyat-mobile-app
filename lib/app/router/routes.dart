/// Named route paths for authentication + customer shell.
abstract final class AppRoutes {
  static const splash = '/splash';
  static const login = '/login';
  static const register = '/register';
  static const registerVerify = '/register/verify';
  static const forgotPassword = '/forgot-password';
  static const resetPassword = '/reset-password';
  static const changePassword = '/change-password';

  static const home = '/home';
  static const search = '/search';
  static const bookings = '/bookings';
  static const profile = '/profile';

  static const stadiumDetailPath = '/stadiums/:stadiumId';
  static const pitchDetailPath = '/pitches/:pitchId';
  static const bookingReview = '/booking/review';
  static const bookingPaymentPath = '/bookings/:bookingId/payment';

  static String stadiumDetail(String stadiumId) => '/stadiums/$stadiumId';
  static String pitchDetail(String pitchId) => '/pitches/$pitchId';
  static String bookingPayment(String bookingId) =>
      '/bookings/$bookingId/payment';

  /// Alias used as go_router initial location.
  static const root = splash;

  static const unauthenticated = <String>{
    splash,
    login,
    register,
    registerVerify,
    forgotPassword,
    resetPassword,
  };

  static bool isUnauthenticatedRoute(String location) {
    final path = Uri.parse(location).path;
    return unauthenticated.contains(path);
  }

  static bool isAuthenticatedArea(String location) {
    final path = Uri.parse(location).path;
    return path == home ||
        path == search ||
        path == bookings ||
        path == profile ||
        path == changePassword ||
        path.startsWith('/stadiums/') ||
        path.startsWith('/pitches/') ||
        path.startsWith('/booking/') ||
        path.startsWith('/bookings/');
  }
}
