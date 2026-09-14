import 'package:equatable/equatable.dart';
import 'order_item.dart';

enum OrderStatus { pending, confirmed, shipping, delivered, cancelled }

extension OrderStatusX on OrderStatus {
  String get apiName => name;
  static OrderStatus fromApi(String? raw) {
    switch (raw) {
      case 'confirmed':
        return OrderStatus.confirmed;
      case 'shipping':
        return OrderStatus.shipping;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }
}

enum PaymentMethod { cod, bankTransfer, eWallet, payos }

extension PaymentMethodX on PaymentMethod {
  String get apiName {
    switch (this) {
      case PaymentMethod.cod:
        return 'cod';
      case PaymentMethod.bankTransfer:
        return 'bank_transfer';
      case PaymentMethod.eWallet:
        return 'e_wallet';
      case PaymentMethod.payos:
        return 'payos';
    }
  }

  static PaymentMethod fromApi(String? raw) {
    switch (raw) {
      case 'bank_transfer':
        return PaymentMethod.bankTransfer;
      case 'e_wallet':
        return PaymentMethod.eWallet;
      case 'payos':
        return PaymentMethod.payos;
      default:
        return PaymentMethod.cod;
    }
  }
}

enum PaymentStatus { unpaid, paid, refunded }

extension PaymentStatusX on PaymentStatus {
  String get apiName => name;
  static PaymentStatus fromApi(String? raw) {
    switch (raw) {
      case 'paid':
        return PaymentStatus.paid;
      case 'refunded':
        return PaymentStatus.refunded;
      default:
        return PaymentStatus.unpaid;
    }
  }
}

class Order extends Equatable {
  final String id;
  final String? userId;
  final String? addressId;
  final OrderStatus status;
  final PaymentMethod paymentMethod;
  final PaymentStatus paymentStatus;
  final double subtotalPrice;
  final double shippingFee;
  final double discountAmount;
  final double totalPrice;
  final String? receiverName;
  final String? phoneNumber;
  final String? addressLine;
  final String? city;
  final String? district;
  final String? ward;
  final String? postalCode;
  final String? note;
  final List<OrderItem> items;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Order({
    required this.id,
    this.userId,
    this.addressId,
    this.status = OrderStatus.pending,
    this.paymentMethod = PaymentMethod.cod,
    this.paymentStatus = PaymentStatus.unpaid,
    this.subtotalPrice = 0,
    this.shippingFee = 0,
    this.discountAmount = 0,
    required this.totalPrice,
    this.receiverName,
    this.phoneNumber,
    this.addressLine,
    this.city,
    this.district,
    this.ward,
    this.postalCode,
    this.note,
    this.items = const [],
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        addressId,
        status,
        paymentMethod,
        paymentStatus,
        subtotalPrice,
        shippingFee,
        discountAmount,
        totalPrice,
        receiverName,
        phoneNumber,
        addressLine,
        city,
        district,
        ward,
        postalCode,
        note,
        items,
        createdAt,
        updatedAt,
      ];
}