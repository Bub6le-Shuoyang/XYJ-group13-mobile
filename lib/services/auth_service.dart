import 'package:shared_preferences/shared_preferences.dart';
import '../core/models/app_role.dart';
import '../core/models/result.dart';
import '../core/models/auth_models.dart';
import '../core/network/api_client.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();

  // 1. 获取图形验证码
  Future<Result<CaptchaResponseVO>> getCaptcha() async {
    return _apiClient.get<CaptchaResponseVO>(
      '/auth/captcha',
      fromJsonT: (data) => CaptchaResponseVO.fromJson(data),
    );
  }

  Future<Result<bool>> sendEmailCode(
    String email,
    String captchaId,
    String captchaCode,
  ) async {
    return _apiClient.post<bool>(
      '/auth/send-email-code',
      data: {
        'email': email,
        'captcha_id': captchaId,
        'captchaId': captchaId,
        'captcha_code': captchaCode,
        'captchaCode': captchaCode,
      },
      fromJsonT: (data) => data as bool,
    );
  }

  Future<Result<LoginResponseVO>> login(
    AppRole role,
    String account,
    String password,
  ) async {
    final result = await _apiClient.post<LoginResponseVO>(
      '/auth/login',
      data: {
        'account': account,
        'password': password,
        'role': _roleParam(role),
      },
      fromJsonT: (data) => LoginResponseVO.fromJson(data),
    );

    // 登录成功后保存 token
    if (result.isSuccess && result.data != null) {
      await _saveLoginSession(result.data!);
    }

    return result;
  }

  Future<Result<LoginResponseVO>> register({
    required AppRole role,
    required String email,
    required String emailCode,
    required String password,
    required String confirmPassword,
  }) async {
    final result = await _apiClient.post<LoginResponseVO>(
      '/auth/register',
      data: {
        'email': email,
        'email_code': emailCode,
        'emailCode': emailCode,
        'password': password,
        'confirm_password': confirmPassword,
        'confirmPassword': confirmPassword,
        'role': _roleParam(role),
      },
      fromJsonT: (data) => LoginResponseVO.fromJson(data),
    );

    if (result.isSuccess && result.data != null) {
      await _saveLoginSession(result.data!);
    }

    return result;
  }

  String _roleParam(AppRole role) {
    return switch (role) {
      AppRole.villager => 'USER',
      AppRole.courier => 'COURIER',
      AppRole.admin => 'ADMIN',
    };
  }

  Future<SavedLoginSession?> loadSavedSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final roleText = prefs.getString('user_role');
    if (token == null || token.isEmpty || roleText == null) {
      return null;
    }
    final role = _roleFromParam(roleText);
    if (role == null) {
      return null;
    }
    return SavedLoginSession(
      role: role,
      user: UserVO(
        id: prefs.getInt('user_id') ?? 0,
        email: prefs.getString('user_email') ?? '',
        phone: prefs.getString('user_phone'),
        nickname: prefs.getString('user_nickname'),
        avatarUrl: prefs.getString('user_avatar_url'),
        role: roleText,
      ),
    );
  }

  AppRole? _roleFromParam(String role) {
    return switch (role.toUpperCase()) {
      'USER' => AppRole.villager,
      'COURIER' => AppRole.courier,
      'ADMIN' => AppRole.admin,
      _ => null,
    };
  }

  Future<void> _saveLoginSession(LoginResponseVO data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', data.token);
    await prefs.setString('refresh_token', data.refreshToken);
    await prefs.setInt('user_id', data.user.id);
    await prefs.setString('user_email', data.user.email);
    await prefs.setString('user_role', data.user.role);
    if (data.user.phone != null) {
      await prefs.setString('user_phone', data.user.phone!);
    }
    if (data.user.nickname != null) {
      await prefs.setString('user_nickname', data.user.nickname!);
    }
    if (data.user.avatarUrl != null) {
      await prefs.setString('user_avatar_url', data.user.avatarUrl!);
    }
  }

  // 4. 退出登录
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('refresh_token');
    await prefs.remove('user_id');
    await prefs.remove('user_email');
    await prefs.remove('user_role');
    await prefs.remove('user_phone');
    await prefs.remove('user_nickname');
    await prefs.remove('user_avatar_url');
  }
}

class SavedLoginSession {
  const SavedLoginSession({required this.role, required this.user});

  final AppRole role;
  final UserVO user;
}
