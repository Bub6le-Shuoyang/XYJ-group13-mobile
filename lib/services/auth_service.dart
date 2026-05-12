import 'package:shared_preferences/shared_preferences.dart';
import '../core/models/result.dart';
import '../core/models/auth_models.dart';
import '../core/network/api_client.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();

  // 1. 获取图形验证码
  Future<Result<CaptchaResponseVO>> getCaptcha() async {
    return _apiClient.get<CaptchaResponseVO>(
      '/admin/auth/captcha',
      fromJsonT: (data) => CaptchaResponseVO.fromJson(data),
    );
  }

  // 2. 发送邮箱验证码
  Future<Result<Map<String, dynamic>>> sendEmailCode(
    String email,
    String captchaUuid,
    String captchaCode,
  ) async {
    return _apiClient.post<Map<String, dynamic>>(
      '/admin/auth/send-email-code',
      data: {
        'email': email,
        'captcha_uuid': captchaUuid,
        'captcha_code': captchaCode,
      },
      fromJsonT: (data) => data as Map<String, dynamic>,
    );
  }

  // 3. 管理员登录
  Future<Result<LoginResponseVO>> login(String email, String password) async {
    final result = await _apiClient.post<LoginResponseVO>(
      '/admin/auth/login',
      data: {'email': email, 'password': password},
      fromJsonT: (data) => LoginResponseVO.fromJson(data),
    );

    // 登录成功后保存 token
    if (result.isSuccess && result.data != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', result.data!.token);
      await prefs.setString('refresh_token', result.data!.refreshToken);
      await prefs.setString('user_email', result.data!.user.email);
    }

    return result;
  }

  // 4. 退出登录
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('refresh_token');
    await prefs.remove('user_email');
  }
}
