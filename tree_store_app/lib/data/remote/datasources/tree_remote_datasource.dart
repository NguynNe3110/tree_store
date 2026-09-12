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
    // Backend serializes TreeDto directly at root, not wrapped in { data: ... }
    final data = res.data;
    if (data is! Map<String, dynamic>) {
      throw Exception('Invalid tree detail response');
    }
    return TreeResponseDto.fromJson(data);
  }

  Future<List<CategoryResponseDto>> getCategories() async {
    final res = await _dio.get(ApiEndpoints.categories);
    // Backend returns a raw JSON array at root, not { data: [...] }
    final raw = res.data is List
        ? (res.data as List)
        : ((res.data as Map<String, dynamic>)['data'] as List?) ?? const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(CategoryResponseDto.fromJson)
        .toList();
  }
}