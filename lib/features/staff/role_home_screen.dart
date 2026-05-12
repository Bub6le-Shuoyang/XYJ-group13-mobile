import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/models/app_role.dart';
import '../auth/state/auth_cubit.dart';
import '../package/state/package_cubit.dart';
import '../package/state/package_state.dart';
import 'admin_dashboard_screen.dart';
import 'courier_dashboard_screen.dart';

class RoleHomeScreen extends StatelessWidget {
  const RoleHomeScreen({super.key, required this.role});

  final AppRole role;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(role.title),
        actions: [
          TextButton.icon(
            key: const ValueKey('role_logout_button'),
            onPressed: () => context.read<AuthCubit>().logout(),
            icon: const Icon(Icons.logout),
            label: const Text('退出'),
          ),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<PackageCubit, PackageState>(
          builder: (context, state) {
            return switch (role) {
              AppRole.villager => const Center(
                child: Text('Villager role should not be here'),
              ),
              AppRole.courier => CourierDashboardScreen(
                packages: state.packages,
              ),
              AppRole.admin => AdminDashboardScreen(packages: state.packages),
            };
          },
        ),
      ),
    );
  }
}
