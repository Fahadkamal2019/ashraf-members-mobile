import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_exception.dart';
import '../../core/providers.dart';
import '../../models/member_summary.dart';

class LoginResult {
  LoginResult({required this.accessToken, required this.member});

  final String accessToken;
  final MemberSummary member;
}

/// Talks to the unauthenticated /api/auth/* endpoints. Uses a plain Dio (not the shared
/// dioProvider's instance) is unnecessary here - the shared client's Authorization interceptor is
/// a no-op when there's no stored token yet, so it's safe to reuse for verify/set-password/login.
class AuthService {
  AuthService(this._dio);

  final Dio _dio;

  Future<String> verify({required int memberId, required String nationalId, required String mobile}) async {
    try {
      final response = await _dio.post('/api/auth/verify', data: {
        'memberId': memberId,
        'nationalId': nationalId,
        'mobile': mobile,
      });
      return response.data['setPasswordToken'] as String;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> setPassword({required String token, required String password, required String confirmPassword}) async {
    try {
      await _dio.post('/api/auth/set-password', data: {
        'token': token,
        'password': password,
        'confirmPassword': confirmPassword,
      });
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<LoginResult> login({required int memberId, required String password}) async {
    try {
      final response = await _dio.post('/api/auth/login', data: {
        'memberId': memberId,
        'password': password,
      });
      final data = response.data as Map<String, dynamic>;
      return LoginResult(
        accessToken: data['accessToken'] as String,
        member: MemberSummary.fromJson(data['member'] as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}

final authServiceProvider = Provider<AuthService>((ref) => AuthService(ref.watch(dioProvider)));
