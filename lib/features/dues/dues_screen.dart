import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/api_exception.dart';
import '../../core/app_theme.dart';
import '../../models/dues_summary.dart';
import 'dues_service.dart';

class DuesScreen extends ConsumerStatefulWidget {
  const DuesScreen({super.key});

  @override
  ConsumerState<DuesScreen> createState() => _DuesScreenState();
}

class _DuesScreenState extends ConsumerState<DuesScreen> with WidgetsBindingObserver {
  int _years = 1;
  bool _isPaying = false;
  int? _pendingTransactionId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // When the member returns to the app after finishing (or abandoning) the checkout page in the
  // external browser, check whether the order actually went through.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _pendingTransactionId != null) {
      final id = _pendingTransactionId!;
      _pendingTransactionId = null;
      _checkStatus(id);
    }
  }

  Future<void> _checkStatus(int transactionId) async {
    try {
      final status = await ref.read(duesServiceProvider).getStatus(transactionId);
      if (!mounted) return;
      if (status.isPaid) {
        ref.invalidate(duesSummaryProvider);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('تم الدفع بنجاح، تم تجديد اشتراكك'), backgroundColor: AppColors.green));
      } else if (status.isFailed) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('لم تكتمل عملية الدفع'), backgroundColor: Colors.red));
      }
    } catch (_) {
      // Silently ignore - the member can just check their profile / retry.
    }
  }

  Future<void> _pay(DuesSummary summary) async {
    setState(() => _isPaying = true);
    try {
      final checkout = await ref.read(duesServiceProvider).createCheckout(_years);
      _pendingTransactionId = checkout.transactionId;
      final uri = Uri.parse(checkout.checkoutUrl);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _isPaying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final summaryAsync = ref.watch(duesSummaryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('تجديد الاشتراك')),
      body: summaryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
        data: (summary) {
          final total = (summary.perYearFee * _years) + summary.renewalCardFee + summary.electronicServicesFee;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _row('آخر تجديد', summary.lastRenewedYear?.toString() ?? 'لا يوجد'),
                      _row('السنة الحالية', summary.currentYear.toString()),
                      if (summary.yearsOwed > 0) _row('عدد السنوات المستحقة', summary.yearsOwed.toString()),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text('عدد سنوات التجديد', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton(
                    onPressed: _years > 1 ? () => setState(() => _years--) : null,
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Text('$_years', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(
                    onPressed: _years < 40 ? () => setState(() => _years++) : null,
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Card(
                color: AppColors.greenLight,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _row('رسوم التجديد (${summary.perYearFee.toStringAsFixed(0)} × $_years)',
                          (summary.perYearFee * _years).toStringAsFixed(0)),
                      _row('رسوم بطاقة العضوية', summary.renewalCardFee.toStringAsFixed(0)),
                      _row('رسوم الخدمات الإلكترونية', summary.electronicServicesFee.toStringAsFixed(0)),
                      const Divider(),
                      _row('الإجمالي', '${total.toStringAsFixed(0)} جنيه', bold: true),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isPaying ? null : () => _pay(summary),
                child: _isPaying
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('ادفع الآن'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(color: bold ? Colors.black : Colors.grey, fontWeight: bold ? FontWeight.bold : null)),
            Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: bold ? 18 : 14)),
          ],
        ),
      );
}
