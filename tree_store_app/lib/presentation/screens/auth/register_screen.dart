import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../blocs/auth_bloc.dart';
import '../../widgets/primary_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _agreed = false;
  bool _obscure = true;
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _pass = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _pass.dispose();
    super.dispose();
  }

  void _onRegisterPressed() {
    debugPrint('[DEBUG] Register button pressed');
    final email = _email.text.trim();
    final password = _pass.text;
    final fullName = _name.text.trim();
    final phone = _phone.text.trim();

    if (fullName.isEmpty || email.isEmpty || password.isEmpty) {
      debugPrint('[DEBUG] Register validation failed: empty fields');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin'), backgroundColor: AppColors.terra),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận đăng ký'),
        content: Text('Đăng ký tài khoản với email $email?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              debugPrint('[DEBUG] Register confirmed, dispatching AuthRegister');
              context.read<AuthBloc>().add(AuthRegister(
                fullName: fullName,
                email: email,
                password: password,
                phoneNumber: phone.isNotEmpty ? phone : null,
              ));
            },
            child: const Text('Đồng ý', style: TextStyle(color: AppColors.green700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop())),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          debugPrint('[DEBUG] Register BlocConsumer state: ${state.runtimeType}');
          if (state is AuthAuthenticated) {
            debugPrint('[DEBUG] Register success, showing snackbar and navigating to login');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Đăng ký thành công! Vui lòng đăng nhập.'), backgroundColor: AppColors.green700),
            );
            context.go('/login');
          } else if (state is AuthError) {
            debugPrint('[DEBUG] Register error: ${state.message}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.terra),
            );
          }
        },
        builder: (context, state) {
          final loading = state is AuthLoading;
          return SingleChildScrollView(
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
                TextField(controller: _email, decoration: const InputDecoration(hintText: 'Email'), keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 12),
                TextField(controller: _phone, decoration: const InputDecoration(hintText: 'Số điện thoại'), keyboardType: TextInputType.phone),
                const SizedBox(height: 12),
                TextField(
                  controller: _pass,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    hintText: 'Mật khẩu',
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, color: AppColors.muted),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Checkbox(value: _agreed, onChanged: (v) => setState(() => _agreed = v ?? false), activeColor: AppColors.green700),
                    Expanded(child: Text.rich(TextSpan(text: 'Tôi đồng ý với ', style: const TextStyle(fontSize: 13, color: AppColors.ink2), children: const [TextSpan(text: 'Điều khoản dịch vụ', style: TextStyle(color: AppColors.green700, fontWeight: FontWeight.w600)), TextSpan(text: ' và '), TextSpan(text: 'Chính sách bảo mật', style: TextStyle(color: AppColors.green700, fontWeight: FontWeight.w600))]))),
                  ],
                ),
                const SizedBox(height: 16),
                loading
                    ? const Center(child: CircularProgressIndicator())
                    : PrimaryButton(label: 'Tạo tài khoản', onPressed: _agreed ? _onRegisterPressed : null),
                const SizedBox(height: 24),
                Center(
                  child: GestureDetector(onTap: () => context.pop(), child: const Text.rich(TextSpan(text: 'Đã có tài khoản? ', style: TextStyle(color: AppColors.muted), children: [TextSpan(text: 'Đăng nhập', style: TextStyle(color: AppColors.green700, fontWeight: FontWeight.w700))]))),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}