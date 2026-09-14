import 'package:dartz/dartz.dart' hide Order;
import '../../../core/error/failures.dart';
import '../../entities/payment.dart';
import '../../repositories/payment_repository.dart';

class CreatePaymentUsecase {
  final PaymentRepository _repo;
  const CreatePaymentUsecase(this._repo);

  Future<Either<Failure, PaymentInit>> call({
    required String orderId,
    required String provider,
  }) {
    if (orderId.isEmpty || provider.isEmpty) {
      return Future.value(
          const Left(ValidationFailure('orderId and provider required')));
    }
    return _repo.createPayment(orderId: orderId, provider: provider);
  }
}
