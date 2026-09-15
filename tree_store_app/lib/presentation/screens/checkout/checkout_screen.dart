import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/di/injection.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/image_url.dart';
import '../../../domain/entities/address.dart';
import '../../../domain/entities/cart_item.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/repositories/order_repository.dart';
import '../../../domain/usecases/order/create_order_usecase.dart';
import '../../../domain/usecases/profile/get_addresses_usecase.dart';
import '../../blocs/cart_bloc.dart';
import '../../blocs/order_bloc.dart';
import '../../widgets/primary_button.dart';

class CheckoutScreen extends StatefulWidget {
  final Product? singleItem;
  final int quantity;
  
  const CheckoutScreen({super.key, this.singleItem, this.quantity = 1});
  
  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _noteCtrl = TextEditingController();
  String _paymentMethod = 'cod';
  Address? _address;
  bool _loadingAddress = true;
  bool _isProcessingPayment = false;

  @override
  void initState() {
    super.initState();
    if (widget.singleItem == null) {
      context.read<CartBloc>().add(const CartLoad());
    }
    _loadInitialAddress();
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadInitialAddress() async {
    final result = await sl<GetAddressesUsecase>()();
    result.fold(
      (_) => setState(() => _loadingAddress = false),
      (list) {
        final defaultAddr = list.where((a) => a.isDefault).isNotEmpty ? list.firstWhere((a) => a.isDefault) : (list.isNotEmpty ? list.first : null);
        setState(() {
          _address = defaultAddr;
          _loadingAddress = false;
        });
      },
    );
  }

  Future<void> _selectAddress() async {
    final selected = await context.push<Address?>('/addresses');
    if (selected != null) {
      setState(() => _address = selected);
    }
  }

  String _formatPrice(double v) {
    final s = v.toStringAsFixed(0);
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return '${buf.toString()}₫';
  }

  double _calculateTotal(List<CartItem> cartItems) {
    if (widget.singleItem != null) {
      return widget.singleItem!.finalPrice * widget.quantity;
    }
    double sum = 0;
    for (final it in cartItems) {
      sum += (it.tree?.finalPrice ?? 0) * it.quantity;
    }
    return sum;
  }

  Future<void> _handlePlaceOrder(List<CartItem> cartItems) async {
    final addr = _address;
    if (addr == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn địa chỉ giao hàng'), backgroundColor: AppColors.terra));
      return;
    }

    List<OrderItemInput> orderItems;
    if (widget.singleItem != null) {
      orderItems = [OrderItemInput(treeId: widget.singleItem!.id, quantity: widget.quantity)];
    } else {
      if (cartItems.isEmpty) return;
      orderItems = cartItems.map((c) => OrderItemInput(treeId: c.treeId, quantity: c.quantity)).toList();
    }

    setState(() => _isProcessingPayment = _paymentMethod != 'cod');

    context.read<OrderBloc>().add(OrderCreate(CreateOrderParams(
          customerName: addr.receiverName,
          phoneNumber: addr.phoneNumber,
          addressLine: addr.addressLine,
          city: addr.city,
          district: addr.district,
          ward: addr.ward,
          note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
          items: orderItems,
          paymentMethod: _paymentMethod,
        )));
  }

  Future<void> _startGatewayPayment(String orderId) async {
    context.read<OrderBloc>().add(OrderStartPayment(orderId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thanh toán')),
      body: BlocConsumer<OrderBloc, OrderState>(
        listener: (context, state) async {
          if (state is OrderCreated) {
            if (_paymentMethod == 'cod') {
              context.go('/order-success?id=${state.order.id}');
            } else {
              _startGatewayPayment(state.order.id);
            }
          } else if (state is PaymentReady) {
            await context.push('/pay-webview', extra: {
              'orderId': state.orderId,
              'url': state.checkoutUrl,
            });
            if (!context.mounted) return;
            setState(() => _isProcessingPayment = true);
            context.read<OrderBloc>().add(OrderWatchPayment(state.orderId));
          } else if (state is PaymentPaid) {
            if (!context.mounted) return;
            context.go('/order-success?id=${state.order.id}&paid=1');
          } else if (state is PaymentTimeout) {
            if (!context.mounted) return;
            setState(() => _isProcessingPayment = false);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Chưa nhận được xác nhận thanh toán. Đơn vẫn giữ nguyên, kiểm tra lại trong mục Đơn hàng.'),
              backgroundColor: AppColors.terra,
            ));
            context.go('/orders');
          } else if (state is OrderError) {
            if (!context.mounted) return;
            setState(() => _isProcessingPayment = false);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: AppColors.terra));
          }
        },
        builder: (context, orderState) {
          if (_isProcessingPayment) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text('Đang xử lý thanh toán...', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.green700)),
                  Text('Vui lòng không thoát ứng dụng', style: TextStyle(fontSize: 12, color: AppColors.muted)),
                ],
              ),
            );
          }

          return BlocBuilder<CartBloc, CartState>(
            builder: (context, cartState) {
              final List<CartItem> displayItems;
              if (widget.singleItem != null) {
                displayItems = [CartItem(treeId: widget.singleItem!.id, quantity: widget.quantity, tree: widget.singleItem)];
              } else {
                if (cartState is! CartLoaded) {
                  return const Center(child: CircularProgressIndicator());
                }
                displayItems = cartState.items;
              }

              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                children: [
                  const SizedBox(height: 12),
                  _addressCard(),
                  const SizedBox(height: 12),
                  _itemsCard(displayItems),
                  const SizedBox(height: 12),
                  _paymentCard(),
                  const SizedBox(height: 12),
                  _noteField(),
                ],
              );
            },
          );
        },
      ),
      bottomSheet: widget.singleItem != null 
        ? _buildBottomBar([CartItem(treeId: widget.singleItem!.id, quantity: widget.quantity, tree: widget.singleItem)])
        : BlocBuilder<CartBloc, CartState>(
            builder: (context, state) => state is CartLoaded ? _buildBottomBar(state.items) : const SizedBox.shrink(),
          ),
    );
  }

  Widget _buildBottomBar(List<CartItem> items) {
    final total = _calculateTotal(items);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      decoration: const BoxDecoration(color: AppColors.paper, border: Border(top: BorderSide(color: AppColors.line2))),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Tổng thanh toán', style: TextStyle(fontSize: 11, color: AppColors.muted)),
              Text(_formatPrice(total), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.green700)),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: PrimaryButton(label: 'Đặt hàng', onPressed: () => _handlePlaceOrder(items)),
          ),
        ],
      ),
    );
  }

  Widget _addressCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.paper, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.line2)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.location_on_outlined, color: AppColors.green700, size: 20),
            const SizedBox(width: 8),
            const Text('Địa chỉ giao hàng', style: TextStyle(fontWeight: FontWeight.w700)),
            const Spacer(),
            GestureDetector(onTap: _selectAddress, child: const Text('Đổi', style: TextStyle(fontSize: 12, color: AppColors.green700, fontWeight: FontWeight.w600))),
          ]),
          const SizedBox(height: 12),
          if (_loadingAddress)
            const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator(strokeWidth: 2)))
          else if (_address == null)
            const Text('Chưa có địa chỉ. Bấm "Đổi" để thêm.', style: TextStyle(fontSize: 13, color: AppColors.terra))
          else ...[
            Text(_address!.receiverName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(_address!.phoneNumber, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
            const SizedBox(height: 6),
            Text(_address!.fullAddress, style: const TextStyle(fontSize: 13, color: AppColors.ink2, height: 1.4)),
            if (_address!.isDefault) ...[
              const SizedBox(height: 8),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: AppColors.green50, borderRadius: BorderRadius.circular(6)), child: const Text('MẶC ĐỊNH', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.green700))),
            ]
          ],
        ],
      ),
    );
  }

  Widget _itemsCard(List<CartItem> items) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.paper, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.line2)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Text('🛒 Sản phẩm', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            const Spacer(),
            Text('(${items.length})', style: const TextStyle(fontSize: 12, color: AppColors.muted)),
          ]),
          const SizedBox(height: 12),
          ...items.map((it) {
            final tree = it.tree;
            final imgUrl = (tree?.images.isNotEmpty ?? false) ? resolveImageUrl(tree!.images.first.imageUrl) : '';
            final name = tree?.name ?? it.treeId.substring(0, 8);
            final price = tree?.finalPrice ?? 0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: imgUrl.isEmpty
                          ? Container(color: AppColors.green50, child: const Icon(Icons.eco, size: 20, color: AppColors.green700))
                          : Image.network(imgUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: AppColors.green50, child: const Icon(Icons.eco, size: 20, color: AppColors.green700))),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                        const Text('Kèm chậu gốm', style: TextStyle(fontSize: 10, color: AppColors.muted)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(_formatPrice(price * it.quantity), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.green700)),
                      Text('×${it.quantity}', style: const TextStyle(fontSize: 10, color: AppColors.muted)),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _paymentCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.paper, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.line2)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('💳 Phương thức thanh toán', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          _payOption('cod', 'Thanh toán khi nhận hàng (COD)', Icons.payments_outlined),
          _payOption('payos', 'QR ngân hàng / ví (PayOS)', Icons.qr_code_2, subtitle: 'VietQR · MoMo · ZaloPay'),
        ],
      ),
    );
  }

  Widget _payOption(String val, String title, IconData icon, {String? subtitle}) {
    final on = _paymentMethod == val;
    return GestureDetector(
      onTap: () => setState(() => _paymentMethod = val),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(width: 36, height: 36, decoration: BoxDecoration(color: AppColors.green50, borderRadius: BorderRadius.circular(8)), child: Icon(icon, size: 18, color: AppColors.green700)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  if (subtitle != null) Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
                ],
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: on ? AppColors.green700 : AppColors.line2, width: 2)),
              padding: const EdgeInsets.all(3),
              child: on ? Container(decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.green700)) : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _noteField() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.paper, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.line2)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('📝 Ghi chú cho shop', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          TextField(controller: _noteCtrl, maxLines: 2, style: const TextStyle(fontSize: 13), decoration: const InputDecoration(hintText: 'Giao giờ hành chính, gọi trước...', border: InputBorder.none, hintStyle: TextStyle(color: AppColors.muted))),
        ],
      ),
    );
  }
}