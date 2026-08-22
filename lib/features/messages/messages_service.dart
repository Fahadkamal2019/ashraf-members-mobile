import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_exception.dart';
import '../../core/providers.dart';
import '../../models/message_item.dart';

class MessagesService {
  MessagesService(this._dio);

  final Dio _dio;

  Future<List<MessageItem>> getThread() async {
    try {
      final response = await _dio.get('/api/messages');
      return (response.data as List).map((e) => MessageItem.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<MessageItem> send(String body) async {
    try {
      final response = await _dio.post('/api/messages', data: {'body': body});
      return MessageItem.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}

final messagesServiceProvider = Provider<MessagesService>((ref) => MessagesService(ref.watch(dioProvider)));

final messagesThreadProvider = FutureProvider.autoDispose<List<MessageItem>>((ref) {
  return ref.watch(messagesServiceProvider).getThread();
});
