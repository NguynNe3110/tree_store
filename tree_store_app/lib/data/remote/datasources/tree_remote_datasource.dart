import 'package:dio/dio.dart';
import '../../../core/constants/api_endpoints.dart';
import '../models/responses/category_response.dart';
import '../models/responses/tree_response.dart';

class TreeRemoteDataSource {
  final Dio _dio;
  TreeRemoteDataSource(this._dio);

  Future<List<TreeResponseDto>> getTrees({
    String? categoryId,
    String? keyword,
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    final res = await _dio.get(
      ApiEndpoints.trees,
      queryParameters: {
        if (categoryId != null) 'category_id': categoryId,
        if (keyword != null) 'keyword': keyword,
        if (status != null) 'status': status,
        'page': page,
        'limit': limit,
      },
    );
    final raw = (res.data['data'] as List?) ?? const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(TreeResponseDto.fromJson)
        .toList();
  }

  Future<TreeResponseDto> getTreeDetail(String id) async {
    final res = await _dio.get(
      ApiEndpoints.treeDetail.replaceAll('{id}', id),
    );
    return TreeResponseDto.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<List<CategoryResponseDto>> getCategories() async {
    final res = await _dio.get(ApiEndpoints.categories);
    final raw = (res.data['data'] as List?) ?? const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(CategoryResponseDto.fromJson)
        .toList();
  }
}