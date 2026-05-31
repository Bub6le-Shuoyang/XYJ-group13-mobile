import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/app_role.dart';
import '../../../core/models/auth_models.dart';
import '../../../services/auth_service.dart';
import '../state/auth_cubit.dart';
import '../state/auth_state.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key, required this.onBackToLogin});

  final VoidCallback onBackToLogin;

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _authService = AuthService();
  final _emailController = TextEditingController();
  final _captchaController = TextEditingController();
  final _emailCodeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  AppRole _selectedRole = AppRole.villager;
  CaptchaResponseVO? _captcha;
  bool _isCaptchaLoading = false;
  bool _isSendingEmailCode = false;

  @override
  void initState() {
    super.initState();
    _loadCaptcha();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _captchaController.dispose();
    _emailCodeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadCaptcha() async {
    setState(() => _isCaptchaLoading = true);
    final result = await _authService.getCaptcha();
    if (!mounted) {
      return;
    }
    setState(() {
      _isCaptchaLoading = false;
      _captcha = result.data;
      _captchaController.clear();
    });
    if (!result.isSuccess || result.data == null) {
      _showMessage(result.message);
    }
  }

  Future<void> _sendEmailCode() async {
    final email = _emailController.text.trim();
    final captchaCode = _captchaController.text.trim();
    final captcha = _captcha;
    if (email.isEmpty || captchaCode.isEmpty || captcha == null) {
      _showMessage('请先填写邮箱和图形验证码');
      return;
    }

    setState(() => _isSendingEmailCode = true);
    final result = await _authService.sendEmailCode(
      email,
      captcha.captchaId,
      captchaCode,
    );
    if (!mounted) {
      return;
    }
    setState(() => _isSendingEmailCode = false);
    if (result.isSuccess && result.data == true) {
      _showMessage('邮箱验证码已发送，开发环境可在后端控制台查看');
      return;
    }
    _showMessage(result.message);
    await _loadCaptcha();
  }

  Future<void> _handleRegister() async {
    try {
      await context.read<AuthCubit>().register(
        role: _selectedRole,
        email: _emailController.text.trim(),
        emailCode: _emailCodeController.text.trim(),
        password: _passwordController.text.trim(),
        confirmPassword: _confirmPasswordController.text.trim(),
      );
      if (!mounted) {
        return;
      }
      final user = context.read<AuthCubit>().state.user;
      final loginName = user?.nickname?.isNotEmpty == true
          ? user!.nickname!
          : _emailController.text.trim();
      _showMessage('注册成功: $loginName');
    } catch (e) {
      if (!mounted) {
        return;
      }
      _showMessage(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Uint8List? _captchaBytes() {
    final image = _captcha?.captchaImageBase64;
    if (image == null || image.isEmpty) {
      return null;
    }
    final base64Text = image.contains(',') ? image.split(',').last : image;
    return base64Decode(base64Text);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
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
                '新用户注册',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              TextButton(
                key: const ValueKey('back_to_login_button'),
                onPressed: widget.onBackToLogin,
                child: const Text('去登录'),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _RoleSelector(
            selectedRole: _selectedRole,
            onChanged: (role) => setState(() => _selectedRole = role),
          ),
          const SizedBox(height: 18),
          TextField(
            key: const ValueKey('register_email_field'),
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: '请输入邮箱',
              prefixIcon: Icon(Icons.email_outlined, size: 20),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextField(
                  key: const ValueKey('register_captcha_field'),
                  controller: _captchaController,
                  decoration: const InputDecoration(
                    hintText: '图形验证码',
                    prefixIcon: Icon(Icons.verified_outlined, size: 20),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _CaptchaBox(
                bytes: _captchaBytes(),
                isLoading: _isCaptchaLoading,
                onRefresh: _loadCaptcha,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextField(
                  key: const ValueKey('register_email_code_field'),
                  controller: _emailCodeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: '邮箱验证码',
                    prefixIcon: Icon(Icons.mark_email_read_outlined, size: 20),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 112,
                height: 52,
                child: OutlinedButton(
                  key: const ValueKey('send_register_email_code_button'),
                  onPressed: _isSendingEmailCode ? null : _sendEmailCode,
                  child: _isSendingEmailCode
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('发送验证码'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            key: const ValueKey('register_password_field'),
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              hintText: '请输入密码',
              prefixIcon: Icon(Icons.lock_outline_rounded, size: 20),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            key: const ValueKey('register_confirm_password_field'),
            controller: _confirmPasswordController,
            obscureText: true,
            decoration: const InputDecoration(
              hintText: '请再次输入密码',
              prefixIcon: Icon(Icons.lock_reset_rounded, size: 20),
            ),
          ),
          const SizedBox(height: 22),
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              return FilledButton(
                key: const ValueKey('register_submit_button'),
                onPressed: state.isLoading ? null : _handleRegister,
                style: FilledButton.styleFrom(
                  backgroundColor: _selectedRole.color,
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
                    : Text('注册${_selectedRole.title}'),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _RoleSelector extends StatelessWidget {
  const _RoleSelector({required this.selectedRole, required this.onChanged});

  final AppRole selectedRole;
  final ValueChanged<AppRole> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: AppRole.values.map((role) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: role == AppRole.values.last ? 0 : 8,
            ),
            child: _RegisterRoleCard(
              role: role,
              selected: selectedRole == role,
              onTap: () => onChanged(role),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _RegisterRoleCard extends StatelessWidget {
  const _RegisterRoleCard({
    required this.role,
    required this.selected,
    required this.onTap,
  });

  final AppRole role;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: ValueKey('register_role_${role.name}_button'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: selected ? role.color.withValues(alpha: 0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? role.color : const Color(0xFFEAEAEA),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(role.icon, color: role.color, size: 24),
            const SizedBox(height: 6),
            Text(
              role.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: selected ? role.color : const Color(0xFF333333),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CaptchaBox extends StatelessWidget {
  const _CaptchaBox({
    required this.bytes,
    required this.isLoading,
    required this.onRefresh,
  });

  final Uint8List? bytes;
  final bool isLoading;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: const ValueKey('refresh_register_captcha_button'),
      onTap: isLoading ? null : onRefresh,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 112,
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : bytes == null
            ? const Text('刷新')
            : Image.memory(bytes!, fit: BoxFit.cover, width: 112, height: 52),
      ),
    );
  }
}
