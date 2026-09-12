import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/di/injection.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/usecases/profile/add_address_usecase.dart';
import '../../widgets/primary_button.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key});
  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _districtCtrl = TextEditingController();
  final _wardCtrl = TextEditingController();
  final _addrCtrl = TextEditingController();
  String _type = 'Nhà';
  bool _isDefault = false;
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _cityCtrl.dispose();
    _districtCtrl.dispose();
    _wardCtrl.dispose();
    _addrCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty ||
        _phoneCtrl.text.trim().isEmpty ||
        _cityCtrl.text.trim().isEmpty ||
        _districtCtrl.text.trim().isEmpty ||
        _addrCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin'), backgroundColor: AppColors.terra));
      return;
    }
    setState(() => _saving = true);
    final result = await sl<AddAddressUsecase>()(
      label: _type,
      receiverName: _nameCtrl.text.trim(),
      phoneNumber: _phoneCtrl.text.trim(),
      addressLine: _addrCtrl.text.trim(),
      city: _cityCtrl.text.trim(),
      district: _districtCtrl.text.trim(),
      ward: _wardCtrl.text.trim().isEmpty ? null : _wardCtrl.text.trim(),
      isDefault: _isDefault,
    );
    if (!mounted) return;
    result.fold(
      (f) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(f.message), backgroundColor: AppColors.terra));
      },
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã lưu địa chỉ'), backgroundColor: AppColors.green700));
        context.pop(true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thêm địa chỉ mới')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
        children: [
          const Text('THÔNG TIN LIÊN HỆ', style: TextStyle(fontSize: 12, color: AppColors.muted, letterSpacing: 0.04)),
          const SizedBox(height: 8),
          _field('Họ và tên người nhận', 'Minh Anh', _nameCtrl),
          _field('Số điện thoại', '0912 345 678', _phoneCtrl),
          const SizedBox(height: 24),
          const Text('ĐỊA CHỈ', style: TextStyle(fontSize: 12, color: AppColors.muted, letterSpacing: 0.04)),
          const SizedBox(height: 8),
          _field('Tỉnh / Thành phố', 'TP. Hồ Chí Minh', _cityCtrl),
          _field('Quận / Huyện', 'Quận 1', _districtCtrl),
          _field('Phường / Xã', 'Phường Bến Nghé', _wardCtrl),
          _field('Địa chỉ cụ thể', '42 Nguyễn Huệ', _addrCtrl),
          const SizedBox(height: 24),
          const Text('LOẠI ĐỊA CHỈ', style: TextStyle(fontSize: 12, color: AppColors.muted, letterSpacing: 0.04)),
          const SizedBox(height: 8),
          Row(children: [_typePill('🏠 Nhà'), _typePill('🏢 Công ty'), _typePill('📍 Khác')]),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Đặt làm địa chỉ mặc định', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  SizedBox(height: 2),
                  Text('Sử dụng cho các đơn hàng tiếp theo', style: TextStyle(fontSize: 11, color: AppColors.muted)),
                ],
              ),
            ),
            Switch(value: _isDefault, onChanged: (v) => setState(() => _isDefault = v), activeColor: AppColors.green700),
          ]),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(color: AppColors.paper, border: Border(top: BorderSide(color: AppColors.line))),
        child: SafeArea(
          child: _saving ? const Center(child: CircularProgressIndicator()) : PrimaryButton(label: 'Lưu địa chỉ', onPressed: _save),
        ),
      ),
    );
  }

  Widget _field(String label, String hint, TextEditingController ctrl) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextField(controller: ctrl, decoration: InputDecoration(labelText: label, hintText: hint, fillColor: AppColors.green50)),
      );

  Widget _typePill(String label) => Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _type = label.substring(2).trim()),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(vertical: 10),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _type == label.substring(2).trim() ? AppColors.green50 : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _type == label.substring(2).trim() ? AppColors.green700 : AppColors.line),
            ),
            child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _type == label.substring(2).trim() ? AppColors.green700 : AppColors.muted)),
          ),
        ),
      );
}