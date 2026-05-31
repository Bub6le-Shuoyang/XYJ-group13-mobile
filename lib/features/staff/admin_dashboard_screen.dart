import 'package:flutter/material.dart';
import '../../services/admin_service.dart';
import '../package/state/package_state.dart';
import '../package/widgets/package_card.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _adminService = AdminService();
  bool _isLoading = true;
  String? _message;
  List<VillagePackage> _packages = const [];

  @override
  void initState() {
    super.initState();
    _loadPackages();
  }

  Future<void> _loadPackages() async {
    setState(() {
      _isLoading = true;
      _message = null;
    });
    final result = await _adminService.getPackages();
    if (!mounted) {
      return;
    }
    setState(() {
      if (result.isSuccess) {
        _packages = result.data ?? const [];
      } else {
        _packages = const [];
        _message = result.message;
      }
      _isLoading = false;
    });
  }

  Future<void> _inboundPackage(String packageId) async {
    final current = _packages.firstWhere((item) => item.id == packageId);
    final result = await _adminService.approvePackage(
      packageId,
      current.reward.toDouble(),
    );
    if (!mounted) {
      return;
    }
    if (!result.isSuccess || result.data != true) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result.message)));
      return;
    }
    await _loadPackages();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    final message = _message;
    if (message != null) {
      return _AdminErrorView(message: message, onRetry: _loadPackages);
    }
    final packages = _packages;
    final pendingInbound = packages
        .where((p) => p.status == PackageStatus.pendingInbound)
        .toList();
    final waitingCourier = packages
        .where((p) => p.status == PackageStatus.taskPublished)
        .toList();
    final completed = packages
        .where((p) => p.status == PackageStatus.completed)
        .length;

    return RefreshIndicator(
      onRefresh: _loadPackages,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.inbox_rounded,
                  label: '待审批',
                  value: '${pendingInbound.length}',
                  color: const Color(0xFF9E9E9E),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.outbox_rounded,
                  label: '待接单',
                  value: '${waitingCourier.length}',
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
            title: '包裹审批',
            count: pendingInbound.length,
            color: const Color(0xFF9E9E9E),
          ),
          const SizedBox(height: 10),
          if (pendingInbound.isEmpty)
            const _EmptyPlaceholder(text: '暂无待审批包裹')
          else
            ...pendingInbound.map(
              (p) => PackageCard(
                key: ValueKey('inbound_${p.id}'),
                package: p,
                actionLabel: '审批通过',
                actionIcon: Icons.verified_rounded,
                onPressed: () => _inboundPackage(p.id),
              ),
            ),
          const SizedBox(height: 24),
          _SectionHeader(
            icon: Icons.outbox_rounded,
            title: '待骑手接单',
            count: waitingCourier.length,
            color: const Color(0xFF1677FF),
          ),
          const SizedBox(height: 10),
          if (waitingCourier.isEmpty)
            const _EmptyPlaceholder(text: '暂无待骑手接单包裹')
          else
            ...waitingCourier.map(
              (p) => PackageCard(key: ValueKey('waiting_${p.id}'), package: p),
            ),
        ],
      ),
    );
  }
}

class _AdminErrorView extends StatelessWidget {
  const _AdminErrorView({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: Colors.grey,
            ),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('重新获取')),
          ],
        ),
      ),
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
