import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/primary_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _email = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop())),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 72, height: 72, decoration: BoxDecoration(color: AppColors.green50, borderRadius: BorderRadius.circular(20)),
              child: const Icon(Icons.lock_reset, size: 36, color: AppColors.green700),
            ),
            const SizedBox(height: 20),
            const Text('Quên mật khẩu', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.ink)),
            const SizedBox(height: 4),
            const Text('Nhập email để nhận mã xác thực đặt lại mật khẩu', style: TextStyle(fontSize: 14, color: AppColors.muted)),
            const SizedBox(height: 24),
            TextField(
              controller: _email, keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'Email', prefixIcon: const Icon(Icons.email_outlined, color: AppColors.green700),
                fillColor: AppColors.green50, filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Gửi mã xác thực',
              onPressed: () {
                if (_email.text.isNotEmpty) {
                  context.push('/otp?email=${Uri.encodeComponent(_email.text)}&purpose=forgot_password');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
