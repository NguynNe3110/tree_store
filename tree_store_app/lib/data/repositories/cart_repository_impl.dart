import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/repositories/cart_repository.dart';
import '../mappers/cart_mapper.dart';
import '../remote/datasources/cart_remote_datasource.dart';

class CartRepositoryImpl implements CartRepository {
  final CartRemoteDataSource _remote;
  CartRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, List<CartItem>>> getCart() async {
    try {
      final dtos = await _remote.getCart();
      return Right(dtos.map((d) => d.toEntity()).toList());
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addToCart({required String treeId, int quantity = 1, String? note}) async {
    try {
      await _remote.addToCart(treeId: treeId, quantity: quantity, note: note);
      return const Right(null);
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeFromCart(String id) async {
    try {
      await _remote.removeFromCart(id);
      return const Right(null);
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
      if (code == 401 || code == 403) {
        return AuthFailure(e.response?.data?['message']?.toString() ?? 'Auth failed');
      }
      return ServerFailure(e.response?.data?['message']?.toString() ?? 'Server error $code');
    default:
      return ServerFailure(e.message ?? 'Unknown error');
  }
}