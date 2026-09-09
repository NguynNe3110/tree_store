import '../../domain/entities/order.dart';
import '../../domain/entities/order_item.dart';
import '../remote/models/responses/order_response.dart';

extension OrderItemResponseMapper on OrderItemResponseDto {
  OrderItem toEntity() => OrderItem(
        id: id,
        orderId: orderId,
        productId: treeId,
        productNameSnapshot: treeNameSnapshot,
        priceSnapshot: unitPriceSnapshot,
        quantity: quantity,
        lineTotal: lineTotal,
        imageUrlSnapshot: imageUrlSnapshot,
        optionsSnapshot: specsSnapshot,
      );
}

extension OrderResponseMapper on OrderResponseDto {
  Order toEntity() => Order(
        id: id,
        userId: userId,
        receiverName: customerName,
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
