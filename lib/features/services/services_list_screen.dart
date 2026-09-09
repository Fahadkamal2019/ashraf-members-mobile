import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'services_service.dart';

class ServicesListScreen extends ConsumerWidget {
  const ServicesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalogAsync = ref.watch(servicesCatalogProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('الخدمات')),
      body: catalogAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('لا توجد خدمات متاحة حالياً'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                child: ListTile(
                  title: Text(item.nameAr),
                  trailing: Text('${item.price.toStringAsFixed(0)} جنيه',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  onTap: () => context.push('/services/${item.paymentTypeId}', extra: item),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
