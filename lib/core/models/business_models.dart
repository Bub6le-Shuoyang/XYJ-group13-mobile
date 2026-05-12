class PackageVO {
  final String packageId;
  final String name;
  final String receiverName;
  final String receiverPhone;
  final String address;
  final double weight;
  final double estimatedFee;
  final String status;

  PackageVO({
    required this.packageId,
    required this.name,
    required this.receiverName,
    required this.receiverPhone,
    required this.address,
    required this.weight,
    required this.estimatedFee,
    required this.status,
  });

  factory PackageVO.fromJson(Map<String, dynamic> json) {
    return PackageVO(
      packageId: json['package_id'] as String,
      name: json['name'] as String,
      receiverName: json['receiver_name'] as String,
      receiverPhone: json['receiver_phone'] as String,
      address: json['address'] as String,
      weight: (json['weight'] as num).toDouble(),
      estimatedFee: (json['estimated_fee'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'UNKNOWN',
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

  TaskVO({
    required this.taskId,
    required this.packageId,
    required this.packageName,
    required this.pickupAddress,
    required this.deliverAddress,
    required this.rewardAmount,
    required this.status,
  });

  factory TaskVO.fromJson(Map<String, dynamic> json) {
    return TaskVO(
      taskId: json['task_id'] as String,
      packageId: json['package_id'] as String,
      packageName: json['package_name'] as String,
      pickupAddress: json['pickup_address'] as String,
      deliverAddress: json['deliver_address'] as String,
      rewardAmount: (json['reward_amount'] as num).toDouble(),
      status: json['status'] as String,
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
      totalEarnings: (json['total_earnings'] as num).toDouble(),
      todayEarnings: (json['today_earnings'] as num).toDouble(),
      completedOrders: json['completed_orders'] as int,
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
