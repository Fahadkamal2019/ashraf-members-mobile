import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_exception.dart';
import '../../core/providers.dart';
import '../../models/notification_item.dart';

class NotificationsService {
  NotificationsService(this._dio);

  final Dio _dio;

  Future<List<NotificationItem>> getAll() async {
    try {
      final response = await _dio.get('/api/notifications');
      return (response.data as List).map((e) => NotificationItem.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> markRead(int id) async {
    try {
      await _dio.post('/api/notifications/$id/read');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}

final notificationsServiceProvider =
    Provider<NotificationsService>((ref) => NotificationsService(ref.watch(dioProvider)));

final notificationsProvider = FutureProvider.autoDispose<List<NotificationItem>>((ref) {
  return ref.watch(notificationsServiceProvider).getAll();
});
