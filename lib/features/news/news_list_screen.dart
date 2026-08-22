import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'news_service.dart';

class NewsListScreen extends ConsumerWidget {
  const NewsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newsAsync = ref.watch(newsListProvider);

    return RefreshIndicator(
      onRefresh: () => ref.refresh(newsListProvider.future),
      child: newsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ListView(children: [const SizedBox(height: 80), Center(child: Text('$error'))]),
        data: (news) {
          if (news.isEmpty) {
            return ListView(children: const [SizedBox(height: 80), Center(child: Text('لا توجد أخبار حالياً'))]);
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: news.length,
            itemBuilder: (context, index) {
              final item = news[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => context.push('/news/${item.id}'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (item.imageUrl != null)
                        CachedNetworkImage(
                          imageUrl: item.imageUrl!,
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => const SizedBox(height: 160),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.titleAr ?? '', style: Theme.of(context).textTheme.titleMedium),
                            if (item.prefAr != null) ...[
                              const SizedBox(height: 4),
                              Text(item.prefAr!, maxLines: 2, overflow: TextOverflow.ellipsis),
                            ],
                            const SizedBox(height: 6),
                            Text(
                              DateFormat('yyyy/MM/dd').format(item.createdAt.toLocal()),
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
