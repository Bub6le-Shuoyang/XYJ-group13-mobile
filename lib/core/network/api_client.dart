import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../models/result.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late Dio _dio;

  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
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
    } on DioException catch (e) {
      return _handleDioException(e, fromJsonT);
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
    } on DioException catch (e) {
      return _handleDioException(e, fromJsonT);
    } catch (e) {
      return Result(
        code: -1,
        message: e.toString(),
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
    }
  }

  Result<T> _handleDioException<T>(
    DioException e,
    T Function(dynamic)? fromJsonT,
  ) {
    final responseData = e.response?.data;
    if (responseData is Map<String, dynamic>) {
      return Result.fromJson(responseData, fromJsonT);
    }
    return Result(
      code: e.response?.statusCode ?? -1,
      message: e.message ?? e.toString(),
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }
}
