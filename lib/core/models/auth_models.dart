class CaptchaResponseVO {
  final String captchaId;
  final String captchaImageBase64;

  CaptchaResponseVO({
    required this.captchaId,
    required this.captchaImageBase64,
  });

  factory CaptchaResponseVO.fromJson(Map<String, dynamic> json) {
    return CaptchaResponseVO(
      captchaId: json['captcha_id'] as String? ?? json['captchaId'] as String,
      captchaImageBase64:
          json['captcha_image_base64'] as String? ??
          json['captchaImageBase64'] as String,
    );
  }
}

class UserVO {
  final int id;
  final String? account;
  final String email;
  final String? phone;
  final String? nickname;
  final String? avatarUrl;
  final String role;

  UserVO({
    required this.id,
    this.account,
    required this.email,
    this.phone,
    this.nickname,
    this.avatarUrl,
    required this.role,
  });

  factory UserVO.fromJson(Map<String, dynamic> json) {
    return UserVO(
      id: json['id'] as int,
      account: json['account'] as String?,
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      nickname: json['nickname'] as String?,
      avatarUrl: json['avatar_url'] as String? ?? json['avatarUrl'] as String?,
      role: json['role'] as String? ?? '',
    );
  }
}

class LoginResponseVO {
  final String token;
  final String refreshToken;
  final int expiresIn;
  final UserVO user;

  LoginResponseVO({
    required this.token,
    required this.refreshToken,
    required this.expiresIn,
    required this.user,
  });

  factory LoginResponseVO.fromJson(Map<String, dynamic> json) {
    return LoginResponseVO(
      token: json['token'] as String,
      refreshToken: json['refresh_token'] as String,
      expiresIn: json['expires_in'] as int,
      user: UserVO.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}
