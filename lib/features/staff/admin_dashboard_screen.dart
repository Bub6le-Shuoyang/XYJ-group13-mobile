import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../package/state/package_cubit.dart';
import '../package/state/package_state.dart';
import '../package/widgets/package_card.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key, required this.packages});

  final List<VillagePackage> packages;

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _orderCodeController = TextEditingController();

  @override
  void dispose() {
    _orderCodeController.dispose();
    super.dispose();
  }

  void _verifyInboundOrder() {
    final orderCode = _orderCodeController.text.trim();
    if (orderCode.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请输入村民提供的订单号')));
      return;
    }

    final matchedPackage = context.read<PackageCubit>().verifyInboundOrder(
      orderCode,
    );
    if (matchedPackage == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('未找到该订单号，请核对后重试')));
      return;
    }

    if (matchedPackage.status != PackageStatus.pendingInbound) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('该订单当前状态为「${matchedPackage.status.label}」，无需重复入库'),
        ),
      );
      return;
    }

    _orderCodeController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('订单 ${matchedPackage.orderCode} 核验成功，已完成入库')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pendingInbound = widget.packages
        .where((p) => p.status == PackageStatus.pendingInbound)
        .toList();
    final inStock = widget.packages
        .where((p) => p.status == PackageStatus.inStock)
        .toList();
    final completed = widget.packages
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
        _OrderVerifyCard(
          controller: _orderCodeController,
          onVerify: _verifyInboundOrder,
          title: '寄件订单号验证',
          description: '输入村民寄件时生成的订单号，核验后自动改为已入库',
          hintText: '请输入订单号，如 XYJ25004',
          icon: Icons.verified_rounded,
          color: const Color(0xFF1677FF),
          fieldKey: const ValueKey('verify_order_code_field'),
          buttonKey: const ValueKey('verify_order_code_button'),
          buttonLabel: '验证并入库',
        ),
        const SizedBox(height: 24),
        _SectionHeader(
          icon: Icons.inbox_rounded,
          title: '待核验订单',
          count: pendingInbound.length,
          color: const Color(0xFF9E9E9E),
        ),
        const SizedBox(height: 10),
        if (pendingInbound.isEmpty)
          _EmptyPlaceholder(text: '暂无待入库包裹')
        else
          ...pendingInbound.map(
            (p) => PackageCard(
              key: ValueKey('inbound_${p.id}'),
              package: p,
              actionLabel: '用此订单号核验',
              actionIcon: Icons.confirmation_number_rounded,
              onPressed: () {
                _orderCodeController.text = p.orderCode;
                _verifyInboundOrder();
              },
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
          _EmptyPlaceholder(text: '暂无待出库包裹')
        else
          ...inStock.map(
            (p) => PackageCard(
              key: ValueKey('outbound_${p.id}'),
              package: p,
              actionLabel: '确认出库',
              actionIcon: Icons.outbox_rounded,
              onPressed: () => context.read<PackageCubit>().changeStatus(
                p.id,
                PackageStatus.assigned,
                '站点管理员确认包裹出库，进入配送流程',
                courier: '站点配送员',
              ),
            ),
          ),
      ],
    );
  }
}

class _OrderVerifyCard extends StatelessWidget {
  const _OrderVerifyCard({
    required this.controller,
    required this.onVerify,
    required this.title,
    required this.description,
    required this.hintText,
    required this.icon,
    required this.color,
    required this.fieldKey,
    required this.buttonKey,
    required this.buttonLabel,
  });

  final TextEditingController controller;
  final VoidCallback onVerify;
  final String title;
  final String description;
  final String hintText;
  final IconData icon;
  final Color color;
  final ValueKey<String> fieldKey;
  final ValueKey<String> buttonKey;
  final String buttonLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
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
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            key: fieldKey,
            controller: controller,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              hintText: hintText,
              prefixIcon: Icon(icon),
            ),
            onSubmitted: (_) => onVerify(),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            key: buttonKey,
            onPressed: onVerify,
            style: FilledButton.styleFrom(backgroundColor: color),
            icon: const Icon(Icons.fact_check_rounded),
            label: Text(buttonLabel),
          ),
        ],
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
