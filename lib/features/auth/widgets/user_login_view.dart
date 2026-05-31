import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/app_role.dart';
import '../state/auth_cubit.dart';
import '../state/auth_state.dart';

class UserLoginView extends StatefulWidget {
  const UserLoginView({super.key, required this.onRegisterTap});

  final VoidCallback onRegisterTap;

  @override
  State<UserLoginView> createState() => _UserLoginViewState();
}

class _UserLoginViewState extends State<UserLoginView> {
  final _accountController = TextEditingController(text: 'user01@example.com');
  final _passwordController = TextEditingController(text: 'MyPass123!');

  @override
  void dispose() {
    _accountController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final account = _accountController.text.trim();
    final password = _passwordController.text.trim();
    try {
      await context.read<AuthCubit>().login(
        AppRole.villager,
        account,
        password,
      );
      if (!mounted) {
        return;
      }
      final user = context.read<AuthCubit>().state.user;
      final loginName = user?.nickname?.isNotEmpty == true
          ? user!.nickname!
          : account;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('登录成功: $loginName')));
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

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
              TextField(
                key: ValueKey('user_email_field'),
                controller: _accountController,
                decoration: InputDecoration(
                  hintText: '请输入手机号 / 邮箱',
                  prefixIcon: Icon(Icons.phone_iphone_rounded, size: 20),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 14),
              TextField(
                key: ValueKey('user_password_field'),
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: '请输入密码',
                  prefixIcon: Icon(Icons.lock_outline_rounded, size: 20),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: null,
                  child: Text(
                    '当前仅支持账号密码登录',
                    style: TextStyle(color: Colors.grey[500], fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  return FilledButton(
                    key: const ValueKey('user_login_button'),
                    onPressed: state.isLoading ? null : _handleLogin,
                    style: FilledButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: state.isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('登录'),
                  );
                },
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '还没有账号？',
                    style: TextStyle(color: Colors.grey[500], fontSize: 13),
                  ),
                  TextButton(
                    key: const ValueKey('open_register_button'),
                    onPressed: widget.onRegisterTap,
                    child: const Text('立即注册'),
                  ),
                ],
              ),
              const SizedBox(height: 4),
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
                    onTap: () => _showPasswordOnlyTip(context),
                  ),
                  const SizedBox(width: 32),
                  _SocialIcon(
                    icon: Icons.phone_android_rounded,
                    color: const Color(0xFF1677FF),
                    onTap: () => _showPasswordOnlyTip(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showPasswordOnlyTip(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('当前仅支持账号密码登录')));
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
