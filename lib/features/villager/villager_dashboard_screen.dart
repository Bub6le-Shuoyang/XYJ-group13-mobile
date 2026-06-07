import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/models/business_models.dart';
import '../../services/app_data_service.dart';
import '../../services/location_service.dart';
import '../package/state/package_cubit.dart';
import '../package/state/package_state.dart';
import '../package/widgets/package_card.dart';
import 'nearby_station_map_screen.dart';

class VillagerDashboardScreen extends StatefulWidget {
  const VillagerDashboardScreen({super.key});

  @override
  State<VillagerDashboardScreen> createState() =>
      _VillagerDashboardScreenState();
}

class _VillagerDashboardScreenState extends State<VillagerDashboardScreen> {
  final _scrollController = ScrollController();
  final _allPackagesKey = GlobalKey();
  String? _highlightedPackageId;
  int _highlightTick = 0;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showPickupCodeSheet() {
    final pickupPackages = context
        .read<PackageCubit>()
        .state
        .packages
        .where((package) => package.status == PackageStatus.assigned)
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PickupCodeSheet(packages: pickupPackages),
    );
  }

  Future<void> _showSearchPackageDialog() async {
    final controller = TextEditingController();
    final keyword = await showDialog<String>(
      context: context,
      builder: (context) => _PackageSearchDialog(controller: controller),
    );
    controller.dispose();

    final normalizedKeyword = keyword?.trim().toUpperCase();
    if (normalizedKeyword == null || normalizedKeyword.isEmpty) {
      return;
    }
    if (!mounted) {
      return;
    }

    VillagePackage? matchedPackage;
    for (final package in context.read<PackageCubit>().state.packages) {
      if (package.id.toUpperCase() == normalizedKeyword ||
          package.pickupCode.toUpperCase() == normalizedKeyword) {
        matchedPackage = package;
        break;
      }
    }

    if (matchedPackage == null) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('没有找到对应快递，请核对包裹号或取件码')));
      return;
    }

    final matchedPackageId = matchedPackage.id;
    await _scrollToAllPackages();
    if (!mounted) {
      return;
    }
    setState(() {
      _highlightedPackageId = matchedPackageId;
      _highlightTick++;
    });
  }

  Future<void> _scrollToAllPackages() async {
    final targetContext = _allPackagesKey.currentContext;
    if (targetContext != null) {
      await Scrollable.ensureVisible(
        targetContext,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
        alignment: 0.08,
      );
      return;
    }

    await _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
    );
  }

  void _openNearbyStations() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NearbyStationMapScreen()),
    );
  }

  Future<void> _showCreatePackageDialog() async {
    final result = await showDialog<_CreatePackageInput>(
      context: context,
      builder: (context) => const _CreatePackageDialog(),
    );
    if (result == null || !mounted) {
      return;
    }
    await context.read<PackageCubit>().createPackage(
      orderNo: result.orderNo,
      stationId: result.station.id,
      receiverName: result.receiverName,
      receiverPhone: result.receiverPhone,
      address: result.address,
      rewardAmount: result.rewardAmount,
      lat: result.lat,
      lng: result.lng,
    );
    if (!mounted) {
      return;
    }
    final message = context.read<PackageCubit>().state.message ?? '包裹信息已提交';
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<PackageCubit, PackageState>(
      builder: (context, state) {
        final myPackages = state.packages.toList();
        final pickupPackages = state.packages
            .where((p) => p.status == PackageStatus.assigned)
            .toList();

        return ListView(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            _ServiceGrid(
              onCreatePackageTap: _showCreatePackageDialog,
              onPickupCodeTap: _showPickupCodeSheet,
              onSearchTap: _showSearchPackageDialog,
              onStationTap: _openNearbyStations,
            ),
            const SizedBox(height: 20),
            if (pickupPackages.isNotEmpty) ...[
              _SectionHeader(
                icon: Icons.notifications_active_rounded,
                title: '待骑手上门',
                count: pickupPackages.length,
                color: const Color(0xFFFF6B35),
              ),
              const SizedBox(height: 10),
              ...pickupPackages.map(
                (p) => PackageCard(key: ValueKey('pickup_${p.id}'), package: p),
              ),
              const SizedBox(height: 8),
            ],
            KeyedSubtree(
              key: _allPackagesKey,
              child: _SectionHeader(
                icon: Icons.inventory_2_rounded,
                title: '全部包裹',
                count: myPackages.length,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 10),
            if (myPackages.isEmpty)
              _EmptyPlaceholder()
            else
              ...myPackages.map(
                (p) => _HighlightPackageCard(
                  key: ValueKey('pkg_${p.id}_$_highlightTick'),
                  package: p,
                  highlighted: p.id == _highlightedPackageId,
                  highlightTick: _highlightTick,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ServiceGrid extends StatelessWidget {
  const _ServiceGrid({
    required this.onCreatePackageTap,
    required this.onPickupCodeTap,
    required this.onSearchTap,
    required this.onStationTap,
  });

  final VoidCallback onCreatePackageTap;
  final VoidCallback onPickupCodeTap;
  final VoidCallback onSearchTap;
  final VoidCallback onStationTap;

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
      child: Wrap(
        alignment: WrapAlignment.spaceAround,
        runSpacing: 12,
        spacing: 16,
        children: [
          _ServiceItem(
            icon: Icons.add_box_rounded,
            label: '提交包裹',
            color: const Color(0xFFFF8C00),
            bgColor: const Color(0xFFFFF3E0),
            onTap: onCreatePackageTap,
          ),
          _ServiceItem(
            icon: Icons.qr_code_2_rounded,
            label: '我要取件',
            color: const Color(0xFF4CAF50),
            bgColor: const Color(0xFFE8F5E9),
            onTap: onPickupCodeTap,
          ),
          _ServiceItem(
            icon: Icons.search_rounded,
            label: '查快递',
            color: const Color(0xFF1677FF),
            bgColor: const Color(0xFFE3F2FD),
            onTap: onSearchTap,
          ),
          _ServiceItem(
            icon: Icons.store_rounded,
            label: '附近驿站',
            color: const Color(0xFF9C27B0),
            bgColor: const Color(0xFFF3E5F5),
            onTap: onStationTap,
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

class _PackageSearchDialog extends StatelessWidget {
  const _PackageSearchDialog({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('查快递'),
      content: TextField(
        key: const ValueKey('search_package_field'),
        controller: controller,
        autofocus: true,
        textCapitalization: TextCapitalization.characters,
        decoration: const InputDecoration(
          hintText: '输入包裹单号 / 取件码',
          prefixIcon: Icon(Icons.search_rounded),
        ),
        onSubmitted: (value) => Navigator.pop(context, value),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        FilledButton(
          key: const ValueKey('search_package_button'),
          onPressed: () => Navigator.pop(context, controller.text),
          child: const Text('定位快递'),
        ),
      ],
    );
  }
}

class _CreatePackageInput {
  const _CreatePackageInput({
    required this.orderNo,
    required this.station,
    required this.receiverName,
    required this.receiverPhone,
    required this.address,
    required this.rewardAmount,
    required this.lat,
    required this.lng,
  });

  final String orderNo;
  final StationVO station;
  final String receiverName;
  final String receiverPhone;
  final String address;
  final double rewardAmount;
  final double lat;
  final double lng;
}

class _CreatePackageDialog extends StatefulWidget {
  const _CreatePackageDialog();

  @override
  State<_CreatePackageDialog> createState() => _CreatePackageDialogState();
}

class _CreatePackageDialogState extends State<_CreatePackageDialog> {
  final _orderNoController = TextEditingController();
  final _receiverController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _rewardController = TextEditingController(text: '8');
  final _appDataService = AppDataService();
  final _locationService = const LocationService();
  List<StationVO> _stations = const [];
  StationVO? _selectedStation;
  bool _isLoadingStations = true;
  bool _isSubmitting = false;
  String? _stationMessage;

  @override
  void initState() {
    super.initState();
    _loadStations();
  }

  @override
  void dispose() {
    _orderNoController.dispose();
    _receiverController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _rewardController.dispose();
    super.dispose();
  }

  Future<void> _loadStations() async {
    final result = await _appDataService.getNearbyStations();
    if (!mounted) {
      return;
    }
    setState(() {
      if (result.isSuccess && result.data != null && result.data!.isNotEmpty) {
        _stations = result.data!;
        _selectedStation = result.data!.first;
        _stationMessage = null;
      } else {
        _stations = const [];
        _selectedStation = null;
        _stationMessage = result.message;
      }
      _isLoadingStations = false;
    });
  }

  Future<void> _submit() async {
    final reward = double.tryParse(_rewardController.text.trim()) ?? 8;
    final station = _selectedStation;
    final address = _addressController.text.trim();
    final input = _CreatePackageInput(
      orderNo: _orderNoController.text.trim(),
      station: station!,
      receiverName: _receiverController.text.trim(),
      receiverPhone: _phoneController.text.trim(),
      address: address,
      rewardAmount: reward,
      lat: station.lat,
      lng: station.lng,
    );
    if (input.orderNo.isEmpty ||
        input.receiverName.isEmpty ||
        input.address.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请填写订单号、收件人和配送地址')));
      return;
    }
    setState(() {
      _isSubmitting = true;
    });
    final resolvedLocation = await _locationService.geocodeAddress(address);
    if (!mounted) {
      return;
    }
    setState(() {
      _isSubmitting = false;
    });
    if (resolvedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('未解析到精确地址，已使用寄件驿站位置')),
      );
    }
    Navigator.pop(
      context,
      _CreatePackageInput(
        orderNo: input.orderNo,
        station: input.station,
        receiverName: input.receiverName,
        receiverPhone: input.receiverPhone,
        address: input.address,
        rewardAmount: input.rewardAmount,
        lat: resolvedLocation?.lat ?? input.lat,
        lng: resolvedLocation?.lng ?? input.lng,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('提交包裹信息'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _orderNoController,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(labelText: '订单号'),
            ),
            const SizedBox(height: 10),
            _StationSelector(
              isLoading: _isLoadingStations,
              message: _stationMessage,
              stations: _stations,
              selectedStation: _selectedStation,
              onChanged: (station) {
                setState(() {
                  _selectedStation = station;
                });
              },
              onRetry: _loadStations,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _receiverController,
              decoration: const InputDecoration(labelText: '收件人'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: '联系电话'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _addressController,
              maxLines: 2,
              decoration: const InputDecoration(labelText: '配送地址'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _rewardController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: '配送奖励'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: _selectedStation == null || _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('提交审批'),
        ),
      ],
    );
  }
}

class _StationSelector extends StatelessWidget {
  const _StationSelector({
    required this.isLoading,
    required this.message,
    required this.stations,
    required this.selectedStation,
    required this.onChanged,
    required this.onRetry,
  });

  final bool isLoading;
  final String? message;
  final List<StationVO> stations;
  final StationVO? selectedStation;
  final ValueChanged<StationVO?> onChanged;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const LinearProgressIndicator(minHeight: 2);
    }
    if (stations.isEmpty) {
      return InputDecorator(
        decoration: const InputDecoration(labelText: '寄件驿站'),
        child: Row(
          children: [
            Expanded(child: Text(message ?? '暂无可用驿站')),
            TextButton(onPressed: onRetry, child: const Text('重试')),
          ],
        ),
      );
    }
    return DropdownButtonFormField<StationVO>(
      initialValue: selectedStation,
      decoration: const InputDecoration(labelText: '寄件驿站'),
      items: stations
          .map(
            (station) => DropdownMenuItem<StationVO>(
              value: station,
              child: Text(station.name, overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}

class _HighlightPackageCard extends StatelessWidget {
  const _HighlightPackageCard({
    super.key,
    required this.package,
    required this.highlighted,
    required this.highlightTick,
  });

  final VillagePackage package;
  final bool highlighted;
  final int highlightTick;

  @override
  Widget build(BuildContext context) {
    if (!highlighted) {
      return PackageCard(package: package);
    }

    return TweenAnimationBuilder<double>(
      key: ValueKey('highlight_${package.id}_$highlightTick'),
      tween: Tween(begin: 1.08, end: 1),
      duration: const Duration(milliseconds: 520),
      curve: Curves.elasticOut,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1677FF).withValues(alpha: 0.18),
                  blurRadius: 20,
                  spreadRadius: 1,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: child,
          ),
        );
      },
      child: PackageCard(package: package),
    );
  }
}

class _PickupCodeSheet extends StatelessWidget {
  const _PickupCodeSheet({required this.packages});

  final List<VillagePackage> packages;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.78,
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomPadding),
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
          const SizedBox(height: 18),
          const Text(
            '我的取件码',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            '骑手送货上门时出示取件码，骑手核验后会自动完成签收。',
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
          const SizedBox(height: 16),
          if (packages.isEmpty)
            const _PickupCodeEmpty()
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: packages.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) => _PickupCodeCard(
                  key: ValueKey('pickup_code_card_${packages[index].id}'),
                  package: packages[index],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PickupCodeCard extends StatelessWidget {
  const _PickupCodeCard({super.key, required this.package});

  final VillagePackage package;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F5F0),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEDE7DD)),
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
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.markunread_mailbox_rounded,
                  color: Color(0xFF4CAF50),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      package.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      package.address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE8F5E9)),
                  ),
                  child: QrImageView(
                    data: package.pickupCode,
                    version: QrVersions.auto,
                    size: 132,
                    gapless: false,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: Color(0xFF1B5E20),
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: Color(0xFF1B5E20),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '扫码或输入取件码',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  package.pickupCode,
                  style: const TextStyle(
                    color: Color(0xFF1B5E20),
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PickupCodeEmpty extends StatelessWidget {
  const _PickupCodeEmpty();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F5F0),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(Icons.qr_code_2_rounded, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(
            '暂无可出示的取件码',
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
          const SizedBox(height: 6),
          Text(
            '骑手接单并出库后，这里会显示取件码。',
            style: TextStyle(color: Colors.grey[400], fontSize: 12),
          ),
        ],
      ),
    );
  }
}
