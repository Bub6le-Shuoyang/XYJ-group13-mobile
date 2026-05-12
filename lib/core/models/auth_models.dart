class CaptchaResponseVO {
  final String captchaUuid;
  final String captchaImage;

  CaptchaResponseVO({required this.captchaUuid, required this.captchaImage});

  factory CaptchaResponseVO.fromJson(Map<String, dynamic> json) {
    return CaptchaResponseVO(
      captchaUuid: json['captcha_uuid'] as String,
      captchaImage: json['captcha_image'] as String,
    );
  }
}

class UserVO {
  final int id;
  final String email;
  final String? phone;
  final String? realName;
  final String? avatarUrl;
  final int role;

  UserVO({
    required this.id,
    required this.email,
    this.phone,
    this.realName,
    this.avatarUrl,
    required this.role,
  });

  factory UserVO.fromJson(Map<String, dynamic> json) {
    return UserVO(
      id: json['id'] as int,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      realName: json['realName'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      role: json['role'] as int? ?? 0,
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
