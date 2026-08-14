import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:khamasiyat_mobile_app/app/router/routes.dart';
import 'package:khamasiyat_mobile_app/app/shell/customer_shell.dart';
import 'package:khamasiyat_mobile_app/features/auth/domain/auth_state.dart';
import 'package:khamasiyat_mobile_app/features/auth/presentation/auth_controller.dart';
import 'package:khamasiyat_mobile_app/features/auth/presentation/change_password/change_password_screen.dart';
import 'package:khamasiyat_mobile_app/features/auth/presentation/forgot_password/forgot_password_screen.dart';
import 'package:khamasiyat_mobile_app/features/auth/presentation/forgot_password/reset_password_screen.dart';
import 'package:khamasiyat_mobile_app/features/auth/presentation/login/login_screen.dart';
import 'package:khamasiyat_mobile_app/features/auth/presentation/register/register_screen.dart';
import 'package:khamasiyat_mobile_app/features/auth/presentation/register/register_verify_screen.dart';
import 'package:khamasiyat_mobile_app/features/auth/presentation/session_splash_screen.dart';
import 'package:khamasiyat_mobile_app/features/bookings/presentation/bookings_placeholder_screen.dart';
import 'package:khamasiyat_mobile_app/features/catalog/presentation/pitch_detail_placeholder_screen.dart';
import 'package:khamasiyat_mobile_app/features/catalog/presentation/search_screen.dart';
import 'package:khamasiyat_mobile_app/features/catalog/presentation/stadium_detail_screen.dart';
import 'package:khamasiyat_mobile_app/features/home/presentation/home_screen.dart';
import 'package:khamasiyat_mobile_app/features/profile/presentation/profile_placeholder_screen.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

class GoRouterAuthRefresh extends ChangeNotifier {
  GoRouterAuthRefresh(Ref ref) {
    _subscription = ref.listen<AuthState>(authControllerProvider, (_, __) {
      notifyListeners();
    });
  }

  late final ProviderSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.close();
    super.dispose();
  }
}

final goRouterProvider = Provider<GoRouter>((ref) {
  final refresh = GoRouterAuthRefresh(ref);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: kDebugMode,
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      final location = state.matchedLocation;
      final loggingIn = AppRoutes.isUnauthenticatedRoute(location);

      if (auth is AuthInitializing || auth is AuthRefreshing) {
        return location == AppRoutes.splash ? null : AppRoutes.splash;
      }

      if (auth is AuthUnauthenticated) {
        if (location == AppRoutes.splash) {
          return AppRoutes.login;
        }
        if (AppRoutes.isAuthenticatedArea(location)) {
          return AppRoutes.login;
        }
        return null;
      }

      if (auth is AuthAuthenticated) {
        final mustChange = auth.user.mustChangePassword;
        if (mustChange && location != AppRoutes.changePassword) {
          return AppRoutes.changePassword;
        }
        if (loggingIn || location == AppRoutes.splash) {
          return mustChange ? AppRoutes.changePassword : AppRoutes.home;
        }
        return null;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SessionSplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.registerVerify,
        name: 'registerVerify',
        builder: (context, state) {
          final email = state.extra as String? ?? '';
          return RegisterVerifyScreen(email: email);
        },
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: 'forgotPassword',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        name: 'resetPassword',
        builder: (context, state) {
          final email = state.extra as String? ?? '';
          return ResetPasswordScreen(email: email);
        },
      ),
      GoRoute(
        path: AppRoutes.changePassword,
        name: 'changePassword',
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.stadiumDetailPath,
        name: 'stadiumDetail',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['stadiumId'] ?? '';
          return StadiumDetailScreen(stadiumId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.pitchDetailPath,
        name: 'pitchDetail',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['pitchId'] ?? '';
          return PitchDetailPlaceholderScreen(pitchId: id);
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return CustomerShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                name: 'home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.search,
                name: 'search',
                builder: (context, state) => const SearchScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.bookings,
                name: 'bookings',
                builder: (context, state) => const BookingsPlaceholderScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                name: 'profile',
                builder: (context, state) => const ProfilePlaceholderScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
