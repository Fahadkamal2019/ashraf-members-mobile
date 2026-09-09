import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_exception.dart';
import '../../core/providers.dart';
import '../../models/checkout_result.dart';
import '../../models/dues_summary.dart';

class DuesService {
  DuesService(this._dio);

  final Dio _dio;

  Future<DuesSummary> getSummary() async {
    try {
      final response = await _dio.get('/api/dues/summary');
      return DuesSummary.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<CheckoutResult> createCheckout(int yearsToRenew) async {
    try {
      final response = await _dio.post('/api/dues/checkout', data: {'yearsToRenew': yearsToRenew});
      return CheckoutResult.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<OrderStatus> getStatus(int transactionId) async {
    try {
      final response = await _dio.get('/api/dues/status/$transactionId');
      return OrderStatus.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}

final duesServiceProvider = Provider<DuesService>((ref) => DuesService(ref.watch(dioProvider)));

final duesSummaryProvider = FutureProvider.autoDispose<DuesSummary>((ref) {
  return ref.watch(duesServiceProvider).getSummary();
});
