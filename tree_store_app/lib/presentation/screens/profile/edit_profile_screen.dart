import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../blocs/profile_bloc.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _emailCtrl;
  bool _initialized = false;

  @override
  void dispose() {
    if (_initialized) {
      _nameCtrl.dispose();
      _phoneCtrl.dispose();
      _emailCtrl.dispose();
    }
    super.dispose();
  }

  void _initControllers(String name, String phone, String email) {
    if (!_initialized) {
      _nameCtrl = TextEditingController(text: name);
      _phoneCtrl = TextEditingController(text: phone);
      _emailCtrl = TextEditingController(text: email);
      _initialized = true;
    }
  }

  Future<void> _onSave() async {
    debugPrint('[DEBUG] EditProfile save tapped');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận'),
        content: const Text('Bạn có chắc muốn lưu thay đổi?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Lưu', style: TextStyle(color: AppColors.green700))),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    debugPrint('[DEBUG] EditProfile confirmed, dispatching ProfileUpdate');
    context.read<ProfileBloc>().add(ProfileUpdate(
      fullName: _nameCtrl.text.trim(),
      phoneNumber: _phoneCtrl.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thông tin cá nhân'), actions: [
        TextButton(onPressed: _onSave, child: const Text('Lưu', style: TextStyle(color: AppColors.green700, fontWeight: FontWeight.w700))),
      ]),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileUpdated) {
            debugPrint('[DEBUG] EditProfile update success');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Cập nhật thành công', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                backgroundColor: AppColors.green700,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.all(16),
                duration: const Duration(seconds: 2),
              ),
            );
            context.pop();
          } else if (state is ProfileError) {
            debugPrint('[DEBUG] EditProfile update error: ${state.message}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                backgroundColor: AppColors.terra,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.all(16),
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading || state is ProfileUpdating) {
            return const Center(child: CircularProgressIndicator());
          }
          final user = state is ProfileLoaded ? state.user : (state is ProfileUpdated ? state.user : null);
          if (user == null) {
            return const Center(child: Text('Không tải được thông tin'));
          }
          _initControllers(user.fullName, user.phoneNumber ?? '', user.email ?? '');
          // ponytail: gender, birthday, notification toggles not in backend User entity yet. upgrade when backend supports them
          final initials = user.fullName.isNotEmpty ? user.fullName.split(' ').map((e) => e.isNotEmpty ? e[0] : '').join().toUpperCase() : '?';
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Center(child: Stack(children: [
                Container(width: 88, height: 88, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.green100), child: Center(child: Text(initials.length > 2 ? initials.substring(0, 2) : initials, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.green700)))),
                Positioned(bottom: 0, right: 0, child: Container(width: 28, height: 28, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white, border: Border.all(color: AppColors.line)), child: const Icon(Icons.edit, size: 14, color: AppColors.green700))),
              ])),
              const SizedBox(height: 8),
              const Center(child: Text('Đổi ảnh đại diện', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.green700))),
              const SizedBox(height: 24),
              _editableField('Họ và tên', _nameCtrl),
              _readOnlyField('Email', _emailCtrl),
              _editableField('Số điện thoại', _phoneCtrl, keyboardType: TextInputType.phone),
            ],
          );
        },
      ),
    );
  }

  Widget _editableField(String label, TextEditingController ctrl, {TextInputType? keyboardType}) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppColors.green50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      ),
    ),
  );

  Widget _readOnlyField(String label, TextEditingController ctrl) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      controller: ctrl,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      ),
    ),
  );
}