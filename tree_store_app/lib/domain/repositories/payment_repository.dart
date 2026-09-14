import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/payment.dart';

abstract class PaymentRepository {
  Future<Either<Failure, PaymentInit>> createPayment({
    required String orderId,
    required String provider,
  });
}
