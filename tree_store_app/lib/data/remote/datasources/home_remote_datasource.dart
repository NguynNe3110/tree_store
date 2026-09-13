import 'package:dio/dio.dart';
import '../../../core/constants/api_endpoints.dart';
import '../models/responses/home_response.dart';

class HomeRemoteDataSource {
  final Dio _dio;
  HomeRemoteDataSource(this._dio);

  Future<HomeSduiResponse> getHomeBlocks({String? categoryId}) async {
    final res = await _dio.get(
      ApiEndpoints.home,
      queryParameters: {
        if (categoryId != null) 'categoryId': categoryId,
      },
    );
    return HomeSduiResponse.fromJson(res.data as Map<String, dynamic>);
  }
}
