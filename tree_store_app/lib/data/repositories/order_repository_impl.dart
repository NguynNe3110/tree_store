import 'package:dartz/dartz.dart' hide Order;
import 'package:dio/dio.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';
import '../mappers/order_mapper.dart';
import '../remote/datasources/order_remote_datasource.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource _remote;
  OrderRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, List<Order>>> getOrders() async {
    try {
      final dtos = await _remote.getOrders();
      return Right(dtos.map((d) => d.toEntity()).toList());
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Order>> getOrderDetail(String id) async {
    try {
      final dto = await _remote.getOrderDetail(id);
      return Right(dto.toEntity());
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Order>> createOrder({
    required String customerName,
    required String phoneNumber,
    required String addressLine,
    String city = '',
    String district = '',
    String? ward,
    String? note,
    required List<OrderItemInput> items,
    String paymentMethod = 'cod',
    double shippingFee = 0,
    double discountAmount = 0,
  }) async {
    try {
      final dto = await _remote.createOrder(
        customerName: customerName,
        phoneNumber: phoneNumber,
        addressLine: addressLine,
        city: city,
        district: district,
        ward: ward,
        note: note,
        items: items,
        paymentMethod: paymentMethod,
        shippingFee: shippingFee,
        discountAmount: discountAmount,
      );
      return Right(dto.toEntity());
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

Failure _mapDioError(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.connectionError:
      return const NetworkFailure();
    case DioExceptionType.badResponse:
      final code = e.response?.statusCode ?? 0;
      return ServerFailure(e.response?.data?['message']?.toString() ?? 'Server error $code');
    default:
      return ServerFailure(e.message ?? 'Unknown error');
  }
}