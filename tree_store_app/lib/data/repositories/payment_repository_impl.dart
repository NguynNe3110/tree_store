import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/payment.dart';
import '../../domain/repositories/payment_repository.dart';
import '../remote/datasources/payment_remote_datasource.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentRemoteDataSource _remote;
  PaymentRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, PaymentInit>> createPayment({
    required String orderId,
    required String provider,
  }) async {
    try {
      final dto = await _remote.createPayment(orderId: orderId, provider: provider);
      if (dto.checkoutUrl.isEmpty) {
        return const Left(ServerFailure('Gateway trả về thiếu checkout URL'));
      }
      return Right(PaymentInit(
        paymentId: dto.paymentId,
        orderCode: dto.orderCode,
        checkoutUrl: dto.checkoutUrl,
      ));
    } on DioException catch (e) {
      final code = e.response?.statusCode ?? 0;
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.connectionError) {
        return const Left(NetworkFailure());
      }
      return Left(ServerFailure(
          e.response?.data?['message']?.toString() ?? 'Server error $code'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
