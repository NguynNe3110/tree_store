import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/primary_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _agreed = false;
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _pass = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop())),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tạo tài khoản mới', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.ink)),
            const SizedBox(height: 4),
            const Text('Bắt đầu sưu tầm cây yêu thích của bạn', style: TextStyle(fontSize: 14, color: AppColors.muted)),
            const SizedBox(height: 24),
            TextField(controller: _name, decoration: const InputDecoration(hintText: 'Họ và tên')),
            const SizedBox(height: 12),
            TextField(controller: _email, decoration: const InputDecoration(hintText: 'Email')),
            const SizedBox(height: 12),
            TextField(controller: _phone, decoration: const InputDecoration(hintText: 'Số điện thoại'), keyboardType: TextInputType.phone),
            const SizedBox(height: 12),
            TextField(controller: _pass, obscureText: true, decoration: const InputDecoration(hintText: 'Mật khẩu')),
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(value: _agreed, onChanged: (v) => setState(() => _agreed = v ?? false), activeColor: AppColors.green700),
                Expanded(child: Text.rich(TextSpan(text: 'Tôi đồng ý với ', style: const TextStyle(fontSize: 13, color: AppColors.ink2), children: const [TextSpan(text: 'Điều khoản dịch vụ', style: TextStyle(color: AppColors.green700, fontWeight: FontWeight.w600)), TextSpan(text: ' và '), TextSpan(text: 'Chính sách bảo mật', style: TextStyle(color: AppColors.green700, fontWeight: FontWeight.w600))]))),
              ],
            ),
            const SizedBox(height: 16),
            PrimaryButton(label: 'Tạo tài khoản', onPressed: _agreed ? () => context.go('/home') : null), // ponytail: no BLoC yet
            const SizedBox(height: 24),
            Center(
              child: GestureDetector(onTap: () => context.pop(), child: const Text.rich(TextSpan(text: 'Đã có tài khoản? ', style: TextStyle(color: AppColors.muted), children: [TextSpan(text: 'Đăng nhập', style: TextStyle(color: AppColors.green700, fontWeight: FontWeight.w700))]))),
            ),
          ],
        ),
      ),
    );
  }
}