import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../package/state/package_cubit.dart';
import '../package/state/package_state.dart';
import '../package/widgets/package_card.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key, required this.packages});

  final List<VillagePackage> packages;

  @override
  Widget build(BuildContext context) {
    final pendingInbound = packages
        .where((p) => p.status == PackageStatus.pendingInbound)
        .toList();
    final inStock = packages
        .where((p) => p.status == PackageStatus.inStock)
        .toList();
    final completed = packages
        .where((p) => p.status == PackageStatus.completed)
        .length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.inbox_rounded,
                label: '待入库',
                value: '${pendingInbound.length}',
                color: const Color(0xFF9E9E9E),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.outbox_rounded,
                label: '待出库',
                value: '${inStock.length}',
                color: const Color(0xFF1677FF),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.check_circle_rounded,
                label: '已完成',
                value: '$completed',
                color: const Color(0xFF4CAF50),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _SectionHeader(
          icon: Icons.inbox_rounded,
          title: '包裹入库',
          count: pendingInbound.length,
          color: const Color(0xFF9E9E9E),
        ),
        const SizedBox(height: 10),
        if (pendingInbound.isEmpty)
          const _EmptyPlaceholder(text: '暂无待入库包裹')
        else
          ...pendingInbound.map(
            (p) => PackageCard(
              key: ValueKey('inbound_${p.id}'),
              package: p,
              actionLabel: '确认入库',
              actionIcon: Icons.inventory_2_rounded,
              onPressed: () => context.read<PackageCubit>().changeStatus(
                p.id,
                PackageStatus.inStock,
                '站点管理员确认包裹入库',
              ),
            ),
          ),
        const SizedBox(height: 24),
        _SectionHeader(
          icon: Icons.outbox_rounded,
          title: '包裹出库',
          count: inStock.length,
          color: const Color(0xFF1677FF),
        ),
        const SizedBox(height: 10),
        if (inStock.isEmpty)
          const _EmptyPlaceholder(text: '暂无待出库包裹')
        else
          ...inStock.map(
            (p) => PackageCard(
              key: ValueKey('outbound_${p.id}'),
              package: p,
              actionLabel: '确认出库',
              actionIcon: Icons.outbox_rounded,
              onPressed: () => context.read<PackageCubit>().changeStatus(
                p.id,
                PackageStatus.taskPublished,
                '站点管理员确认包裹出库，等待骑手接单',
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
