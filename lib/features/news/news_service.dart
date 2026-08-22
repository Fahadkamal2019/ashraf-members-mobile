import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_exception.dart';
import '../../core/providers.dart';
import '../../models/news_item.dart';

class NewsService {
  NewsService(this._dio);

  final Dio _dio;

  Future<List<NewsListItem>> getList() async {
    try {
      final response = await _dio.get('/api/news');
      return (response.data as List).map((e) => NewsListItem.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<NewsDetail> getDetail(int id) async {
    try {
      final response = await _dio.get('/api/news/$id');
      return NewsDetail.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}

final newsServiceProvider = Provider<NewsService>((ref) => NewsService(ref.watch(dioProvider)));

final newsListProvider = FutureProvider.autoDispose<List<NewsListItem>>((ref) {
  return ref.watch(newsServiceProvider).getList();
});

final newsDetailProvider = FutureProvider.autoDispose.family<NewsDetail, int>((ref, id) {
  return ref.watch(newsServiceProvider).getDetail(id);
});
