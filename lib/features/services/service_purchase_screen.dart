import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/api_exception.dart';
import '../../core/app_theme.dart';
import '../../models/service_catalog_item.dart';
import 'services_service.dart';

class ServicePurchaseScreen extends ConsumerStatefulWidget {
  const ServicePurchaseScreen({super.key, required this.item});

  final ServiceCatalogItem item;

  @override
  ConsumerState<ServicePurchaseScreen> createState() => _ServicePurchaseScreenState();
}

class _ServicePurchaseScreenState extends ConsumerState<ServicePurchaseScreen> with WidgetsBindingObserver {
  String _deliveryMethod = 'pickup';
  String _paymentMethod = 'card';
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
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
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

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
      final status = await ref.read(servicesServiceProvider).getStatus(transactionId);
      if (!mounted) return;
      if (status.isPaid) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('تم الدفع بنجاح، تم استلام طلبك'), backgroundColor: AppColors.green));
      } else if (status.isFailed) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('لم تكتمل عملية الدفع'), backgroundColor: Colors.red));
      }
    } catch (_) {
      // Silently ignore - the member can just check with staff / retry.
    }
  }

  Future<void> _pay() async {
    if (_deliveryMethod == 'mail' && _addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('العنوان مطلوب عند اختيار الإرسال بالبريد')));
      return;
    }

    setState(() => _isPaying = true);
    try {
      final checkout = await ref.read(servicesServiceProvider).createCheckout(
            paymentTypeId: widget.item.paymentTypeId,
            deliveryMethod: _deliveryMethod,
            deliveryAddress: _deliveryMethod == 'mail' ? _addressController.text.trim() : null,
            notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
            paymentMethod: _paymentMethod,
          );
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
    return Scaffold(
      appBar: AppBar(title: Text(widget.item.nameAr)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            color: AppColors.greenLight,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(widget.item.nameAr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('${widget.item.price.toStringAsFixed(0)} جنيه',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('طريقة الاستلام', style: TextStyle(fontWeight: FontWeight.bold)),
          RadioListTile<String>(
            title: const Text('استلام من المقر'),
            value: 'pickup',
            groupValue: _deliveryMethod,
            onChanged: (v) => setState(() => _deliveryMethod = v!),
          ),
          RadioListTile<String>(
            title: const Text('إرسال بالبريد'),
            value: 'mail',
            groupValue: _deliveryMethod,
            onChanged: (v) => setState(() => _deliveryMethod = v!),
          ),
          if (_deliveryMethod == 'mail') ...[
            const SizedBox(height: 8),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'العنوان', hintText: 'اكتب عنوان الإرسال بالتفصيل'),
              minLines: 2,
              maxLines: 3,
            ),
          ],
          const SizedBox(height: 16),
          TextField(
            controller: _notesController,
            decoration: const InputDecoration(labelText: 'ملاحظات (اختياري)'),
            minLines: 1,
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          const Text('طريقة الدفع', style: TextStyle(fontWeight: FontWeight.bold)),
          RadioListTile<String>(
            title: const Text('بطاقة ائتمان / خصم'),
            value: 'card',
            groupValue: _paymentMethod,
            onChanged: (v) => setState(() => _paymentMethod = v!),
          ),
          RadioListTile<String>(
            title: const Text('رقم مرجعي فوري (ادفع لاحقاً في أي منفذ)'),
            value: 'fawry_refno',
            groupValue: _paymentMethod,
            onChanged: (v) => setState(() => _paymentMethod = v!),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _isPaying ? null : _pay,
            child: _isPaying
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('ادفع الآن'),
          ),
        ],
      ),
    );
  }
}
