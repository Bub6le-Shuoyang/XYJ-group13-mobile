import 'package:flutter/material.dart';
import '../../core/models/business_models.dart';
import '../../services/courier_service.dart';
import '../package/state/package_state.dart';
import '../package/widgets/package_card.dart';

class CourierDashboardScreen extends StatefulWidget {
  const CourierDashboardScreen({super.key});

  @override
  State<CourierDashboardScreen> createState() => _CourierDashboardScreenState();
}

class _CourierDashboardScreenState extends State<CourierDashboardScreen> {
  final _courierService = CourierService();
  int _currentIndex = 0;
  bool _isLoading = true;
  String? _message;
  List<VillagePackage> _availableTasks = const [];
  List<VillagePackage> _myTasks = const [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() {
      _isLoading = true;
      _message = null;
    });
    final availableResult = await _courierService.getAvailableTasks(size: 50);
    final mineResult = await _courierService.getMyTasks(
      status: 'ALL',
      size: 50,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      if (availableResult.isSuccess && mineResult.isSuccess) {
        _availableTasks =
            availableResult.data?.records.map(_fromTaskVO).toList() ?? const [];
        _myTasks =
            mineResult.data?.records.map(_fromTaskVO).toList() ?? const [];
      } else {
        _availableTasks = const [];
        _myTasks = const [];
        _message = !availableResult.isSuccess
            ? availableResult.message
            : mineResult.message;
      }
      _isLoading = false;
    });
  }

  Future<void> _grabTask(String taskId) async {
    final result = await _courierService.grabTask(taskId);
    if (!mounted) {
      return;
    }
    if (!result.isSuccess || result.data != true) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result.message)));
      return;
    }
    await _loadTasks();
  }

  Future<void> _verifyPickupCode(String taskId, String pickupCode) async {
    final result = await _courierService.verifyPickupCode(taskId, pickupCode);
    if (!mounted) {
      return;
    }
    if (!result.isSuccess || result.data != true) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result.message)));
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('取件码核验成功，订单已完成')));
    await _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    final message = _message;
    if (message != null) {
      return _CourierErrorView(message: message, onRetry: _loadTasks);
    }
    return Column(
      children: [
        Expanded(
          child: IndexedStack(
            index: _currentIndex,
            children: [
              _CourierWorkPage(
                availableTasks: _availableTasks,
                myTasks: _myTasks,
                onRefresh: _loadTasks,
                onGrabTask: _grabTask,
                onVerifyPickupCode: _verifyPickupCode,
              ),
              _CourierProfilePage(packages: _myTasks),
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

  VillagePackage _fromTaskVO(TaskVO task) {
    final status = switch (task.status.toUpperCase()) {
      'AVAILABLE' || 'TASK_PUBLISHED' => PackageStatus.taskPublished,
      'ASSIGNED' || 'DELIVERING' => PackageStatus.assigned,
      'COMPLETED' => PackageStatus.completed,
      _ => PackageStatus.taskPublished,
    };
    return VillagePackage(
      id: task.taskId,
      pickupCode: task.pickupCodeMasked,
      name: task.packageName,
      sender: '驿站',
      receiver: '村民',
      address: task.deliverAddress,
      reward: task.rewardAmount.round(),
      status: status,
      timeline: [status.label],
      lat: 30.51,
      lng: 114.31,
    );
  }
}

class _CourierWorkPage extends StatelessWidget {
  const _CourierWorkPage({
    required this.availableTasks,
    required this.myTasks,
    required this.onRefresh,
    required this.onGrabTask,
    required this.onVerifyPickupCode,
  });

  final List<VillagePackage> availableTasks;
  final List<VillagePackage> myTasks;
  final Future<void> Function() onRefresh;
  final Future<void> Function(String taskId) onGrabTask;
  final Future<void> Function(String taskId, String pickupCode)
  onVerifyPickupCode;

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

    await onVerifyPickupCode(package.id, normalizedCode);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
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
                onPressed: () => onGrabTask(p.id),
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
      ),
    );
  }
}

class _CourierErrorView extends StatelessWidget {
  const _CourierErrorView({required this.message, required this.onRetry});

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

class _CourierProfilePage extends StatefulWidget {
  const _CourierProfilePage({required this.packages});

  final List<VillagePackage> packages;

  @override
  State<_CourierProfilePage> createState() => _CourierProfilePageState();
}

class _CourierProfilePageState extends State<_CourierProfilePage> {
  final _courierService = CourierService();
  late Future<_CourierData> _courierDataFuture;

  @override
  void initState() {
    super.initState();
    _courierDataFuture = _loadCourierData();
  }

  Future<_CourierData> _loadCourierData() async {
    final profileResult = await _courierService.getProfile();
    final earningsResult = await _courierService.getEarnings();
    return _CourierData(
      profile: profileResult.data!,
      earnings: earningsResult.data!,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_CourierData>(
      future: _courierDataFuture,
      builder: (context, snapshot) {
        final data = snapshot.data;
        if (data == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return _CourierProfileContent(
          packages: widget.packages,
          profile: data.profile,
          earnings: data.earnings,
        );
      },
    );
  }
}

class _CourierData {
  const _CourierData({required this.profile, required this.earnings});

  final CourierProfileVO profile;
  final EarningsVO earnings;
}

class _CourierProfileContent extends StatelessWidget {
  const _CourierProfileContent({
    required this.packages,
    required this.profile,
    required this.earnings,
  });

  final List<VillagePackage> packages;
  final CourierProfileVO profile;
  final EarningsVO earnings;

  @override
  Widget build(BuildContext context) {
    final completedCount = packages
        .where((p) => p.courier != null && p.status == PackageStatus.completed)
        .length;
    final deliveringCount = packages
        .where((p) => p.status == PackageStatus.assigned)
        .length;
    final todayIncome = (earnings.todayEarnings + deliveringCount * 8).round();
    final totalIncome = (earnings.totalEarnings + completedCount * 12).round();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        _CourierProfileHeader(
          profile: profile,
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
                value: '${earnings.completedOrders + completedCount}',
                color: const Color(0xFF1677FF),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _CourierInfoGroup(
          title: '基础信息',
          items: [
            _CourierInfoItem(
              icon: Icons.badge_rounded,
              label: '配送员编号',
              value: profile.courierNo,
              color: const Color(0xFFFF8C00),
            ),
            _CourierInfoItem(
              icon: Icons.phone_rounded,
              label: '联系电话',
              value: profile.phone,
              color: const Color(0xFF4CAF50),
            ),
            _CourierInfoItem(
              icon: Icons.store_rounded,
              label: '服务站点',
              value: profile.stationName,
              color: const Color(0xFF1677FF),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _CourierLevelCard(profile: profile),
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
            _CourierInfoItem(
              icon: Icons.trending_up_rounded,
              label: '本月排名',
              value: '第 ${profile.monthlyRank} 名',
              color: const Color(0xFF9C27B0),
            ),
          ],
        ),
      ],
    );
  }
}

class _CourierProfileHeader extends StatelessWidget {
  const _CourierProfileHeader({
    required this.profile,
    required this.totalIncome,
    required this.todayIncome,
  });

  final CourierProfileVO profile;
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${profile.levelName} · 已实名认证',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
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
  const _CourierLevelCard({required this.profile});

  final CourierProfileVO profile;

  @override
  Widget build(BuildContext context) {
    final progress = profile.levelProgress.clamp(0, 1).toDouble();
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '配送等级',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      profile.levelName,
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(
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
              value: progress,
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
