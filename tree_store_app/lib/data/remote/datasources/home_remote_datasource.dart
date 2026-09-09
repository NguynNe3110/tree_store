import 'package:dio/dio.dart';
import '../../../core/constants/api_endpoints.dart';
import '../models/responses/home_response.dart';

class HomeRemoteDataSource {
  final Dio _dio;
  HomeRemoteDataSource(this._dio);

  Future<HomeSduiResponse> getHomeBlocks() async {
    final res = await _dio.get(ApiEndpoints.home);
    return HomeSduiResponse.fromJson(res.data as Map<String, dynamic>);
  }
}
