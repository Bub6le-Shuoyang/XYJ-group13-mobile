import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

enum AppRole {
  villager('村民用户', '寄件 / 取件', Icons.person_pin_circle, Colors.green),
  courier('配送员', '抢单 / 派送', Icons.delivery_dining, Colors.orange),
  admin('站点管理员', '入库 / 发单', Icons.store_mall_directory, Colors.blue);

  const AppRole(this.title, this.subtitle, this.icon, this.color);

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
}

enum PackageStatus {
  pendingInbound('待入库'),
  inStock('已入库'),
  taskPublished('待抢单'),
  assigned('派送中'),
  readyForPickup('待取件'),
  completed('已完成');

  const PackageStatus(this.label);

  final String label;
}

class VillagePackage {
  VillagePackage({
    required this.id,
    required this.name,
    required this.sender,
    required this.receiver,
    required this.address,
    required this.reward,
    required this.status,
    required this.timeline,
    this.courier,
  });

  final String id;
  final String name;
  final String sender;
  final String receiver;
  final String address;
  final int reward;
  final PackageStatus status;
  final List<String> timeline;
  final String? courier;

  VillagePackage copyWith({
    PackageStatus? status,
    List<String>? timeline,
    String? courier,
  }) {
    return VillagePackage(
      id: id,
      name: name,
      sender: sender,
      receiver: receiver,
      address: address,
      reward: reward,
      status: status ?? this.status,
      timeline: timeline ?? this.timeline,
      courier: courier ?? this.courier,
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  AppRole? _role;
  int _nextPackageNo = 4;
  List<VillagePackage> _packages = [
    VillagePackage(
      id: 'PKG-001',
      name: '农资工具箱',
      sender: '镇上仓库',
      receiver: '王大爷',
      address: '清河村 3 组 18 号',
      reward: 8,
      status: PackageStatus.taskPublished,
      timeline: const ['站点完成入库', '管理员发布配送任务'],
    ),
    VillagePackage(
      id: 'PKG-002',
      name: '生鲜包裹',
      sender: '李阿姨',
      receiver: '县城亲友',
      address: '村口驿站',
      reward: 10,
      status: PackageStatus.pendingInbound,
      timeline: const ['村民提交寄件申请'],
    ),
    VillagePackage(
      id: 'PKG-003',
      name: '药品快件',
      sender: '县医院',
      receiver: '赵奶奶',
      address: '清河村卫生室旁',
      reward: 12,
      status: PackageStatus.readyForPickup,
      timeline: const ['站点完成入库', '配送员送达站点', '等待村民取件'],
      courier: '张师傅',
    ),
  ];

  void _login(AppRole role) {
    setState(() => _role = role);
  }

  void _logout() {
    setState(() => _role = null);
  }

  void _addPackage(String name, String receiver, String address) {
    final packageNo = _nextPackageNo++;

    setState(() {
      _packages = [
        VillagePackage(
          id: 'PKG-${packageNo.toString().padLeft(3, '0')}',
          name: name,
          sender: '当前村民',
          receiver: receiver,
          address: address,
          reward: 9,
          status: PackageStatus.pendingInbound,
          timeline: const ['村民提交寄件申请'],
        ),
        ..._packages,
      ];
    });
  }

  void _changeStatus(
    String packageId,
    PackageStatus status,
    String timelineText, {
    String? courier,
  }) {
    setState(() {
      _packages = _packages.map((package) {
        if (package.id != packageId) {
          return package;
        }

        return package.copyWith(
          status: status,
          courier: courier,
          timeline: [...package.timeline, timelineText],
        );
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '乡村快递协同平台',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      home: _role == null
          ? LoginPage(onLogin: _login)
          : RoleHomePage(
              role: _role!,
              packages: _packages,
              onLogout: _logout,
              onAddPackage: _addPackage,
              onChangeStatus: _changeStatus,
            ),
    );
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key, required this.onLogin});

  final ValueChanged<AppRole> onLogin;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 24), // 调整间距，使其更美观
            Text(
              '乡村快递协同平台',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary, // 增加主色调强调
                  ),
            ),
            const SizedBox(height: 12), // 调整间距
            Text(
              '选择身份登录，体验村民寄取件、配送员抢单派送、站点管理员入库发单。',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),
            ...AppRole.values.map(
              (role) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _RoleLoginCard(role: role, onTap: () => onLogin(role)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleLoginCard extends StatelessWidget {
  const _RoleLoginCard({required this.role, required this.onTap});

  final AppRole role;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: role.color.withValues(alpha: 0.12),
                child: Icon(role.icon, color: role.color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      role.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(role.subtitle),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class RoleHomePage extends StatelessWidget {
  const RoleHomePage({
    super.key,
    required this.role,
    required this.packages,
    required this.onLogout,
    required this.onAddPackage,
    required this.onChangeStatus,
  });

  final AppRole role;
  final List<VillagePackage> packages;
  final VoidCallback onLogout;
  final void Function(String name, String receiver, String address)
  onAddPackage;
  final void Function(
    String packageId,
    PackageStatus status,
    String timelineText, {
    String? courier,
  })
  onChangeStatus;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(role.title),
        actions: [
          TextButton.icon(
            onPressed: onLogout,
            icon: const Icon(Icons.logout),
            label: const Text('退出'),
          ),
        ],
      ),
      body: SafeArea(
        child: switch (role) {
          AppRole.villager => VillagerDashboard(
            packages: packages,
            onAddPackage: onAddPackage,
            onPickup: (packageId) =>
                onChangeStatus(packageId, PackageStatus.completed, '村民完成取件'),
          ),
          AppRole.courier => CourierDashboard(
            packages: packages,
            onGrab: (packageId) => onChangeStatus(
              packageId,
              PackageStatus.assigned,
              '配送员抢单成功',
              courier: '当前配送员',
            ),
            onDeliver: (packageId) => onChangeStatus(
              packageId,
              PackageStatus.readyForPickup,
              '配送员完成派送，包裹到达取件点',
            ),
          ),
          AppRole.admin => AdminDashboard(
            packages: packages,
            onInbound: (packageId) =>
                onChangeStatus(packageId, PackageStatus.inStock, '站点管理员完成包裹入库'),
            onPublish: (packageId) => onChangeStatus(
              packageId,
              PackageStatus.taskPublished,
              '站点管理员发布配送任务',
            ),
          ),
        },
      ),
    );
  }
}

class VillagerDashboard extends StatefulWidget {
  const VillagerDashboard({
    super.key,
    required this.packages,
    required this.onAddPackage,
    required this.onPickup,
  });

  final List<VillagePackage> packages;
  final void Function(String name, String receiver, String address)
  onAddPackage;
  final ValueChanged<String> onPickup;

  @override
  State<VillagerDashboard> createState() => _VillagerDashboardState();
}

class _VillagerDashboardState extends State<VillagerDashboard> {
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请完整填写寄件信息，不能有空项')), // 补充了更清晰的提示信息
      );
      return;
    }

    widget.onAddPackage(name, receiver, address);
    _nameController.clear();
    _receiverController.clear();
    _addressController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final pickupPackages = widget.packages
        .where((package) => package.status == PackageStatus.readyForPickup)
        .toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _SectionTitle(
          icon: Icons.outbox,
          title: '我要寄件',
          subtitle: '提交寄件后，由站点管理员入库并发布配送任务。',
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: '包裹名称'),
                ),
                TextField(
                  controller: _receiverController,
                  decoration: const InputDecoration(labelText: '收件人'),
                ),
                TextField(
                  controller: _addressController,
                  decoration: const InputDecoration(labelText: '取送地址'),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _submitPackage,
                  icon: const Icon(Icons.send),
                  label: const Text('提交寄件'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        const _SectionTitle(
          icon: Icons.inventory_2,
          title: '待取件',
          subtitle: '配送员送达站点后，村民可确认取件。',
        ),
        const SizedBox(height: 12),
        if (pickupPackages.isEmpty)
          const _EmptyState(text: '暂无待取件包裹')
        else
          ...pickupPackages.map(
            (package) => PackageCard(
              key: ValueKey(package.id),
              package: package,
              actionLabel: '确认取件',
              actionIcon: Icons.check_circle,
              onPressed: () => widget.onPickup(package.id),
            ),
          ),
      ],
    );
  }
}

