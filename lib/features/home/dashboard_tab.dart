import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/app_theme.dart';
import 'profile_service.dart';

class DashboardTab extends ConsumerWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);

    return RefreshIndicator(
      onRefresh: () => ref.refresh(profileProvider.future),
      child: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ListView(
          children: [
            const SizedBox(height: 80),
            Center(child: Text('$error')),
          ],
        ),
        data: (profile) => ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Center(
              child: CircleAvatar(
                radius: 56,
                backgroundColor: AppColors.greenLight,
                backgroundImage: profile.photoUrl != null ? CachedNetworkImageProvider(profile.photoUrl!) : null,
                child: profile.photoUrl == null ? const Icon(Icons.person, size: 56, color: AppColors.green) : null,
              ),
            ),
            const SizedBox(height: 16),
            Text(profile.name, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _InfoRow(label: 'رقم العضو', value: profile.id.toString()),
                    _InfoRow(label: 'رقم العضوية', value: profile.referenceNumber ?? '-'),
                    _InfoRow(
                      label: 'بداية العضوية',
                      value: profile.membershipStartDate != null
                          ? DateFormat('yyyy/MM/dd').format(profile.membershipStartDate!)
                          : 'لا يوجد',
                    ),
                    _InfoRow(
                      label: 'مجدد الى',
                      value: profile.lastRenewedYear?.toString() ?? 'لا يوجد',
                    ),
                    if (profile.unreadNotifications > 0)
                      _InfoRow(label: 'إشعارات غير مقروءة', value: profile.unreadNotifications.toString()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
