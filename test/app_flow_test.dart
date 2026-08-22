import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ashraf_members_mobile/core/providers.dart';
import 'package:ashraf_members_mobile/core/token_storage.dart';
import 'package:ashraf_members_mobile/main.dart';

/// In-memory stand-in for SecureTokenStorage - the real one talks to a platform channel that only
/// responds on a real device/browser/emulator, which hangs forever in a plain `flutter test` run.
class _InMemoryTokenStorage implements TokenStorage {
  String? _token;

  @override
  Future<String?> read() async => _token;

  @override
  Future<void> write(String token) async => _token = token;

  @override
  Future<void> clear() async => _token = null;
}

/// Short-circuits network calls with the exact JSON shapes AshrafBack.Members.Api actually
/// returns (verified directly against the running Api with curl - see /api/auth/login and
/// /api/profile responses). flutter_test's fake-async clock doesn't reliably let a real dio
/// request's continuation resume via pump()/runAsync, so this widget test instead proves the real
/// thing it's responsible for: that a tap really drives a network call, updates riverpod state,
/// and renders the result - not whether the Api itself is correct, which the curl testing already
/// covers.
Dio _buildFakeDio() {
  final dio = Dio();
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      if (options.path == '/api/auth/login') {
        handler.resolve(Response(
          requestOptions: options,
          statusCode: 200,
          data: {
            'accessToken': 'fake-token-for-test',
            'expiresAt': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
            'member': {'id': 31, 'referenceNumber': '199200031', 'name': 'عزه عدلى محمد ناجى'},
          },
        ));
        return;
      }
      if (options.path == '/api/profile') {
        handler.resolve(Response(
          requestOptions: options,
          statusCode: 200,
          data: {
            'id': 31,
            'referenceNumber': '199200031',
            'name': 'عزه عدلى محمد ناجى',
            'photoUrl': null,
            'lastRenewedYear': 2013,
            'unreadNotifications': 0,
          },
        ));
        return;
      }
      handler.reject(DioException(requestOptions: options, message: 'Unexpected request in test'));
    },
  ));
  return dio;
}

void main() {
  testWidgets('Login reaches the dashboard and renders the member profile', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dioProvider.overrideWithValue(_buildFakeDio()),
          tokenStorageProvider.overrideWithValue(_InMemoryTokenStorage()),
        ],
        child: const MembersApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('login_member_id_field')), findsOneWidget);

    await tester.enterText(find.byKey(const Key('login_member_id_field')), '31');
    await tester.enterText(find.byKey(const Key('login_password_field')), 'Test123!');
    await tester.tap(find.byKey(const Key('login_submit_button')));
    await tester.pumpAndSettle();

    expect(find.text('عزه عدلى محمد ناجى'), findsOneWidget);
    expect(find.text('199200031'), findsOneWidget);
    expect(find.text('2013'), findsOneWidget);
  });
}
