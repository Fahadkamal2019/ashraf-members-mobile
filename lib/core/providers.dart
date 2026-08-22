import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'api_config.dart';
import 'token_storage.dart';

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return SecureTokenStorage(const FlutterSecureStorage());
});

/// Fires whenever the stored token changes (set on login, cleared on logout or a 401), so
/// go_router's redirect logic can react without the UI polling storage itself.
class AuthTokenNotifier extends StateNotifier<String?> {
  AuthTokenNotifier(this._storage) : super(null) {
    _restore();
  }

  final TokenStorage _storage;

  Future<void> _restore() async {
    state = await _storage.read();
  }

  Future<void> setToken(String token) async {
    await _storage.write(token);
    state = token;
  }

  Future<void> clear() async {
    await _storage.clear();
    state = null;
  }
}

final authTokenProvider = StateNotifierProvider<AuthTokenNotifier, String?>((ref) {
  return AuthTokenNotifier(ref.watch(tokenStorageProvider));
});

/// Exposed as its own provider (rather than called directly inside dioProvider) so tests can
/// override it with a fixed URL instead of relying on defaultApiBaseUrl()'s platform sniffing.
final apiBaseUrlProvider = Provider<String>((ref) => defaultApiBaseUrl());

/// Single Dio instance shared by every feature service. Attaches the bearer token to every
/// request and clears it automatically on a 401 (expired/invalid token) so the router's redirect
/// guard sends the member back to the login screen.
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(baseUrl: ref.watch(apiBaseUrlProvider)));

  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      final token = await ref.read(tokenStorageProvider).read();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      handler.next(options);
    },
    onError: (error, handler) {
      if (error.response?.statusCode == 401) {
        ref.read(authTokenProvider.notifier).clear();
      }
      handler.next(error);
    },
  ));

  return dio;
});
