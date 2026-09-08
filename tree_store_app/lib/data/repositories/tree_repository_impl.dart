import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/tree.dart';
import '../../domain/repositories/tree_repository.dart';
import '../mappers/category_mapper.dart';
import '../mappers/tree_mapper.dart';
import '../remote/datasources/tree_remote_datasource.dart';

class TreeRepositoryImpl implements TreeRepository {
  final TreeRemoteDataSource _remote;
  TreeRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, List<Tree>>> getTrees({
    String? categoryId,
    String? keyword,
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final dtos = await _remote.getTrees(
        categoryId: categoryId,
        keyword: keyword,
        status: status,
        page: page,
        limit: limit,
      );
      return Right(dtos.map((d) => d.toEntity()).toList());
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Tree>> getTreeDetail(String id) async {
    try {
      final dto = await _remote.getTreeDetail(id);
      return Right(dto.toEntity());
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Category>>> getCategories() async {
    try {
      final dtos = await _remote.getCategories();
      return Right(dtos.map((d) => d.toEntity()).toList());
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