import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/result.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late Dio _dio;

  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        // TODO: 替换为实际的后端 Base URL
        baseUrl: 'http://localhost:8080/api/v1',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          return handler.next(e);
        },
      ),
    );
  }

  Future<Result<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJsonT,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return Result.fromJson(response.data, fromJsonT);
    } catch (e) {
      return Result(
        code: -1,
        message: e.toString(),
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
    }
  }

  Future<Result<T>> post<T>(
    String path, {
    dynamic data,
    T Function(dynamic)? fromJsonT,
  }) async {
    try {
      final response = await _dio.post(path, data: data);
      return Result.fromJson(response.data, fromJsonT);
    } catch (e) {
      return Result(
        code: -1,
        message: e.toString(),
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
    }
  }
}
