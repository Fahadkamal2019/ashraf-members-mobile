import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_exception.dart';
import '../../core/providers.dart';
import '../../models/profile.dart';

class ProfileService {
  ProfileService(this._dio);

  final Dio _dio;

  Future<Profile> getProfile() async {
    try {
      final response = await _dio.get('/api/profile');
      return Profile.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}

final profileServiceProvider = Provider<ProfileService>((ref) => ProfileService(ref.watch(dioProvider)));

final profileProvider = FutureProvider.autoDispose<Profile>((ref) {
  return ref.watch(profileServiceProvider).getProfile();
});
