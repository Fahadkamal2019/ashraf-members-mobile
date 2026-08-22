import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api_exception.dart';
import 'auth_service.dart';

class VerifyScreen extends ConsumerStatefulWidget {
  const VerifyScreen({super.key});

  @override
  ConsumerState<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends ConsumerState<VerifyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _memberIdController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _mobileController = TextEditingController();

  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _memberIdController.dispose();
    _nationalIdController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final token = await ref.read(authServiceProvider).verify(
            memberId: int.parse(_memberIdController.text.trim()),
            nationalId: _nationalIdController.text.trim(),
            mobile: _mobileController.text.trim(),
          );
      if (!mounted) return;
      context.go('/set-password', extra: token);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('التحقق من الهوية')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset('assets/images/logo.png', height: 96),
                const SizedBox(height: 16),
                const Text(
                  'أول مرة تدخل بوابة الأعضاء؟ أدخل بياناتك للتحقق من هويتك',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                if (_error != null) ...[
                  Text(_error!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                ],
                TextFormField(
                  controller: _memberIdController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'رقم العضو'),
                  validator: (value) =>
                      (value == null || int.tryParse(value.trim()) == null) ? 'رقم العضو يجب أن يكون رقماً' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nationalIdController,
                  decoration: const InputDecoration(labelText: 'الرقم القومي'),
                  validator: (value) => (value == null || value.trim().isEmpty) ? 'مطلوب' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _mobileController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'رقم الموبايل'),
                  validator: (value) => (value == null || value.trim().isEmpty) ? 'مطلوب' : null,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('تحقق من الهوية'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('لديك كلمة مرور بالفعل؟ سجل الدخول'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
