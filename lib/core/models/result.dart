class Result<T> {
  final int code;
  final String message;
  final T? data;
  final int timestamp;

  Result({
    required this.code,
    required this.message,
    this.data,
    required this.timestamp,
  });

  bool get isSuccess => code == 200;

  factory Result.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return Result(
      code: json['code'] as int,
      message: json['message'] as String,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'] as T?,
      timestamp: json['timestamp'] as int,
    );
  }
}
