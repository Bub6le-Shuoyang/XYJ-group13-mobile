import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../package/state/package_cubit.dart';
import '../package/state/package_state.dart';
import '../package/widgets/package_card.dart';

class CourierDashboardScreen extends StatelessWidget {
  const CourierDashboardScreen({super.key, required this.packages});

  final List<VillagePackage> packages;

  @override
  Widget build(BuildContext context) {
    final availableTasks = packages
        .where((p) => p.status == PackageStatus.taskPublished)
        .toList();
    final myTasks = packages
        .where((p) => p.status == PackageStatus.assigned)
        .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.flash_on_rounded,
                label: '可抢任务',
                value: '${availableTasks.length}',
                color: const Color(0xFFFF8C00),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.local_shipping_rounded,
                label: '派送中',
                value: '${myTasks.length}',
                color: const Color(0xFF4CAF50),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _SectionHeader(
          icon: Icons.flash_on_rounded,
          title: '可抢任务',
          count: availableTasks.length,
          color: const Color(0xFFFF8C00),
        ),
        const SizedBox(height: 10),
        if (availableTasks.isEmpty)
          _EmptyPlaceholder(text: '暂无可抢任务')
        else
          ...availableTasks.map(
            (p) => PackageCard(
              key: ValueKey('grab_${p.id}'),
              package: p,
              actionLabel: '立即抢单',
              actionIcon: Icons.touch_app_rounded,
              onPressed: () => context.read<PackageCubit>().changeStatus(
                p.id,
                PackageStatus.assigned,
                '配送员抢单成功',
                courier: '当前配送员',
              ),
            ),
          ),
        const SizedBox(height: 24),
        _SectionHeader(
          icon: Icons.local_shipping_rounded,
          title: '我的派送',
          count: myTasks.length,
          color: const Color(0xFF4CAF50),
        ),
        const SizedBox(height: 10),
        if (myTasks.isEmpty)
          _EmptyPlaceholder(text: '暂无派送中任务')
        else
          ...myTasks.map(
            (p) => PackageCard(
              key: ValueKey('deliver_${p.id}'),
              package: p,
              actionLabel: '完成派送',
              actionIcon: Icons.task_alt_rounded,
              onPressed: () => context.read<PackageCubit>().changeStatus(
                p.id,
                PackageStatus.readyForPickup,
                '配送员完成派送，包裹到达取件点',
              ),
            ),
          ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 13)),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.count,
    required this.color,
  });

  final IconData icon;
  final String title;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyPlaceholder extends StatelessWidget {
  const _EmptyPlaceholder({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(color: Colors.grey[400], fontSize: 14),
        ),
      ),
    );
  }
}
