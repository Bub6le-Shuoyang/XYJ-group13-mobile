double _readDouble(
  Map<String, dynamic> json,
  List<String> keys, [
  double fallback = 0,
]) {
  for (final key in keys) {
    final value = json[key];
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value) ?? fallback;
    }
  }
  return fallback;
}

int _readInt(Map<String, dynamic> json, List<String> keys, [int fallback = 0]) {
  for (final key in keys) {
    final value = json[key];
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value) ?? fallback;
    }
  }
  return fallback;
}

String _readString(
  Map<String, dynamic> json,
  List<String> keys, [
  String fallback = '',
]) {
  for (final key in keys) {
    final value = json[key];
    if (value != null) {
      return value.toString();
    }
  }
  return fallback;
}

String? _readNullableString(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value != null && value.toString().isNotEmpty) {
      return value.toString();
    }
  }
  return null;
}

List<String> _readStringList(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }
  }
  return const [];
}

class PackageVO {
  final String packageId;
  final String name;
  final String receiverName;
  final String receiverPhone;
  final String address;
  final double weight;
  final double estimatedFee;
  final String status;
  final String pickupCode;
  final String senderName;
  final double rewardAmount;
  final List<String> timeline;
  final String? courierName;
  final double lat;
  final double lng;

  PackageVO({
    required this.packageId,
    required this.name,
    required this.receiverName,
    required this.receiverPhone,
    required this.address,
    required this.weight,
    required this.estimatedFee,
    required this.status,
    required this.pickupCode,
    required this.senderName,
    required this.rewardAmount,
    required this.timeline,
    required this.lat,
    required this.lng,
    this.courierName,
  });

  factory PackageVO.fromJson(Map<String, dynamic> json) {
    return PackageVO(
      packageId: _readString(json, ['package_id', 'packageId', 'id']),
      name: _readString(json, ['name', 'package_name', 'packageName'], '普通包裹'),
      receiverName: _readString(json, [
        'receiver_name',
        'receiverName',
        'receiver',
      ]),
      receiverPhone: _readString(json, ['receiver_phone', 'receiverPhone']),
      address: _readString(json, [
        'address',
        'deliver_address',
        'deliverAddress',
      ]),
      weight: _readDouble(json, ['weight']),
      estimatedFee: _readDouble(json, ['estimated_fee', 'estimatedFee']),
      status: _readString(json, ['status'], 'UNKNOWN'),
      pickupCode: _readString(json, ['pickup_code', 'pickupCode'], 'QJ00000'),
      senderName: _readString(json, [
        'sender_name',
        'senderName',
        'sender',
      ], '镇上仓库'),
      rewardAmount: _readDouble(json, [
        'reward_amount',
        'rewardAmount',
        'reward',
      ]),
      timeline: _readStringList(json, ['timeline', 'traces', 'logs']),
      courierName:
          json['courier_name'] as String? ?? json['courierName'] as String?,
      lat: _readDouble(json, ['lat', 'latitude'], 30.51),
      lng: _readDouble(json, ['lng', 'longitude'], 114.31),
    );
  }
}

class TaskVO {
  final String taskId;
  final String packageId;
  final String packageName;
  final String pickupAddress;
  final String deliverAddress;
  final double rewardAmount;
  final String status;
  final String pickupCodeMasked;

  TaskVO({
    required this.taskId,
    required this.packageId,
    required this.packageName,
    required this.pickupAddress,
    required this.deliverAddress,
    required this.rewardAmount,
    required this.status,
    required this.pickupCodeMasked,
  });

  factory TaskVO.fromJson(Map<String, dynamic> json) {
    return TaskVO(
      taskId: _readString(json, ['task_id', 'taskId', 'id']),
      packageId: _readString(json, ['package_id', 'packageId']),
      packageName: _readString(json, ['package_name', 'packageName'], '普通包裹'),
      pickupAddress: _readString(json, ['pickup_address', 'pickupAddress']),
      deliverAddress: _readString(json, ['deliver_address', 'deliverAddress']),
      rewardAmount: _readDouble(json, ['reward_amount', 'rewardAmount']),
      status: _readString(json, ['status']),
      pickupCodeMasked: _readString(json, [
        'pickup_code_masked',
        'pickupCodeMasked',
      ]),
    );
  }
}

class EarningsVO {
  final double totalEarnings;
  final double todayEarnings;
  final int completedOrders;

  EarningsVO({
    required this.totalEarnings,
    required this.todayEarnings,
    required this.completedOrders,
  });

