import 'package:equatable/equatable.dart';

class PaymentInit extends Equatable {
  final String paymentId;
  final int orderCode;
  final String checkoutUrl;

  const PaymentInit({
    required this.paymentId,
    required this.orderCode,
    required this.checkoutUrl,
  });

  @override
  List<Object?> get props => [paymentId, orderCode, checkoutUrl];
}
