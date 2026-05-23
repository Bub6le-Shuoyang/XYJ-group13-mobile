import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../package/state/package_cubit.dart';
import '../package/state/package_state.dart';
import '../package/widgets/package_card.dart';

class CourierDashboardScreen extends StatefulWidget {
  const CourierDashboardScreen({super.key, required this.packages});

  final List<VillagePackage> packages;

  @override
  State<CourierDashboardScreen> createState() => _CourierDashboardScreenState();
}

class _CourierDashboardScreenState extends State<CourierDashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: IndexedStack(
            index: _currentIndex,
            children: [
              _CourierWorkPage(packages: widget.packages),
              _CourierProfilePage(packages: widget.packages),
            ],
          ),
        ),
        BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          selectedItemColor: const Color(0xFFFF8C00),
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.delivery_dining_rounded),
              label: '工作台',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: '我的',
            ),
          ],
        ),
      ],
    );
  }
}

class _CourierWorkPage extends StatelessWidget {
  const _CourierWorkPage({required this.packages});

  final List<VillagePackage> packages;

  Future<void> _showPickupCodeDialog(
    BuildContext context,
    VillagePackage package,
  ) async {
    final controller = TextEditingController();
    final pickupCode = await showDialog<String>(
      context: context,
      builder: (context) =>
          _CourierPickupCodeDialog(controller: controller, package: package),
    );
    controller.dispose();

    final normalizedCode = pickupCode?.trim().toUpperCase();
    if (normalizedCode == null || normalizedCode.isEmpty) {
      return;
    }
    if (!context.mounted) {
      return;
    }

    if (normalizedCode != package.pickupCode.toUpperCase()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('取件码不匹配，请和用户核对后重试')));
      return;
    }

    final matchedPackage = context.read<PackageCubit>().verifyPickupCode(
      normalizedCode,
    );
    if (matchedPackage == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('未找到该取件码，请核对后重试')));
      return;
    }

    if (matchedPackage.status != PackageStatus.assigned) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('该订单当前状态为「${matchedPackage.status.label}」，无法签收'),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${package.name} 已完成上门签收')));
  }

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
              actionLabel: '验证取件码',
              actionIcon: Icons.qr_code_scanner_rounded,
              onPressed: () => _showPickupCodeDialog(context, p),
            ),
          ),
      ],
    );
  }
}

class _CourierPickupCodeDialog extends StatelessWidget {
  const _CourierPickupCodeDialog({
    required this.controller,
    required this.package,
  });

  final TextEditingController controller;
  final VillagePackage package;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('上门签收验证'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '请让用户出示「我要取件」里的取件码，核验成功后订单自动完成。',
            style: TextStyle(color: Colors.grey[600], height: 1.4),
          ),
          const SizedBox(height: 14),
          Text(
            package.name,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          TextField(
            key: const ValueKey('courier_pickup_code_field'),
            controller: controller,
            autofocus: true,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              hintText: '请输入用户取件码',
              prefixIcon: Icon(Icons.qr_code_scanner_rounded),
            ),
            onSubmitted: (value) => Navigator.pop(context, value),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        FilledButton(
          key: const ValueKey('courier_verify_pickup_code_button'),
          onPressed: () => Navigator.pop(context, controller.text),
          child: const Text('验证并签收'),
        ),
      ],
    );
  }
}

class _CourierProfilePage extends StatelessWidget {
  const _CourierProfilePage({required this.packages});

  final List<VillagePackage> packages;

  @override
  Widget build(BuildContext context) {
    final completedCount = packages
        .where((p) => p.courier != null && p.status == PackageStatus.completed)
        .length;
    final deliveringCount = packages
        .where((p) => p.status == PackageStatus.assigned)
        .length;
    final todayIncome = deliveringCount * 8 + 36;
    final totalIncome = 2860 + completedCount * 12;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        _CourierProfileHeader(
          totalIncome: totalIncome,
          todayIncome: todayIncome,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.local_shipping_rounded,
                label: '配送中',
                value: '$deliveringCount',
                color: const Color(0xFF4CAF50),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.task_alt_rounded,
                label: '已完成',
                value: '${48 + completedCount}',
                color: const Color(0xFF1677FF),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _CourierInfoGroup(
          title: '基础信息',
          items: const [
            _CourierInfoItem(
              icon: Icons.badge_rounded,
              label: '配送员编号',
              value: 'COURIER-013',
              color: Color(0xFFFF8C00),
            ),
            _CourierInfoItem(
              icon: Icons.phone_rounded,
              label: '联系电话',
              value: '138****1313',
              color: Color(0xFF4CAF50),
            ),
            _CourierInfoItem(
              icon: Icons.store_rounded,
              label: '服务站点',
              value: '清河村中心驿站',
              color: Color(0xFF1677FF),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _CourierLevelCard(),
        const SizedBox(height: 16),
        _CourierInfoGroup(
          title: '收益明细',
          items: [
            _CourierInfoItem(
              icon: Icons.today_rounded,
              label: '今日收益',
              value: '¥$todayIncome',
              color: const Color(0xFFFF8C00),
            ),
            _CourierInfoItem(
              icon: Icons.account_balance_wallet_rounded,
              label: '累计收益',
              value: '¥$totalIncome',
              color: const Color(0xFF4CAF50),
            ),
            const _CourierInfoItem(
              icon: Icons.trending_up_rounded,
              label: '本月排名',
              value: '第 3 名',
              color: Color(0xFF9C27B0),
            ),
          ],
        ),
      ],
    );
  }
}

class _CourierProfileHeader extends StatelessWidget {
  const _CourierProfileHeader({
    required this.totalIncome,
    required this.todayIncome,
  });

  final int totalIncome;
  final int todayIncome;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF8C00), Color(0xFFFFB74D)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF8C00).withValues(alpha: 0.22),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 34,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.delivery_dining_rounded,
                  color: Color(0xFFFF8C00),
                  size: 36,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '张师傅',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '金牌配送员 · 已实名认证',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text(
                  '在线',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _IncomeTile(label: '今日收益', value: '¥$todayIncome'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _IncomeTile(label: '累计收益', value: '¥$totalIncome'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IncomeTile extends StatelessWidget {
  const _IncomeTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _CourierInfoGroup extends StatelessWidget {
  const _CourierInfoGroup({required this.title, required this.items});

  final String title;
  final List<_CourierInfoItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          ...items,
        ],
      ),
    );
  }
}

class _CourierInfoItem extends StatelessWidget {
  const _CourierInfoItem({
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF1A1A1A),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _CourierLevelCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  color: Color(0xFFFF8C00),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '配送等级',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      '金牌配送员 Lv.4',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const Text(
                '88%',
                style: TextStyle(
                  color: Color(0xFFFF8C00),
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: 0.88,
              minHeight: 8,
              backgroundColor: const Color(0xFFFFF3E0),
              valueColor: const AlwaysStoppedAnimation(Color(0xFFFF8C00)),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '再完成 6 单并保持准时率 95% 以上，可升级为钻石配送员。',
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
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