  factory EarningsVO.fromJson(Map<String, dynamic> json) {
    return EarningsVO(
      totalEarnings: _readDouble(json, ['total_earnings', 'totalEarnings']),
      todayEarnings: _readDouble(json, ['today_earnings', 'todayEarnings']),
      completedOrders: _readInt(json, [
        'completed_orders',
        'completedOrders',
        'completed_tasks',
        'completedTasks',
      ]),
    );
  }
}

class CourierProfileVO {
  final String courierNo;
  final String name;
  final String phone;
  final String stationName;
  final String levelName;
  final int monthlyRank;
  final double levelProgress;

  CourierProfileVO({
    required this.courierNo,
    required this.name,
    required this.phone,
    required this.stationName,
    required this.levelName,
    required this.monthlyRank,
    required this.levelProgress,
  });

  factory CourierProfileVO.fromJson(Map<String, dynamic> json) {
    return CourierProfileVO(
      courierNo: _readString(json, ['courier_no', 'courierNo'], 'COURIER-013'),
      name: _readString(json, ['name', 'real_name', 'realName'], '张师傅'),
      phone: _readString(json, ['phone'], '138****1313'),
      stationName: _readString(json, [
        'station_name',
        'stationName',
      ], '清河村中心驿站'),
      levelName: _readString(json, ['level_name', 'levelName'], '金牌配送员 Lv.4'),
      monthlyRank: _readInt(json, ['monthly_rank', 'monthlyRank'], 3),
      levelProgress: _readDouble(json, [
        'level_progress',
        'levelProgress',
      ], 0.88),
    );
  }
}

class StationVO {
  final String id;
  final String name;
  final String address;
  final String distance;
  final double lat;
  final double lng;

  StationVO({
    required this.id,
    required this.name,
    required this.address,
    required this.distance,
    required this.lat,
    required this.lng,
  });

  factory StationVO.fromJson(Map<String, dynamic> json) {
    return StationVO(
      id: _readString(json, ['id', 'station_id', 'stationId']),
      name: _readString(json, ['name', 'station_name', 'stationName']),
      address: _readString(json, ['address']),
      distance: _readString(json, ['distance'], '0.0km'),
      lat: _readDouble(json, ['lat', 'latitude'], 30.51),
      lng: _readDouble(json, ['lng', 'longitude'], 114.31),
    );
  }
}

class NewsPostVO {
  final String id;
  final String title;
  final String content;
  final String tag;
  final String authorName;
  final String stationName;
  final String publishedAtText;
  final int likes;
  final int commentsCount;
  final List<String> comments;
  final bool isUrgent;

  NewsPostVO({
    required this.id,
    required this.title,
    required this.content,
    required this.tag,
    required this.authorName,
    required this.stationName,
    required this.publishedAtText,
    required this.likes,
    required this.commentsCount,
    required this.comments,
    required this.isUrgent,
  });

  factory NewsPostVO.fromJson(Map<String, dynamic> json) {
    final comments = _readStringList(json, ['comments']);
    return NewsPostVO(
      id: _readString(json, ['id', 'post_id', 'postId']),
      title: _readString(json, ['title']),
      content: _readString(json, ['content']),
      tag: _readString(json, ['tag']),
      authorName: _readString(json, ['author_name', 'authorName'], '站点管理员'),
      stationName: _readString(json, ['station_name', 'stationName'], '清河村驿站'),
      publishedAtText: _readPublishedAtText(json),
      likes: _readInt(json, ['likes']),
      commentsCount: comments.isNotEmpty
          ? comments.length
          : _readInt(json, ['comments_count', 'commentsCount']),
      comments: comments,
      isUrgent:
          json['is_urgent'] as bool? ?? json['isUrgent'] as bool? ?? false,
    );
  }
}

String _readPublishedAtText(Map<String, dynamic> json) {
  final text = _readString(json, ['published_at_text', 'publishedAtText']);
  if (text.isNotEmpty) {
    return text;
  }
  final rawTime = _readString(json, ['publish_time', 'publishTime']);
  final time = DateTime.tryParse(rawTime);
  if (time == null) {
    return '刚刚';
  }
  final diff = DateTime.now().difference(time.toLocal());
  if (diff.inMinutes < 1) {
    return '刚刚';
  }
  if (diff.inHours < 1) {
    return '${diff.inMinutes}分钟前';
  }
  if (diff.inDays < 1) {
    return '${diff.inHours}小时前';
  }
  return '${diff.inDays}天前';
}

enum MallItemType { coupon, goods }

class MallItemVO {
  final String id;
  final String name;
  final String desc;
  final int points;
  final MallItemType type;
  final int stock;
  final String? imageUrl;

  MallItemVO({
    required this.id,
    required this.name,
    required this.desc,
    required this.points,
    required this.type,
    required this.stock,
    this.imageUrl,
  });

