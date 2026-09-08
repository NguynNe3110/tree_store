class BaseResponse<T> {
  final int statusCode;
  final String? message;
  final T? data;
  final dynamic error;

  const BaseResponse({
    required this.statusCode,
    this.message,
    this.data,
    this.error,
  });

  bool get isSuccess => statusCode >= 200 && statusCode < 300;

  factory BaseResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic raw) parseData,
  ) {
    return BaseResponse<T>(
      statusCode: (json['statusCode'] as num?)?.toInt() ?? 200,
      message: json['message'] as String?,
      data: json['data'] != null ? parseData(json['data']) : null,
      error: json['error'],
    );
  }
}