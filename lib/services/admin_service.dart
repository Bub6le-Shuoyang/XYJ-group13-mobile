import '../core/models/result.dart';
import '../core/network/api_client.dart';

class AdminService {
  final ApiClient _apiClient = ApiClient();

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
    return _apiClient.post<bool>(
      '/admin/tasks',
      data: {'package_id': packageId, 'reward_amount': rewardAmount},
      fromJsonT: (data) => data as bool,
    );
  }
}
