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
  final _accountController = TextEditingController(text: 'admin@example.com');
  final _passwordController = TextEditingController(text: 'MyPass123!');
  AppRole _selectedRole = AppRole.admin;

  @override
  void dispose() {
    _accountController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _selectRole(AppRole role) {
    setState(() {
      _selectedRole = role;
      _accountController.text = role == AppRole.admin
          ? 'admin@example.com'
          : 'courier@example.com';
      _passwordController.text = role == AppRole.admin
          ? 'MyPass123!'
          : '123456';
    });
  }

  Future<void> _handleStaffLogin(BuildContext context) async {
    final account = _accountController.text.trim();
    final password = _passwordController.text.trim();
    if (account.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请输入账号和密码')));
      return;
    }

    try {
      await context.read<AuthCubit>().loginAsStaff(
        _selectedRole,
        account,
        password,
      );
      if (context.mounted) {
        final userEmail = context.read<AuthCubit>().state.user?.email;
        final loginName = userEmail == null || userEmail.isEmpty
            ? _selectedRole.title
            : userEmail;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('登录成功: $loginName')));
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
              '当前 ${_selectedRole.title} 登录接口暂不可用：\n${e.toString()}\n\n是否使用演示模式进入？',
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
                  widget.onForceLogin(_selectedRole);
                },
                child: const Text('进入演示模式'),
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
                    '工作人员登录',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _StaffRoleSelector(
                      role: AppRole.admin,
                      selected: _selectedRole == AppRole.admin,
                      onTap: () => _selectRole(AppRole.admin),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StaffRoleSelector(
                      role: AppRole.courier,
                      selected: _selectedRole == AppRole.courier,
                      onTap: () => _selectRole(AppRole.courier),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              TextField(
                key: const ValueKey('staff_account_field'),
                controller: _accountController,
                decoration: InputDecoration(
                  hintText: '请输入${_selectedRole.title}账号',
                  prefixIcon: const Icon(Icons.badge_outlined, size: 20),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 14),
              TextField(
                key: const ValueKey('staff_password_field'),
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
                    key: const ValueKey('staff_login_button'),
                    onPressed: state.isLoading
                        ? null
                        : () => _handleStaffLogin(context),
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
                        : Text('登录${_selectedRole.title}'),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StaffRoleSelector extends StatelessWidget {
  const _StaffRoleSelector({
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
      key: ValueKey('staff_role_${role.name}_button'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? role.color.withValues(alpha: 0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? role.color : const Color(0xFFEAEAEA),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: role.color.withValues(alpha: selected ? 0.16 : 0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(role.icon, color: role.color, size: 24),
            ),
            const SizedBox(height: 10),
            Text(
              role.title,
              style: TextStyle(
                color: selected ? role.color : const Color(0xFF333333),
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              role.subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: selected ? role.color : Colors.grey[500],
                fontSize: 11,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: selected ? role.color : Colors.grey[400],
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
