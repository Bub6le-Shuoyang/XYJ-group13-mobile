import '../core/models/business_models.dart';
import '../core/models/result.dart';
import '../core/network/api_client.dart';
import '../features/package/state/package_state.dart';
import 'mock_data.dart';

class PackageService {
  final ApiClient _apiClient = ApiClient();

  Future<Result<List<VillagePackage>>> getPackages() async {
    final result = await _apiClient.get<Page<PackageVO>>(
      '/user/packages',
      queryParameters: {'type': 'RECEIVE', 'page': 1, 'size': 100},
      fromJsonT: (data) => Page.fromJson(
        data as Map<String, dynamic>,
        (json) => PackageVO.fromJson(json as Map<String, dynamic>),
      ),
    );

    if (result.isSuccess && result.data != null) {
      return Result(
        code: 200,
        message: 'success',
        timestamp: DateTime.now().millisecondsSinceEpoch,
        data: result.data!.records.map(_fromPackageVO).toList(),
      );
    }

    return _mockPackages('接口调用失败，已使用本地模拟包裹数据：${result.message}');
  }

  Future<Result<bool>> updatePackageStatus(
    String id,
    PackageStatus nextStatus, {
    double rewardAmount = 8,
  }) async {
    final result = switch (nextStatus) {
      PackageStatus.inStock => await _apiClient.post<bool>(
        '/admin/packages/$id/inbound',
        data: {'shelf_number': 'A-01-03'},
        fromJsonT: (data) => data as bool,
      ),
      PackageStatus.taskPublished => await _publishOutboundTask(
        id,
        rewardAmount,
      ),
      PackageStatus.assigned => await _apiClient.post<bool>(
        '/courier/tasks/$id/grab',
        fromJsonT: (data) => data as bool,
      ),
      PackageStatus.completed => await _apiClient.post<bool>(
        '/user/packages/$id/confirm',
        fromJsonT: (data) => data as bool,
      ),
      PackageStatus.pendingInbound => Result<bool>(
        code: 200,
        message: 'pending inbound is local only',
        timestamp: DateTime.now().millisecondsSinceEpoch,
        data: true,
      ),
    };

    if (result.isSuccess) {
      return result;
    }

    return Result(
      code: 200,
      message: '接口调用失败，已在模拟数据中推进状态：${result.message}',
      timestamp: DateTime.now().millisecondsSinceEpoch,
      data: true,
    );
  }

  Result<List<VillagePackage>> _mockPackages(String message) {
    return Result(
      code: 200,
      message: message,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      data: MockData.packages,
    );
  }

  Future<Result<bool>> _publishOutboundTask(
    String packageId,
    double rewardAmount,
  ) async {
    final outbound = await _apiClient.post<bool>(
      '/admin/packages/$packageId/outbound',
      fromJsonT: (data) => data as bool,
    );
    if (!outbound.isSuccess) {
      return outbound;
    }

    return _apiClient.post<bool>(
      '/admin/tasks',
      data: {'package_id': packageId, 'reward_amount': rewardAmount},
      fromJsonT: (data) => data as bool,
    );
  }

  VillagePackage _fromPackageVO(PackageVO vo) {
    final status = _parseStatus(vo.status);
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

  PackageStatus _parseStatus(String status) {
    return switch (status.toUpperCase()) {
      'PENDING_INBOUND' || 'WAIT_INBOUND' => PackageStatus.pendingInbound,
      'IN_STOCK' || 'INBOUND' || 'STORED' => PackageStatus.inStock,
      'TASK_PUBLISHED' ||
      'READY_FOR_COURIER' ||
      'AVAILABLE' => PackageStatus.taskPublished,
      'ASSIGNED' || 'DELIVERING' || 'IN_DELIVERY' => PackageStatus.assigned,
      'COMPLETED' || 'SIGNED' || 'CONFIRMED' => PackageStatus.completed,
      _ => PackageStatus.pendingInbound,
    };
  }
}