  factory MallItemVO.fromJson(Map<String, dynamic> json) {
    final type = _readString(json, ['type'], 'goods').toLowerCase();
    return MallItemVO(
      id: _readString(json, ['id', 'item_id', 'itemId']),
      name: _readString(json, ['name']),
      desc: _readString(json, ['desc', 'description']),
      points: _readInt(json, ['points', 'points_required', 'pointsRequired']),
      type: type == 'coupon' ? MallItemType.coupon : MallItemType.goods,
      stock: _readInt(json, ['stock']),
      imageUrl: _readNullableString(json, ['image_url', 'imageUrl']),
    );
  }
}

class RedeemRecordVO {
  final String id;
  final String itemName;
  final int pointsCost;
  final int remainPoints;
  final String status;

  RedeemRecordVO({
    required this.id,
    required this.itemName,
    required this.pointsCost,
    required this.remainPoints,
    required this.status,
  });

  factory RedeemRecordVO.fromJson(Map<String, dynamic> json) {
    return RedeemRecordVO(
      id: _readString(json, ['id', 'record_id', 'recordId']),
      itemName: _readString(json, ['item_name', 'itemName']),
      pointsCost: _readInt(json, ['points_cost', 'pointsCost']),
      remainPoints: _readInt(json, ['remain_points', 'remainPoints']),
      status: _readString(json, ['status']),
    );
  }
}

class SplashAdVO {
  final String adNo;
  final String name;
  final String imageUrl;
  final String targetUrl;

  const SplashAdVO({
    required this.adNo,
    required this.name,
    required this.imageUrl,
    required this.targetUrl,
  });

  factory SplashAdVO.fromJson(Map<String, dynamic> json) {
    return SplashAdVO(
      adNo: _readString(json, ['ad_no', 'adNo']),
      name: _readString(json, ['name']),
      imageUrl: _readString(json, ['image_url', 'imageUrl']),
      targetUrl: _readString(json, ['target_url', 'targetUrl']),
    );
  }

  bool get isValid => imageUrl.isNotEmpty && targetUrl.isNotEmpty;
}

class UserProfileVO {
  final String userNo;
  final String nickname;
  final String avatarUrl;
  final List<String> backgroundUrls;
  final int points;
  final int couponCount;
  final double balance;
  final String memberLevel;
  final int monthlySignedCount;
  final List<String> addresses;
  final List<String> orderSummaries;
  final List<String> pendingSummaries;
  final List<MallItemVO> mallItems;

  UserProfileVO({
    required this.userNo,
    required this.nickname,
    required this.avatarUrl,
    required this.backgroundUrls,
    required this.points,
    required this.couponCount,
    required this.balance,
    required this.memberLevel,
    required this.monthlySignedCount,
    required this.addresses,
    required this.orderSummaries,
    required this.pendingSummaries,
    required this.mallItems,
  });

  factory UserProfileVO.fromJson(Map<String, dynamic> json) {
    return UserProfileVO(
      userNo: _readString(json, ['user_no', 'userNo']),
      nickname: _readString(json, ['nickname'], '村民张三'),
      avatarUrl: _readString(json, [
        'avatar_url',
        'avatarUrl',
      ], 'https://api.dicebear.com/7.x/avataaars/png?seed=Felix'),
      backgroundUrls: _readStringList(json, [
        'background_urls',
        'backgroundUrls',
      ]),
      points: _readInt(json, ['points']),
      couponCount: _readInt(json, ['coupon_count', 'couponCount']),
      balance: _readDouble(json, ['balance']),
      memberLevel: _readString(json, ['member_level', 'memberLevel'], '金牌村民'),
      monthlySignedCount: _readInt(json, [
        'monthly_signed_count',
        'monthlySignedCount',
      ]),
      addresses: _readStringList(json, ['addresses']),
      orderSummaries: _readStringList(json, [
        'order_summaries',
        'orderSummaries',
      ]),
      pendingSummaries: _readStringList(json, [
        'pending_summaries',
        'pendingSummaries',
      ]),
      mallItems:
          ((json['mall_items'] ?? json['mallItems']) as List?)
              ?.map((item) => MallItemVO.fromJson(item as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}

class Page<T> {
  final int total;
  final int current;
  final int size;
  final List<T> records;

  Page({
    required this.total,
    required this.current,
    required this.size,
    required this.records,
  });

  factory Page.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    return Page(
      total: json['total'] as int? ?? 0,
      current: json['current'] as int? ?? 1,
      size: json['size'] as int? ?? 10,
      records: (json['records'] as List?)?.map(fromJsonT).toList() ?? [],
    );
  }
}
