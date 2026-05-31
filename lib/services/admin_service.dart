import '../core/models/business_models.dart';
import '../core/models/result.dart';
import '../core/network/api_client.dart';
import '../features/package/state/package_state.dart';

class AdminService {
  final ApiClient _apiClient = ApiClient();

  Future<Result<List<VillagePackage>>> getPackages({
    String status = 'ALL',
    int page = 1,
    int size = 100,
  }) async {
    final result = await _apiClient.get<Page<PackageVO>>(
      '/admin/packages',
      queryParameters: {'status': status, 'page': page, 'size': size},
      fromJsonT: (data) => Page.fromJson(
        data as Map<String, dynamic>,
        (json) => PackageVO.fromJson(json as Map<String, dynamic>),
      ),
    );

    return Result(
      code: result.code,
      message: result.message,
      timestamp: result.timestamp,
      data: result.isSuccess && result.data != null
          ? result.data!.records.map(_fromPackageVO).toList()
          : const [],
    );
  }

  // 1. 包裹入库
  Future<Result<bool>> inboundPackage(
    String packageId,
    String shelfNumber,
  ) async {
    return _apiClient.post<bool>(
      '/admin/packages/$packageId/inbound',
      data: {'shelf_number': shelfNumber},
      fromJsonT: (data) => data as bool,
    );
  }

  Future<Result<bool>> approvePackage(
    String packageId,
    double rewardAmount,
  ) async {
    final result = await _apiClient.post<TaskVO>(
      '/admin/packages/$packageId/approve',
      data: {'reward_amount': rewardAmount},
      fromJsonT: (data) => TaskVO.fromJson(data as Map<String, dynamic>),
    );
    return Result(
      code: result.code,
      message: result.message,
      timestamp: result.timestamp,
      data: result.isSuccess && result.data != null,
    );
  }

  // 2. 包裹出库
  Future<Result<bool>> outboundPackage(String packageId) async {
    return _apiClient.post<bool>(
      '/admin/packages/$packageId/outbound',
      fromJsonT: (data) => data as bool,
    );
  }

  // 3. 发布配送任务
  Future<Result<bool>> publishTask(
    String packageId,
    double rewardAmount,
  ) async {
    final result = await _apiClient.post<TaskVO>(
      '/admin/tasks',
      data: {'package_id': packageId, 'reward_amount': rewardAmount},
      fromJsonT: (data) => TaskVO.fromJson(data as Map<String, dynamic>),
    );
    return Result(
      code: result.code,
      message: result.message,
      timestamp: result.timestamp,
      data: result.isSuccess && result.data != null,
    );
  }

  VillagePackage _fromPackageVO(PackageVO vo) {
    final status = switch (vo.status.toUpperCase()) {
      'PENDING_INBOUND' || 'WAIT_INBOUND' => PackageStatus.pendingInbound,
      'IN_STOCK' || 'INBOUND' || 'STORED' => PackageStatus.inStock,
      'TASK_PUBLISHED' ||
      'READY_FOR_COURIER' ||
      'AVAILABLE' => PackageStatus.taskPublished,
      'ASSIGNED' || 'DELIVERING' || 'IN_DELIVERY' => PackageStatus.assigned,
      'COMPLETED' || 'SIGNED' || 'CONFIRMED' => PackageStatus.completed,
      _ => PackageStatus.pendingInbound,
    };
    return VillagePackage(
      id: vo.packageId,
      pickupCode: vo.pickupCode,
      name: vo.name,
      sender: vo.senderName,
      receiver: vo.receiverName,
      address: vo.address,
      reward: vo.rewardAmount.round(),
      status: status,
      timeline: vo.timeline.isEmpty ? [status.label] : vo.timeline,
      courier: vo.courierName,
      lat: vo.lat,
      lng: vo.lng,
    );
  }
}
