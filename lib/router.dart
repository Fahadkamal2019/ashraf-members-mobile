import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/providers.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/set_password_screen.dart';
import 'features/auth/verify_screen.dart';
import 'features/home/home_screen.dart';
import 'features/news/news_detail_screen.dart';

const _publicRoutes = ['/login', '/verify', '/set-password'];

/// Bridges authTokenProvider's changes into a Listenable go_router can watch, so a login/logout
/// re-runs the redirect guard below without rebuilding the whole router (which would lose
/// navigation state).
class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(Ref ref) {
    ref.listen(authTokenProvider, (previous, next) => notifyListeners());
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _AuthRefreshNotifier(ref);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final isAuthenticated = ref.read(authTokenProvider) != null;
      final isPublicRoute = _publicRoutes.contains(state.matchedLocation);

      if (!isAuthenticated && !isPublicRoute) {
        return '/login';
      }
      if (isAuthenticated && isPublicRoute) {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/verify', builder: (context, state) => const VerifyScreen()),
      GoRoute(
        path: '/set-password',
        builder: (context, state) => SetPasswordScreen(token: state.extra as String? ?? ''),
      ),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/news/:id',
        builder: (context, state) => NewsDetailScreen(newsId: int.parse(state.pathParameters['id']!)),
      ),
    ],
  );
});
