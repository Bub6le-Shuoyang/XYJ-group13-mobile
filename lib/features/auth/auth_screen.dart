import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'state/auth_cubit.dart';
import 'widgets/user_login_view.dart';
import 'widgets/staff_login_view.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _showStaffLogin = false;

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
                          child: !_showStaffLogin
                              ? UserLoginView(
                                  key: const ValueKey('user_login'),
                                  onLogin: (role) => context
                                      .read<AuthCubit>()
                                      .forceLogin(role),
                                )
                              : StaffLoginView(
                                  key: const ValueKey('staff_login'),
                                  onForceLogin: (role) => context
                                      .read<AuthCubit>()
                                      .forceLogin(role),
                                ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextButton(
                        key: ValueKey(
                          _showStaffLogin
                              ? 'user_entrance_button'
                              : 'staff_entrance_button',
                        ),
                        onPressed: () =>
                            setState(() => _showStaffLogin = !_showStaffLogin),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _showStaffLogin
                                  ? Icons.arrow_back_ios
                                  : Icons.admin_panel_settings_outlined,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _showStaffLogin ? '返回用户登录' : '工作人员入口',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
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
}
