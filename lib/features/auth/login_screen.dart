import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api_exception.dart';
import '../../core/providers.dart';
import 'auth_service.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _memberIdController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _memberIdController.dispose();
    _passwordController.dispose();
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
      final result = await ref.read(authServiceProvider).login(
            memberId: int.parse(_memberIdController.text.trim()),
            password: _passwordController.text,
          );
      await ref.read(authTokenProvider.notifier).setToken(result.accessToken);
      if (!mounted) return;
      context.go('/home');
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('بوابة الأعضاء')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset('assets/images/logo.png', height: 96),
                const SizedBox(height: 24),
                if (_error != null) ...[
                  Text(_error!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                ],
                TextFormField(
                  key: const Key('login_member_id_field'),
                  controller: _memberIdController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'رقم العضو'),
                  validator: (value) =>
                      (value == null || int.tryParse(value.trim()) == null) ? 'أدخل رقم العضو' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  key: const Key('login_password_field'),
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'كلمة المرور'),
                  validator: (value) => (value == null || value.isEmpty) ? 'أدخل كلمة المرور' : null,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  key: const Key('login_submit_button'),
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('تسجيل الدخول'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => context.go('/verify'),
                  child: const Text('أول مرة تدخل البوابة؟ تحقق من هويتك'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
