import 'package:flutter/material.dart';
import '../../core/models/app_role.dart';
import 'widgets/register_view.dart';
import 'widgets/user_login_view.dart';
import 'widgets/staff_login_view.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _showStaffLogin = false;
  bool _showRegister = false;
  String _userAccountDraft = '';
  String _staffAdminAccountDraft = '';
  String _staffCourierAccountDraft = '';
  AppRole _staffSelectedRole = AppRole.admin;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [colorScheme.primary, colorScheme.tertiary],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.primary.withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.local_shipping_rounded,
                          size: 44,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '乡驿家',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF2D2D2D),
                              letterSpacing: 2,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer.withValues(
                            alpha: 0.4,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '乡村快递协同平台',
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 36),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: _buildAuthForm(),
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (!_showRegister)
                        _EntranceSwitchButton(
                          showStaffLogin: _showStaffLogin,
                          onPressed: () => setState(
                            () => _showStaffLogin = !_showStaffLogin,
                          ),
                        ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthForm() {
    if (_showRegister) {
      return RegisterView(
        key: const ValueKey('register'),
        onBackToLogin: () => setState(() {
          _showRegister = false;
          _showStaffLogin = false;
        }),
      );
    }
    if (_showStaffLogin) {
      return StaffLoginView(
        key: const ValueKey('staff_login'),
        initialRole: _staffSelectedRole,
        initialAdminAccount: _staffAdminAccountDraft,
        initialCourierAccount: _staffCourierAccountDraft,
        onRoleChanged: (role) => _staffSelectedRole = role,
        onAdminAccountChanged: (value) => _staffAdminAccountDraft = value,
        onCourierAccountChanged: (value) => _staffCourierAccountDraft = value,
      );
    }
    return UserLoginView(
      key: const ValueKey('user_login'),
      initialAccount: _userAccountDraft,
      onAccountChanged: (value) => _userAccountDraft = value,
      onRegisterTap: () => setState(() {
        _showRegister = true;
        _showStaffLogin = false;
      }),
    );
  }
}

class _EntranceSwitchButton extends StatelessWidget {
  const _EntranceSwitchButton({
    required this.showStaffLogin,
    required this.onPressed,
  });

  final bool showStaffLogin;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      key: ValueKey(
        showStaffLogin ? 'user_entrance_button' : 'staff_entrance_button',
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            showStaffLogin
                ? Icons.arrow_back_ios
                : Icons.admin_panel_settings_outlined,
            size: 16,
            color: Colors.grey,
          ),
          const SizedBox(width: 6),
          Text(
            showStaffLogin ? '返回用户登录' : '工作人员入口',
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
