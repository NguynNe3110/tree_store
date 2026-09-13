import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../blocs/auth_bloc.dart';
import '../../widgets/primary_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            context.go('/home');
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.terra),
            );
          }
        },
        builder: (context, state) {
          final loading = state is AuthLoading;
          return SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [AppColors.green700, AppColors.green600], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
                  ),
                  child: const Center(child: Text('🌱 Verdant', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white))),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Chào mừng trở lại', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.ink)),
                      const SizedBox(height: 4),
                      const Text('Đăng nhập để tiếp tục hành trình xanh', style: TextStyle(fontSize: 14, color: AppColors.muted)),
                      const SizedBox(height: 24),
                      TextField(controller: _email, decoration: const InputDecoration(prefixIcon: Icon(Icons.mail_outline, color: AppColors.muted), hintText: 'email@verdant.vn', hintStyle: TextStyle(color: Colors.black26))),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _pass,
                        obscureText: _obscure,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock_outline, color: AppColors.muted),
                          hintText: '••••••••',
                          hintStyle: const TextStyle(color: Colors.black26),
                          suffixIcon: IconButton(icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, color: AppColors.muted), onPressed: () => setState(() => _obscure = !_obscure)),
                        ),
                      ),
                      Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () { debugPrint('[DEBUG] Forgot password tapped'); context.push('/forgot-password'); }, child: const Text('Quên mật khẩu?', style: TextStyle(color: AppColors.green700, fontSize: 13)))),
                      const SizedBox(height: 8),
                      loading
                          ? const Center(child: CircularProgressIndicator())
                          : PrimaryButton(
                              label: 'Đăng nhập',
                              onPressed: () {
                                debugPrint('[DEBUG] Login button pressed, email: ${_email.text.trim()}');
                                context.read<AuthBloc>().add(AuthLogin(_email.text.trim(), _pass.text));
                              },
                            ),
                      const SizedBox(height: 16),
                      Row(children: [const Expanded(child: Divider()), const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('hoặc', style: TextStyle(color: AppColors.muted))), const Expanded(child: Divider())]),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.g_mobiledata, color: AppColors.ink), label: const Text('Google'))),
                          const SizedBox(width: 12),
                          Expanded(child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.facebook, color: Colors.blue), label: const Text('Facebook'))),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: GestureDetector(
                          onTap: () => context.push('/register'),
                          child: const Text.rich(TextSpan(text: 'Chưa có tài khoản? ', style: TextStyle(color: AppColors.muted), children: [TextSpan(text: 'Đăng ký ngay', style: TextStyle(color: AppColors.green700, fontWeight: FontWeight.w700))])),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}