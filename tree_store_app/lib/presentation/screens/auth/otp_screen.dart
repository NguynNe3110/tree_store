import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../blocs/otp_bloc.dart';
import '../../widgets/primary_button.dart';

class OtpScreen extends StatefulWidget {
  final String email;
  final String purpose;
  const OtpScreen({super.key, required this.email, required this.purpose});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    context.read<OtpBloc>().add(OtpSend(email: widget.email, purpose: widget.purpose));
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _code => _controllers.map((c) => c.text).join();

  void _onDigitChanged(int index, String value) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    if (_code.length == 6) {
      context.read<OtpBloc>().add(OtpVerify(email: widget.email, code: _code, purpose: widget.purpose));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop())),
      body: BlocConsumer<OtpBloc, OtpState>(
        listener: (context, state) {
          if (state is OtpVerified) {
            if (widget.purpose == 'register') {
              context.go('/home');
            } else {
              context.pop(true);
            }
          }
          if (state is OtpError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: AppColors.terra));
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 72, height: 72, decoration: BoxDecoration(color: AppColors.green50, borderRadius: BorderRadius.circular(20)),
                  child: const Icon(Icons.shield_outlined, size: 36, color: AppColors.green700),
                ),
                const SizedBox(height: 20),
                const Text('Xác thực email', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.ink)),
                const SizedBox(height: 4),
                Text('Chúng tôi đã gửi mã 6 chữ số đến\n${widget.email}', style: const TextStyle(fontSize: 14, color: AppColors.muted)),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(6, (i) {
                    return Container(
                      width: 48, height: 56, margin: const EdgeInsets.symmetric(horizontal: 5),
                      child: TextField(
                        controller: _controllers[i], focusNode: _focusNodes[i],
                        keyboardType: TextInputType.number, maxLength: 1, textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                        decoration: InputDecoration(
                          counterText: '', fillColor: AppColors.green50, filled: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                        ),
                        onChanged: (v) => _onDigitChanged(i, v),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),
                Center(
                  child: state is OtpSent && state.remainingSeconds > 0
                      ? Text('Gửi lại sau ${state.remainingSeconds}s', style: const TextStyle(fontSize: 13, color: AppColors.muted))
                      : GestureDetector(
                          onTap: () => context.read<OtpBloc>().add(OtpResend(email: widget.email, purpose: widget.purpose)),
                          child: const Text('Gửi lại mã', style: TextStyle(fontSize: 13, color: AppColors.green700, fontWeight: FontWeight.w600)),
                        ),
                ),
                const SizedBox(height: 24),
                if (state is OtpVerifying)
                  const Center(child: CircularProgressIndicator())
                else
                  PrimaryButton(
                    label: 'Xác nhận',
                    onPressed: _code.length == 6
                        ? () => context.read<OtpBloc>().add(OtpVerify(email: widget.email, code: _code, purpose: widget.purpose))
                        : null,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
