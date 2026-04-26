class ApiResponse<T> {
  ApiResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  final bool success;
  final T data;
  final String message;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic rawData) mapData,
  ) {
    return ApiResponse<T>(
      success: json['success'] as bool? ?? false,
      data: mapData(json['data']),
      message: json['message'] as String? ?? '',
    );
  }
}
