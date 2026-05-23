import '../core/models/business_models.dart';
import '../features/package/state/package_state.dart';

class MockData {
  const MockData._();

  static const packages = [
    VillagePackage(
      id: 'PKG-001',
      pickupCode: 'QJ25001',
      name: '农资工具箱',
      sender: '镇上仓库',
      receiver: '王大爷',
      address: '清河村 3 组 18 号',
      reward: 8,
      status: PackageStatus.inStock,
      timeline: ['快递到达清河村中心驿站', '站点管理员确认包裹入库', '等待管理员安排骑手配送'],
      lat: 30.51,
      lng: 114.31,
    ),
    VillagePackage(
      id: 'PKG-002',
      pickupCode: 'QJ25002',
      name: '生鲜包裹',
      sender: '县城商超',
      receiver: '李阿姨',
      address: '清河村村口小卖部旁',
      reward: 10,
      status: PackageStatus.pendingInbound,
      timeline: ['县城商超已发出', '快递到站，等待管理员确认入库'],
      lat: 30.518,
      lng: 114.319,
    ),
    VillagePackage(
      id: 'PKG-003',
      pickupCode: 'QJ25003',
      name: '药品快件',
      sender: '县医院',
      receiver: '赵奶奶',
      address: '清河村卫生室旁',
      reward: 12,
      status: PackageStatus.assigned,
      timeline: ['县医院已发出', '站点完成入库', '站点管理员确认出库', '张师傅正在送货上门'],
      courier: '张师傅',
      lat: 30.503,
      lng: 114.302,
    ),
    VillagePackage(
      id: 'PKG-004',
      pickupCode: 'QJ25004',
      name: '助农直播物料',
      sender: '镇电商服务站',
      receiver: '村委会',
      address: '清河村村委会旁 20 米',
      reward: 9,
      status: PackageStatus.taskPublished,
      timeline: ['镇电商服务站已发出', '站点完成入库', '管理员发布配送任务，等待骑手接单'],
      lat: 30.509,
      lng: 114.312,
    ),
    VillagePackage(
      id: 'PKG-005',
      pickupCode: 'QJ25005',
      name: '老人慢病药品',
      sender: '县医院',
      receiver: '刘爷爷',
      address: '清河村 5 组 9 号',
      reward: 12,
      status: PackageStatus.completed,
      timeline: ['县医院已发出', '站点完成入库', '张师傅抢单成功', '骑手上门核验取件码，订单完成签收'],
      courier: '张师傅',
      lat: 30.506,
      lng: 114.306,
    ),
  ];

  static final stations = [
    StationVO(
      id: 'ST-001',
      name: '清河村中心驿站',
      address: '清河村村委会旁 20 米',
      distance: '0.6km',
      lat: 30.5100,
      lng: 114.3100,
    ),
    StationVO(
      id: 'ST-002',
      name: '村口便民取件点',
      address: '清河村村口小卖部',
      distance: '1.2km',
      lat: 30.5180,
      lng: 114.3190,
    ),
    StationVO(
      id: 'ST-003',
      name: '卫生室临时取件点',
      address: '清河村卫生室对面',
      distance: '1.8km',
      lat: 30.5030,
      lng: 114.3020,
    ),
  ];

  static final newsPosts = [
    NewsPostVO(
      id: 'NEWS-001',
      title: '明日暴雨预警',
      content: '明日暴雨预警，清河村部分包裹可能会延迟派送。药品、生鲜等时效包裹将优先入库并安排骑手上门，请村民关注取件码通知。',
      tag: '紧急通知',
      authorName: '站点管理员',
      stationName: '清河村中心驿站',
      publishedAtText: '2小时前',
      likes: 32,
      comments: ['收到，谢谢提醒', '药品包裹能优先配送很贴心'],
      isUrgent: true,
    ),
    NewsPostVO(
      id: 'NEWS-002',
      title: '积分兑换商品上新',
      content: '清河村中心驿站新增上门配送立减券、抽纸和农家土鸡蛋，完成收件签收和评价都可以继续累计积分。',
      tag: '驿站动态',
      authorName: '站点管理员',
      stationName: '清河村中心驿站',
      publishedAtText: '今天 09:20',
      likes: 18,
      comments: ['这个活动不错', '想兑换土鸡蛋'],
      isUrgent: false,
    ),
    NewsPostVO(
      id: 'NEWS-003',
      title: '药品包裹优先配送说明',
      content: '县医院药品快件将默认进入优先配送队列，由张师傅等实名认证骑手送货上门，签收时请向骑手出示取件码。',
      tag: '服务公告',
      authorName: '站点管理员',
      stationName: '清河村中心驿站',
      publishedAtText: '昨天 18:40',
      likes: 24,
      comments: ['老人用药更方便了'],
      isUrgent: false,
    ),
  ];

  static final mallItems = [
    MallItemVO(
      id: 'MALL-001',
      name: '上门配送立减券',
      desc: '适用于清河村中心驿站上门配送服务',
      points: 120,
      type: MallItemType.coupon,
    ),
    MallItemVO(
      id: 'MALL-002',
      name: '配送优先券',
      desc: '可优先安排骑手上门配送',
      points: 220,
      type: MallItemType.coupon,
    ),
    MallItemVO(
      id: 'MALL-003',
      name: '抽纸一提',
      desc: '到清河村中心驿站领取',
      points: 360,
      type: MallItemType.goods,
    ),
    MallItemVO(
      id: 'MALL-004',
      name: '农家土鸡蛋 6 枚',
      desc: '每日限量，兑换后站点自提',
      points: 520,
      type: MallItemType.goods,
    ),
  ];

  static UserProfileVO userProfile(List<VillagePackage> relatedPackages) {
    final orderSummaries = relatedPackages
        .map(
          (package) =>
              '${package.id} | ${package.status.label} | ${package.name}',
        )
        .toList();
    final pendingSummaries = relatedPackages
        .where((package) => package.status != PackageStatus.completed)
        .map((package) => '${package.name} 当前为「${package.status.label}」')
        .toList();

    return UserProfileVO(
      userNo: 'U20260524001',
      nickname: '村民张三',
      avatarUrl: 'https://api.dicebear.com/7.x/avataaars/png?seed=Felix',
      backgroundUrls: const [
        'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=900&q=80',
        'https://images.unsplash.com/photo-1473773508845-188df298d2d1?auto=format&fit=crop&w=900&q=80',
        'https://images.unsplash.com/photo-1499529112087-3cb3b73cec95?auto=format&fit=crop&w=900&q=80',
      ],
      points: 1250,
      couponCount: 3,
      balance: 0,
      memberLevel: '金牌村民',
      monthlySignedCount: 8,
      addresses: const ['清河村 3 组 18 号', '清河村村委会旁 20 米'],
      orderSummaries: orderSummaries,
      pendingSummaries: pendingSummaries,
      mallItems: mallItems,
    );
  }

  static final courierProfile = CourierProfileVO(
    courierNo: 'COURIER-013',
    name: '张师傅',
    phone: '138****1313',
    stationName: '清河村中心驿站',
    levelName: '金牌配送员 Lv.4',
    monthlyRank: 3,
    levelProgress: 0.88,
  );

  static final earnings = EarningsVO(
    totalEarnings: 2860,
    todayEarnings: 48,
    completedOrders: 49,
  );
}
