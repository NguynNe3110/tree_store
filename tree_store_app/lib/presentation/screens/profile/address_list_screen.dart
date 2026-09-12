import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/di/injection.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/address.dart';
import '../../../domain/usecases/profile/get_addresses_usecase.dart';

class AddressListScreen extends StatefulWidget {
  const AddressListScreen({super.key});
  @override
  State<AddressListScreen> createState() => _AddressListScreenState();
}

class _AddressListScreenState extends State<AddressListScreen> {
  late Future<List<Address>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Address>> _load() async {
    final result = await sl<GetAddressesUsecase>()();
    return result.fold((f) => throw Exception(f.message), (list) => list);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sổ địa chỉ')),
      body: FutureBuilder<List<Address>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString(), style: const TextStyle(color: AppColors.terra)));
          }
          final list = snapshot.data ?? const [];
          if (list.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.location_off_outlined, size: 64, color: AppColors.line),
                  SizedBox(height: 12),
                  Text('Chưa có địa chỉ nào', style: TextStyle(fontSize: 15, color: AppColors.muted)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (_, i) => _card(list[i]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final added = await context.push<bool>('/add-address');
          if (!mounted) return;
          if (added == true) setState(() => _future = _load());
        },
        backgroundColor: AppColors.green700,
        child: const Icon(Icons.add, color: Colors.white, size: 26),
      ),
    );
  }

  Widget _card(Address a) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(16),
        border: a.isDefault ? Border.all(color: AppColors.green500, width: 1.5) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(a.receiverName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(width: 8),
              if (a.isDefault)
                Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: AppColors.green700, borderRadius: BorderRadius.circular(6)), child: const Text('MẶC ĐỊNH', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white))),
              if (a.label != null && a.label!.isNotEmpty)
                Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: AppColors.green50, borderRadius: BorderRadius.circular(6)), child: Text(a.label!.toUpperCase(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.green700))),
            ],
          ),
          const SizedBox(height: 8),
          Text(a.phoneNumber, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
          const SizedBox(height: 4),
          Text(a.fullAddress, style: const TextStyle(fontSize: 13, color: AppColors.ink2, height: 1.5)),
        ],
      ),
    );
  }
}