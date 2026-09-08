import '../../domain/entities/order.dart';
import '../../domain/entities/order_item.dart';
import '../remote/models/responses/order_response.dart';

extension OrderItemResponseMapper on OrderItemResponseDto {
  OrderItem toEntity() => OrderItem(
        id: id,
        orderId: orderId,
        treeId: treeId,
        treeNameSnapshot: treeNameSnapshot,
        unitPriceSnapshot: unitPriceSnapshot,
        quantity: quantity,
        lineTotal: lineTotal,
        imageUrlSnapshot: imageUrlSnapshot,
        specsSnapshot: specsSnapshot,
      );
}

extension OrderResponseMapper on OrderResponseDto {
  Order toEntity() => Order(
        id: id,
        userId: userId,
        customerName: customerName,
        phoneNumber: phoneNumber,
        addressLine: addressLine,
        note: note,
        status: OrderStatusX.fromApi(status),
        paymentStatus: PaymentStatusX.fromApi(paymentStatus),
        subtotalPrice: subtotalPrice,
        discountAmount: discountAmount,
        shippingFee: shippingFee,
        totalPrice: totalPrice,
        items: items.map((e) => e.toEntity()).toList(),
        createdAt: DateTime.tryParse(createdAt ?? ''),
        updatedAt: DateTime.tryParse(updatedAt ?? ''),
      );
}