import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/app_role.dart';
import '../state/auth_cubit.dart';
import '../state/auth_state.dart';

class StaffLoginView extends StatefulWidget {
  const StaffLoginView({super.key, required this.onForceLogin});

  final ValueChanged<AppRole> onForceLogin;

  @override
  State<StaffLoginView> createState() => _StaffLoginViewState();
}

class _StaffLoginViewState extends State<StaffLoginView> {
  final _emailController = TextEditingController(text: 'admin@example.com');
  final _passwordController = TextEditingController(text: 'MyPass123!');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleAdminLogin(BuildContext context) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      await context.read<AuthCubit>().loginAsAdmin(email, password);
      if (context.mounted) {
        final user = context.read<AuthCubit>().state.user;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('登录成功: ${user?.email ?? ''}')));
      }
    } catch (e) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (dialogContext) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('网络请求失败'),
            content: Text(
              '接口调用失败 (这很正常，因为后端地址还没配)：\n${e.toString()}\n\n是否直接进入演示模式？',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('取消'),
              ),
              FilledButton(
                key: const ValueKey('force_login_button'),
                onPressed: () {
                  Navigator.pop(dialogContext);
                  widget.onForceLogin(AppRole.admin);
                },
                child: const Text('强制进入'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      color: const Color(0xFF1677FF),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    '管理员登录',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                key: const ValueKey('admin_email_field'),
                controller: _emailController,
                decoration: const InputDecoration(
                  hintText: '请输入管理员邮箱',
                  prefixIcon: Icon(Icons.email_outlined, size: 20),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 14),
              TextField(
                key: const ValueKey('admin_password_field'),
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: '请输入密码',
                  prefixIcon: Icon(Icons.lock_outline_rounded, size: 20),
                ),
              ),
              const SizedBox(height: 24),
              BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  return FilledButton(
                    key: const ValueKey('admin_login_button'),
                    onPressed: state.isLoading
                        ? null
                        : () => _handleAdminLogin(context),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF1677FF),
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
                        : const Text('登 录'),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _RoleLoginCard(
          role: AppRole.courier,
          onTap: () => widget.onForceLogin(AppRole.courier),
        ),
      ],
    );
  }
}

class _RoleLoginCard extends StatelessWidget {
  const _RoleLoginCard({required this.role, required this.onTap});

  final AppRole role;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
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
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: ValueKey('role_login_card_${role.name}'),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: role.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(role.icon, color: role.color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      role.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      role.subtitle,
                      style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
