import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../home/profile_service.dart';
import 'notifications_service.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return RefreshIndicator(
      onRefresh: () => ref.refresh(notificationsProvider.future),
      child: notificationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => ListView(children: [const SizedBox(height: 80), Center(child: Text('$error'))]),
        data: (notifications) {
          if (notifications.isEmpty) {
            return ListView(children: const [SizedBox(height: 80), Center(child: Text('لا توجد إشعارات'))]);
          }
          return ListView.separated(
            itemCount: notifications.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return ListTile(
                leading: Icon(
                  notification.isRead ? Icons.notifications_none : Icons.notifications_active,
                  color: notification.isRead ? Colors.grey : Theme.of(context).colorScheme.primary,
                ),
                title: Text(
                  notification.title,
                  style: TextStyle(fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold),
                ),
                subtitle: Text(notification.body),
                trailing: Text(
                  DateFormat('yyyy/MM/dd').format(notification.createdAt.toLocal()),
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                onTap: notification.isRead
                    ? null
                    : () async {
                        await ref.read(notificationsServiceProvider).markRead(notification.id);
                        ref.invalidate(notificationsProvider);
                        ref.invalidate(profileProvider);
                      },
              );
            },
          );
        },
      ),
    );
  }
}
