import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../package/state/package_cubit.dart';
import '../package/state/package_state.dart';
import '../package/widgets/package_card.dart';

class VillagerDashboardScreen extends StatefulWidget {
  const VillagerDashboardScreen({super.key});

  @override
  State<VillagerDashboardScreen> createState() =>
      _VillagerDashboardScreenState();
}

class _VillagerDashboardScreenState extends State<VillagerDashboardScreen> {
  final _nameController = TextEditingController();
  final _receiverController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _receiverController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _submitPackage() {
    final name = _nameController.text.trim();
    final receiver = _receiverController.text.trim();
    final address = _addressController.text.trim();

    if (name.isEmpty || receiver.isEmpty || address.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请完整填写寄件信息，不能有空项')));
      return;
    }

    context.read<PackageCubit>().addPackage(name, receiver, address);
    _nameController.clear();
    _receiverController.clear();
    _addressController.clear();
  }

  void _showSendDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SendPackageSheet(
        nameController: _nameController,
        receiverController: _receiverController,
        addressController: _addressController,
        onSubmit: () {
          _submitPackage();
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<PackageCubit, PackageState>(
      builder: (context, state) {
        final myPackages = state.packages.toList();
        final pickupPackages = state.packages
            .where((p) => p.status == PackageStatus.readyForPickup)
            .toList();

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            _ServiceGrid(onSendTap: _showSendDialog),
            const SizedBox(height: 20),
            if (pickupPackages.isNotEmpty) ...[
              _SectionHeader(
                icon: Icons.notifications_active_rounded,
                title: '待取件提醒',
                count: pickupPackages.length,
                color: const Color(0xFFFF6B35),
              ),
              const SizedBox(height: 10),
              ...pickupPackages.map(
                (p) => PackageCard(
                  key: ValueKey('pickup_${p.id}'),
                  package: p,
                  actionLabel: '确认取件',
                  actionIcon: Icons.check_circle_rounded,
                  onPressed: () => context.read<PackageCubit>().changeStatus(
                    p.id,
                    PackageStatus.completed,
                    '村民完成取件',
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
            _SectionHeader(
              icon: Icons.inventory_2_rounded,
              title: '全部包裹',
              count: myPackages.length,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 10),
            if (myPackages.isEmpty)
              _EmptyPlaceholder()
            else
              ...myPackages.map(
                (p) => PackageCard(key: ValueKey('pkg_${p.id}'), package: p),
              ),
          ],
        );
      },
    );
  }
}

class _ServiceGrid extends StatelessWidget {
  const _ServiceGrid({required this.onSendTap});

  final VoidCallback onSendTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _ServiceItem(
            icon: Icons.outbox_rounded,
            label: '我要寄件',
            color: const Color(0xFFFF8C00),
            bgColor: const Color(0xFFFFF3E0),
            onTap: onSendTap,
          ),
          _ServiceItem(
            icon: Icons.markunread_mailbox_rounded,
            label: '我要取件',
            color: const Color(0xFF4CAF50),
            bgColor: const Color(0xFFE8F5E9),
            onTap: () {},
          ),
          _ServiceItem(
            icon: Icons.search_rounded,
            label: '查快递',
            color: const Color(0xFF1677FF),
            bgColor: const Color(0xFFE3F2FD),
            onTap: () {},
          ),
          _ServiceItem(
            icon: Icons.store_rounded,
            label: '附近驿站',
            color: const Color(0xFF9C27B0),
            bgColor: const Color(0xFFF3E5F5),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _ServiceItem extends StatelessWidget {
  const _ServiceItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF333333),
              ),
            ),
          ],
        ),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
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
      ),
    );
  }
}

class _EmptyPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.inbox_rounded, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text('暂无包裹', style: TextStyle(color: Colors.grey[400], fontSize: 14)),
        ],
      ),
    );
  }
}

class _SendPackageSheet extends StatelessWidget {
  const _SendPackageSheet({
    required this.nameController,
    required this.receiverController,
    required this.addressController,
    required this.onSubmit,
  });

  final TextEditingController nameController;
  final TextEditingController receiverController;
  final TextEditingController addressController;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(24, 20, 24, 20 + bottomInset),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            '我要寄件',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 20),
          TextField(
            key: const ValueKey('package_name_field'),
            controller: nameController,
            decoration: const InputDecoration(
              hintText: '包裹名称（如：农资工具箱）',
              prefixIcon: Icon(Icons.inventory_2_outlined, size: 20),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            key: const ValueKey('package_receiver_field'),
            controller: receiverController,
            decoration: const InputDecoration(
              hintText: '收件人姓名',
              prefixIcon: Icon(Icons.person_outline, size: 20),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            key: const ValueKey('package_address_field'),
            controller: addressController,
            decoration: const InputDecoration(
              hintText: '取送地址',
              prefixIcon: Icon(Icons.location_on_outlined, size: 20),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            key: const ValueKey('submit_package_button'),
            onPressed: onSubmit,
            child: const Text('确认寄件'),
          ),
        ],
      ),
    );
  }
}
