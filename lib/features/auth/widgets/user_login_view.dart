import 'package:flutter/material.dart';
import '../../../core/models/app_role.dart';

class UserLoginView extends StatelessWidget {
  const UserLoginView({super.key, required this.onLogin});

  final ValueChanged<AppRole> onLogin;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '手机号登录',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const TextField(
                key: ValueKey('user_email_field'),
                decoration: InputDecoration(
                  hintText: '请输入手机号 / 邮箱',
                  prefixIcon: Icon(Icons.phone_iphone_rounded, size: 20),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 14),
              const TextField(
                key: ValueKey('user_password_field'),
                obscureText: true,
                decoration: InputDecoration(
                  hintText: '请输入密码 / 验证码',
                  prefixIcon: Icon(Icons.lock_outline_rounded, size: 20),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    '获取验证码',
                    style: TextStyle(color: colorScheme.primary, fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              FilledButton(
                key: const ValueKey('user_login_button'),
                onPressed: () => onLogin(AppRole.villager),
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('登录 / 注册'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey[200])),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '其他登录方式',
                      style: TextStyle(color: Colors.grey[400], fontSize: 13),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey[200])),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _SocialIcon(
                    icon: Icons.wechat_rounded,
                    color: const Color(0xFF07C160),
                    onTap: () => onLogin(AppRole.villager),
                  ),
                  const SizedBox(width: 32),
                  _SocialIcon(
                    icon: Icons.phone_android_rounded,
                    color: const Color(0xFF1677FF),
                    onTap: () => onLogin(AppRole.villager),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SocialIcon extends StatelessWidget {
  const _SocialIcon({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icon, color: color, size: 26),
      ),
    );
  }
}