class CourierDashboard extends StatelessWidget {
  const CourierDashboard({
    super.key,
    required this.packages,
    required this.onGrab,
    required this.onDeliver,
  });

  final List<VillagePackage> packages;
  final ValueChanged<String> onGrab;
  final ValueChanged<String> onDeliver;

  @override
  Widget build(BuildContext context) {
    final availableTasks = packages
        .where((package) => package.status == PackageStatus.taskPublished)
        .toList();
    final myTasks = packages
        .where((package) => package.status == PackageStatus.assigned)
        .toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _SectionTitle(
          icon: Icons.flash_on,
          title: '可抢任务',
          subtitle: '站点管理员发布后，配送员可抢单。',
        ),
        const SizedBox(height: 12),
        if (availableTasks.isEmpty)
          const _EmptyState(text: '暂无可抢任务')
        else
          ...availableTasks.map(
            (package) => PackageCard(
              key: ValueKey(package.id),
              package: package,
              actionLabel: '抢单',
              actionIcon: Icons.front_hand,
              onPressed: () => onGrab(package.id),
            ),
          ),
        const SizedBox(height: 24),
        const _SectionTitle(
          icon: Icons.local_shipping,
          title: '我的派送',
          subtitle: '抢单后进入派送中，送达后更新为待取件。',
        ),
        const SizedBox(height: 12),
        if (myTasks.isEmpty)
          const _EmptyState(text: '暂无派送中任务')
        else
          ...myTasks.map(
            (package) => PackageCard(
              key: ValueKey(package.id),
              package: package,
              actionLabel: '完成派送',
              actionIcon: Icons.task_alt,
              onPressed: () => onDeliver(package.id),
            ),
          ),
      ],
    );
  }
}

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({
    super.key,
    required this.packages,
    required this.onInbound,
    required this.onPublish,
  });

  final List<VillagePackage> packages;
  final ValueChanged<String> onInbound;
  final ValueChanged<String> onPublish;

  @override
  Widget build(BuildContext context) {
    final pendingInbound = packages
        .where((package) => package.status == PackageStatus.pendingInbound)
        .toList();
    final inStock = packages
        .where((package) => package.status == PackageStatus.inStock)
        .toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _MetricCard(label: '待入库', value: pendingInbound.length),
            _MetricCard(label: '可发布', value: inStock.length),
            _MetricCard(
              label: '已完成',
              value: packages
                  .where((package) => package.status == PackageStatus.completed)
                  .length,
            ),
          ],
        ),
        const SizedBox(height: 24),
        const _SectionTitle(
          icon: Icons.warehouse,
          title: '包裹入库',
          subtitle: '村民寄件申请进入待入库，由站点管理员确认。',
        ),
        const SizedBox(height: 12),
        if (pendingInbound.isEmpty)
          const _EmptyState(text: '暂无待入库包裹')
        else
          ...pendingInbound.map(
            (package) => PackageCard(
              key: ValueKey(package.id),
              package: package,
              actionLabel: '确认入库',
              actionIcon: Icons.input,
              onPressed: () => onInbound(package.id),
            ),
          ),
        const SizedBox(height: 24),
        const _SectionTitle(
          icon: Icons.campaign,
          title: '任务发布',
          subtitle: '入库完成后发布配送任务，等待配送员抢单。',
        ),
        const SizedBox(height: 12),
        if (inStock.isEmpty)
          const _EmptyState(text: '暂无可发布任务')
        else
          ...inStock.map(
            (package) => PackageCard(
              key: ValueKey(package.id),
              package: package,
              actionLabel: '发布任务',
              actionIcon: Icons.publish,
              onPressed: () => onPublish(package.id),
            ),
          ),
      ],
    );
  }
}

class PackageCard extends StatelessWidget {
  const PackageCard({
    super.key,
    required this.package,
    this.actionLabel,
    this.actionIcon,
    this.onPressed,
  });

  final VillagePackage package;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${package.name} · ${package.id}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Chip(label: Text(package.status.label)),
              ],
            ),
            const SizedBox(height: 8),
            Text('寄件人：${package.sender}'),
            Text('收件人：${package.receiver}'),
            Text('地址：${package.address}'),
            Text('配送奖励：${package.reward} 元'),
            if (package.courier != null) Text('配送员：${package.courier}'),
            const SizedBox(height: 12),
            Text(
              '进度：${package.timeline.join(' > ')}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (actionLabel != null && onPressed != null) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: onPressed,
                  icon: Icon(actionIcon ?? Icons.play_arrow),
                  label: Text(actionLabel!),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 112,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                '$value',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(subtitle),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(text, textAlign: TextAlign.center),
    );
  }
}
