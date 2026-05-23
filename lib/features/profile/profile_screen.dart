import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/models/business_models.dart';
import '../../services/app_data_service.dart';
import '../package/state/package_cubit.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.onLogout});

  final VoidCallback onLogout;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _appDataService = AppDataService();
  static const _backgrounds = [
    'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=900&q=80',
    'https://images.unsplash.com/photo-1473773508845-188df298d2d1?auto=format&fit=crop&w=900&q=80',
    'https://images.unsplash.com/photo-1499529112087-3cb3b73cec95?auto=format&fit=crop&w=900&q=80',
  ];

  String _backgroundUrl = _backgrounds.first;
  double _panelTop = 250;
  int _points = 1250;
  int _couponCount = 3;
  final List<String> _addresses = ['清河村 3 组 18 号', '清河村村委会旁 20 米'];
  final List<String> _redeemedItems = [];
  List<String> _orderSummaries = const [];
  List<String> _pendingSummaries = const [];
  List<_MallItem> _mallItems = _PointsMallScreen.defaultItems;
  String _nickname = '村民张三';
  String _avatarUrl = 'https://api.dicebear.com/7.x/avataaars/png?seed=Felix';
  String _memberLevel = '金牌村民';
  int _monthlySignedCount = 8;
  double _balance = 0;

  static const _coverTop = 190.0;
  static const _revealTop = 360.0;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final packages = context.read<PackageCubit>().state.packages;
    final result = await _appDataService.getUserProfile(packages);
    final profile = result.data;
    if (!mounted || profile == null) {
      return;
    }
    setState(() {
      _points = profile.points;
      _couponCount = profile.couponCount;
      _balance = profile.balance;
      _nickname = profile.nickname;
      _avatarUrl = profile.avatarUrl;
      _memberLevel = profile.memberLevel;
      _monthlySignedCount = profile.monthlySignedCount;
      _orderSummaries = profile.orderSummaries;
      _pendingSummaries = profile.pendingSummaries;
      _mallItems = profile.mallItems.map(_MallItem.fromVO).toList();
      if (profile.addresses.isNotEmpty) {
        _addresses
          ..clear()
          ..addAll(profile.addresses);
      }
      if (profile.backgroundUrls.isNotEmpty) {
        _backgroundUrl = profile.backgroundUrls.first;
      }
    });
  }

  void _openSimpleListPage({
    required String title,
    required IconData icon,
    required Color color,
    required List<String> items,
    String? emptyText,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _ProfileListScreen(
          title: title,
          icon: icon,
          color: color,
          items: items,
          emptyText: emptyText,
        ),
      ),
    );
  }

  void _openAddressPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _AddressManagementScreen(
          addresses: _addresses,
          onAddAddress: (address) {
            _appDataService.addAddress(address);
            setState(() => _addresses.add(address));
          },
        ),
      ),
    );
  }

  void _openMallPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _PointsMallScreen(
          points: _points,
          items: _mallItems,
          onRedeem: (item) {
            if (_points < item.points) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('积分不足，暂时无法兑换')));
              return false;
            }

            _appDataService.redeemMallItem(item.id);
            setState(() {
              _points -= item.points;
              _redeemedItems.insert(0, item.name);
              if (item.type == _MallItemType.coupon) {
                _couponCount++;
              }
            });
            return true;
          },
        ),
      ),
    );
  }

  void _selectBackground() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '选择个人主页背景',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 104,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _backgrounds.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final url = _backgrounds[index];
                  final selected = url == _backgroundUrl;
                  return InkWell(
                    key: ValueKey('profile_background_option_$index'),
                    onTap: () {
                      setState(() => _backgroundUrl = url);
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            url,
                            width: 144,
                            height: 104,
                            fit: BoxFit.cover,
                          ),
                        ),
                        if (selected)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.check_circle_rounded,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: 420,
            child: GestureDetector(
              key: const ValueKey('profile_background_button'),
              onTap: _selectBackground,
              child: Container(
                padding: EdgeInsets.only(top: topPadding + 16, bottom: 40),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(_backgroundUrl),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withValues(alpha: 0.28),
                      BlendMode.darken,
                    ),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      colorScheme.primary,
                      colorScheme.primary.withValues(alpha: 0.85),
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Spacer(),
                        Container(
                          margin: const EdgeInsets.only(right: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.image_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                              SizedBox(width: 4),
                              Text(
                                '换背景',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          key: const ValueKey('logout_button'),
                          icon: const Icon(
                            Icons.settings_outlined,
                            color: Colors.white,
                          ),
                          onPressed: widget.onLogout,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        backgroundImage: NetworkImage(_avatarUrl),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _nickname,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.stars_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _memberLevel,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            left: 0,
            right: 0,
            top: _panelTop,
            bottom: 0,
            child: GestureDetector(
              key: const ValueKey('profile_content_panel'),
              behavior: HitTestBehavior.translucent,
              onVerticalDragUpdate: (details) {
                setState(() {
                  _panelTop = (_panelTop - details.delta.dy).clamp(
                    _coverTop,
                    _revealTop,
                  );
                });
              },
              onVerticalDragEnd: (_) {
                final target = _panelTop > (_coverTop + _revealTop) / 2
                    ? _revealTop
                    : _coverTop;
                setState(() => _panelTop = target);
              },
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 24,
                          offset: const Offset(0, -8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        Container(
                          width: 42,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          16,
                          0,
                          16,
                          24 + MediaQuery.of(context).padding.bottom,
                        ),
                        child: Column(
                          children: [
                            _ProfileStatsCard(
                              points: _points,
                              couponCount: _couponCount,
                              balance: _balance,
                              onPointsTap: _openMallPage,
                              onCouponsTap: () => _openSimpleListPage(
                                title: '我的优惠券',
                                icon: Icons.card_giftcard_rounded,
                                color: const Color(0xFFE53935),
                                items: List.generate(
                                  _couponCount,
                                  (index) => '乡驿家上门配送优惠券 #${index + 1}',
                                ),
                                emptyText: '暂无优惠券，去积分商城兑换一张吧',
                              ),
                              onWalletTap: () => _openSimpleListPage(
                                title: '我的零钱',
                                icon: Icons.account_balance_wallet_rounded,
                                color: const Color(0xFF4CAF50),
                                items: [
                                  '当前余额 ¥${_balance.toStringAsFixed(2)}',
                                  '最近暂无零钱流水',
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            _MenuGroup(
                              title: '我的订单',
                              items: [
                                _MenuItem(
                                  icon: Icons.call_received_rounded,
                                  label: '收件订单',
                                  color: const Color(0xFF4CAF50),
                                  onTap: () => _openSimpleListPage(
                                    title: '收件订单',
                                    icon: Icons.call_received_rounded,
                                    color: const Color(0xFF4CAF50),
                                    items: _orderSummaries,
                                  ),
                                ),
                                _MenuItem(
                                  icon: Icons.pending_actions_rounded,
                                  label: '待处理',
                                  color: const Color(0xFFFF6B35),
                                  badge: '2',
                                  onTap: () => _openSimpleListPage(
                                    title: '待处理',
                                    icon: Icons.pending_actions_rounded,
                                    color: const Color(0xFFFF6B35),
                                    items: _pendingSummaries,
                                  ),
                                ),
                                _MenuItem(
                                  icon: Icons.replay_rounded,
                                  label: '退换货',
                                  color: const Color(0xFF9C27B0),
                                  onTap: () => _openSimpleListPage(
                                    title: '退换货',
                                    icon: Icons.replay_rounded,
                                    color: const Color(0xFF9C27B0),
                                    items: ['暂无退换货申请', '如需退换货可联系驿站客服协助处理'],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _MenuGroup(
                              title: '常用功能',
                              items: [
                                _MenuItem(
                                  icon: Icons.location_on_rounded,
                                  label: '地址管理',
                                  color: const Color(0xFF1677FF),
                                  onTap: _openAddressPage,
                                ),
                                _MenuItem(
                                  icon: Icons.support_agent_rounded,
                                  label: '联系客服',
                                  color: const Color(0xFF00BCD4),
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const _CustomerServiceScreen(),
                                    ),
                                  ),
                                ),
                                _MenuItem(
                                  icon: Icons.help_outline_rounded,
                                  label: '帮助中心',
                                  color: const Color(0xFF607D8B),
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const _HelpCenterScreen(),
                                    ),
                                  ),
                                ),
                                _MenuItem(
                                  icon: Icons.info_outline_rounded,
                                  label: '关于我们',
                                  color: const Color(0xFF795548),
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const _AboutUsScreen(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _MenuGroup(
                              title: '会员服务',
                              items: [
                                _MenuItem(
                                  icon: Icons.storefront_rounded,
                                  label: '积分商城',
                                  color: const Color(0xFFFF8C00),
                                  badge: '兑',
                                  onTap: _openMallPage,
                                ),
                                _MenuItem(
                                  icon: Icons.history_rounded,
                                  label: '兑换记录',
                                  color: const Color(0xFF1677FF),
                                  onTap: () => _openSimpleListPage(
                                    title: '兑换记录',
                                    icon: Icons.history_rounded,
                                    color: const Color(0xFF1677FF),
                                    items: _redeemedItems.isEmpty
                                        ? const ['暂无兑换记录']
                                        : _redeemedItems,
                                  ),
                                ),
                                _MenuItem(
                                  icon: Icons.workspace_premium_rounded,
                                  label: '会员等级',
                                  color: const Color(0xFFFFB300),
                                  onTap: () => _openSimpleListPage(
                                    title: '会员等级',
                                    icon: Icons.workspace_premium_rounded,
                                    color: const Color(0xFFFFB300),
                                    items: [
                                      '当前等级：$_memberLevel',
                                      '本月完成 $_monthlySignedCount 次收件签收，再完成 2 次可升级为钻石村民',
                                    ],
                                  ),
                                ),
                                _MenuItem(
                                  icon: Icons.receipt_long_rounded,
                                  label: '积分明细',
                                  color: const Color(0xFF4CAF50),
                                  onTap: () => _openSimpleListPage(
                                    title: '积分明细',
                                    icon: Icons.receipt_long_rounded,
                                    color: const Color(0xFF4CAF50),
                                    items: [
                                      '当前积分 $_points',
                                      '取件奖励 +20',
                                      '评价奖励 +10',
                                      if (_redeemedItems.isNotEmpty)
                                        '最近兑换 ${_redeemedItems.first}',
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileStatsCard extends StatelessWidget {
  const _ProfileStatsCard({
    required this.points,
    required this.couponCount,
    required this.balance,
    required this.onPointsTap,
    required this.onCouponsTap,
    required this.onWalletTap,
  });

  final int points;
  final int couponCount;
  final double balance;
  final VoidCallback onPointsTap;
  final VoidCallback onCouponsTap;
  final VoidCallback onWalletTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            icon: Icons.stars_rounded,
            value: '$points',
            label: '我的积分',
            color: const Color(0xFFFF8C00),
            onTap: onPointsTap,
          ),
          _DividerLine(),
          _StatItem(
            icon: Icons.card_giftcard_rounded,
            value: '$couponCount',
            label: '优惠券',
            color: const Color(0xFFE53935),
            onTap: onCouponsTap,
          ),
          _DividerLine(),
          _StatItem(
            icon: Icons.account_balance_wallet_rounded,
            value: '¥${balance.toStringAsFixed(2)}',
            label: '零钱',
            color: const Color(0xFF4CAF50),
            onTap: onWalletTap,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}

class _DividerLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 28, color: Colors.grey[200]);
  }
}

class _MenuGroup extends StatelessWidget {
  const _MenuGroup({required this.title, required this.items});

  final String title;
  final List<_MenuItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: items,
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.badge,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                if (badge != null)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE53935),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        badge!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Color(0xFF555555)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileListScreen extends StatelessWidget {
  const _ProfileListScreen({
    required this.title,
    required this.icon,
    required this.color,
    required this.items,
    this.emptyText,
  });

  final String title;
  final IconData icon;
  final Color color;
  final List<String> items;
  final String? emptyText;

  @override
  Widget build(BuildContext context) {
    final displayItems = items.isEmpty ? [emptyText ?? '暂无内容'] : items;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: displayItems.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    displayItems[index],
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AddressManagementScreen extends StatefulWidget {
  const _AddressManagementScreen({
    required this.addresses,
    required this.onAddAddress,
  });

  final List<String> addresses;
  final ValueChanged<String> onAddAddress;

  @override
  State<_AddressManagementScreen> createState() =>
      _AddressManagementScreenState();
}

class _AddressManagementScreenState extends State<_AddressManagementScreen> {
  late final List<String> _addresses = [...widget.addresses];

  void _showAddAddressDialog() {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('新增地址'),
        content: TextField(
          key: const ValueKey('profile_address_field'),
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: '请输入常用地址',
            prefixIcon: Icon(Icons.location_on_outlined),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            key: const ValueKey('add_profile_address_button'),
            onPressed: () {
              final address = controller.text.trim();
              if (address.isEmpty) {
                return;
              }
              setState(() => _addresses.add(address));
              widget.onAddAddress(address);
              Navigator.pop(context);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    ).whenComplete(controller.dispose);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('地址管理')),
      floatingActionButton: FloatingActionButton.extended(
        key: const ValueKey('add_address_fab'),
        onPressed: _showAddAddressDialog,
        icon: const Icon(Icons.add_location_alt_rounded),
        label: const Text('新增地址'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _addresses.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) =>
            _AddressCard(address: _addresses[index], isDefault: index == 0),
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({required this.address, required this.isDefault});

  final String address;
  final bool isDefault;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Icon(Icons.home_rounded, color: Color(0xFF1677FF)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  address,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isDefault ? '默认地址' : '常用地址',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ),
          if (isDefault)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '默认',
                style: TextStyle(color: Color(0xFF1677FF), fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}

class _CustomerServiceScreen extends StatelessWidget {
  const _CustomerServiceScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('联系客服')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ContactCard(
            icon: Icons.phone_rounded,
            title: '驿站热线',
            subtitle: '400-888-1313',
            color: const Color(0xFF00BCD4),
          ),
          const SizedBox(height: 12),
          _ContactCard(
            icon: Icons.chat_bubble_rounded,
            title: '在线客服',
            subtitle: '工作日 08:00-20:00，通常 2 分钟内回复',
            color: const Color(0xFFFF8C00),
          ),
          const SizedBox(height: 12),
          _ContactCard(
            icon: Icons.store_rounded,
            title: '站点客服',
            subtitle: '清河村中心驿站，村委会旁 20 米',
            color: const Color(0xFF4CAF50),
          ),
        ],
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
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
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HelpCenterScreen extends StatelessWidget {
  const _HelpCenterScreen();

  static const _helps = [
    ('如何取件？', '点击首页“我要取件”展示取件码，骑手送货上门时核验取件码后自动完成签收。'),
    ('积分如何获得？', '完成取件、评价和参与驿站活动都可以获得积分。'),
    ('优惠券怎么用？', '下单配送服务或参与站点活动时可使用优惠券抵扣费用。'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('帮助中心')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: _helps
            .map(
              (help) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ExpansionTile(
                  title: Text(
                    help.$1,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Text(
                        help.$2,
                        style: TextStyle(color: Colors.grey[700], height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _AboutUsScreen extends StatelessWidget {
  const _AboutUsScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('关于我们')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF8C00), Color(0xFFFFB74D)],
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.local_shipping_rounded,
                    color: Colors.white,
                    size: 38,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '乡驿家',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                Text(
                  '连接村民、驿站和配送员的乡村快递协同平台',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600], height: 1.5),
                ),
                const SizedBox(height: 20),
                const Text('版本 1.0.0'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _MallItemType { coupon, goods }

class _MallItem {
  const _MallItem({
    required this.id,
    required this.name,
    required this.desc,
    required this.points,
    required this.icon,
    required this.color,
    required this.type,
  });

  factory _MallItem.fromVO(MallItemVO vo) {
    final isCoupon = vo.type == MallItemType.coupon;
    return _MallItem(
      id: vo.id,
      name: vo.name,
      desc: vo.desc,
      points: vo.points,
      icon: isCoupon ? Icons.card_giftcard_rounded : Icons.inventory_2_rounded,
      color: isCoupon ? const Color(0xFFE53935) : const Color(0xFF1677FF),
      type: isCoupon ? _MallItemType.coupon : _MallItemType.goods,
    );
  }

  final String id;
  final String name;
  final String desc;
  final int points;
  final IconData icon;
  final Color color;
  final _MallItemType type;
}

class _PointsMallScreen extends StatefulWidget {
  const _PointsMallScreen({
    required this.points,
    required this.items,
    required this.onRedeem,
  });

  final int points;
  final List<_MallItem> items;
  final bool Function(_MallItem item) onRedeem;

  static const defaultItems = [
    _MallItem(
      id: 'MALL-001',
      name: '上门配送立减券',
      desc: '适用于上门配送服务',
      points: 120,
      icon: Icons.card_giftcard_rounded,
      color: Color(0xFFE53935),
      type: _MallItemType.coupon,
    ),
    _MallItem(
      id: 'MALL-002',
      name: '配送优先券',
      desc: '可优先安排骑手上门配送',
      points: 220,
      icon: Icons.confirmation_number_rounded,
      color: Color(0xFFFF8C00),
      type: _MallItemType.coupon,
    ),
    _MallItem(
      id: 'MALL-003',
      name: '抽纸一提',
      desc: '到清河村中心驿站领取',
      points: 360,
      icon: Icons.inventory_2_rounded,
      color: Color(0xFF1677FF),
      type: _MallItemType.goods,
    ),
    _MallItem(
      id: 'MALL-004',
      name: '农家土鸡蛋 6 枚',
      desc: '每日限量，兑换后站点自提',
      points: 520,
      icon: Icons.egg_alt_rounded,
      color: Color(0xFF8D6E63),
      type: _MallItemType.goods,
    ),
  ];

  @override
  State<_PointsMallScreen> createState() => _PointsMallScreenState();
}

class _PointsMallScreenState extends State<_PointsMallScreen> {
  late int _points = widget.points;

  void _redeem(_MallItem item) {
    final success = widget.onRedeem(item);
    if (!success) {
      return;
    }

    setState(() => _points -= item.points);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('已成功兑换「${item.name}」')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('积分商城')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF8C00), Color(0xFFFFB74D)],
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              children: [
                const Icon(Icons.stars_rounded, color: Colors.white, size: 36),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('可用积分', style: TextStyle(color: Colors.white70)),
                    Text(
                      '$_points',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            '可兑换权益',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          ...widget.items.map(
            (item) => _MallItemCard(item: item, onRedeem: _redeem),
          ),
        ],
      ),
    );
  }
}

class _MallItemCard extends StatelessWidget {
  const _MallItemCard({required this.item, required this.onRedeem});

  final _MallItem item;
  final ValueChanged<_MallItem> onRedeem;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(item.icon, color: item.color, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    _MallTypeChip(type: item.type),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.desc,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      '${item.points} 积分',
                      style: const TextStyle(
                        color: Color(0xFFFF8C00),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    FilledButton(
                      key: ValueKey('redeem_${item.name}_button'),
                      onPressed: () => onRedeem(item),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(82, 38),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                      ),
                      child: const Text('兑换'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MallTypeChip extends StatelessWidget {
  const _MallTypeChip({required this.type});

  final _MallItemType type;

  @override
  Widget build(BuildContext context) {
    final isCoupon = type == _MallItemType.coupon;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: (isCoupon ? const Color(0xFFE53935) : const Color(0xFF1677FF))
            .withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isCoupon ? '优惠券' : '实物',
        style: TextStyle(
          color: isCoupon ? const Color(0xFFE53935) : const Color(0xFF1677FF),
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
