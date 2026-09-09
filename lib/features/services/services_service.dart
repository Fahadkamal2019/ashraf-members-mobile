import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_exception.dart';
import '../../core/providers.dart';
import '../../models/checkout_result.dart';
import '../../models/service_catalog_item.dart';

class ServicesService {
  ServicesService(this._dio);

  final Dio _dio;

  Future<List<ServiceCatalogItem>> getCatalog() async {
    try {
      final response = await _dio.get('/api/services/catalog');
      return (response.data as List)
          .map((e) => ServiceCatalogItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<CheckoutResult> createCheckout({
    required int paymentTypeId,
    required String deliveryMethod,
    String? deliveryAddress,
    String? notes,
    required String paymentMethod,
  }) async {
    try {
      final response = await _dio.post('/api/services/checkout', data: {
        'paymentTypeId': paymentTypeId,
        'deliveryMethod': deliveryMethod,
        'deliveryAddress': deliveryAddress,
        'notes': notes,
        'paymentMethod': paymentMethod,
      });
      return CheckoutResult.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<OrderStatus> getStatus(int transactionId) async {
    try {
      final response = await _dio.get('/api/services/status/$transactionId');
      return OrderStatus.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}

final servicesServiceProvider = Provider<ServicesService>((ref) => ServicesService(ref.watch(dioProvider)));

final servicesCatalogProvider = FutureProvider.autoDispose<List<ServiceCatalogItem>>((ref) {
  return ref.watch(servicesServiceProvider).getCatalog();
});
