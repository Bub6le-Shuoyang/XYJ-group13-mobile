import 'package:flutter/foundation.dart';

/// 应用全局基础配置，统一管理后端地址。
///
/// 优先级：`--dart-define=API_BASE_URL=...` 编译时注入 > 这里定义的默认值。
class AppConfig {
  AppConfig._();

  /// 后端 API 基础地址，编译时可通过 --dart-define=API_BASE_URL 覆盖。
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.45.54:7022/api/v1',
  );

  /// 静态资源基础地址（图片等），由 apiBaseUrl 派生。
  static String get resourceBaseUrl {
    final uri = Uri.parse(apiBaseUrl);
    return '${uri.scheme}://${uri.host}:${uri.port}';
  }
}
