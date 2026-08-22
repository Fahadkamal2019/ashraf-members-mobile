import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/api_exception.dart';
import '../../core/app_theme.dart';
import 'messages_service.dart';

class MessagesScreen extends ConsumerStatefulWidget {
  const MessagesScreen({super.key});

  @override
  ConsumerState<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends ConsumerState<MessagesScreen> {
  final _bodyController = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final body = _bodyController.text.trim();
    if (body.isEmpty) return;

    setState(() => _isSending = true);
    try {
      await ref.read(messagesServiceProvider).send(body);
      _bodyController.clear();
      ref.invalidate(messagesThreadProvider);
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final threadAsync = ref.watch(messagesThreadProvider);

    return Column(
      children: [
        Expanded(
          child: threadAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text('$error')),
            data: (thread) {
              if (thread.isEmpty) {
                return const Center(child: Text('لا توجد رسائل بعد'));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: thread.length,
                itemBuilder: (context, index) {
                  final message = thread[index];
                  return Align(
                    alignment: message.isFromMember ? Alignment.centerLeft : Alignment.centerRight,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(12),
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                      decoration: BoxDecoration(
                        color: message.isFromMember ? AppColors.greenLight : AppColors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            message.body,
                            style: TextStyle(color: message.isFromMember ? Colors.black87 : Colors.white),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('yyyy/MM/dd HH:mm').format(message.createdAt.toLocal()),
                            style: TextStyle(
                              fontSize: 11,
                              color: message.isFromMember ? Colors.black54 : Colors.white70,
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
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _bodyController,
                    decoration: const InputDecoration(hintText: 'اكتب رسالتك هنا...'),
                    minLines: 1,
                    maxLines: 4,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _isSending ? null : _send,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
