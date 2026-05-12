import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../news/news_screen.dart';
import '../profile/profile_screen.dart';
import 'villager_dashboard_screen.dart';
import '../auth/state/auth_cubit.dart';

class UserMainScreen extends StatefulWidget {
  const UserMainScreen({super.key});

  @override
  State<UserMainScreen> createState() => _UserMainScreenState();
}

class _UserMainScreenState extends State<UserMainScreen> {
  int _currentIndex = 1;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const NewsScreen(),
          Scaffold(
            appBar: AppBar(
              title: const Text(
                '乡驿家',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  letterSpacing: 1,
                ),
              ),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {},
                ),
              ],
            ),
            body: const VillagerDashboardScreen(),
          ),
          ProfileScreen(onLogout: () => context.read<AuthCubit>().logout()),
        ],
      ),
      floatingActionButton: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          key: const ValueKey('package_tab_fab'),
          onPressed: () => setState(() => _currentIndex = 1),
          elevation: 0,
          backgroundColor: _currentIndex == 1
              ? colorScheme.primary
              : Colors.white,
          foregroundColor: _currentIndex == 1
              ? Colors.white
              : colorScheme.primary,
          shape: const CircleBorder(),
          child: const Icon(Icons.inventory_2_rounded, size: 28),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 8,
          clipBehavior: Clip.antiAlias,
          color: Colors.white,
          elevation: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.article_outlined,
                activeIcon: Icons.article_rounded,
                label: '资讯',
                index: 0,
                currentIndex: _currentIndex,
                onTap: (i) => setState(() => _currentIndex = i),
              ),
              const SizedBox(width: 48),
              _NavItem(
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
                label: '我的',
                index: 2,
                currentIndex: _currentIndex,
                onTap: (i) => setState(() => _currentIndex = i),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final isSelected = currentIndex == index;
    final color = isSelected
        ? Theme.of(context).colorScheme.primary
        : const Color(0xFF999999);

    return InkWell(
      key: ValueKey('tab_item_${index}_button'),
      onTap: () => onTap(index),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isSelected ? activeIcon : icon, color: color, size: 24),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
