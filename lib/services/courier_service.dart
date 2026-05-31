import '../core/models/result.dart';
import '../core/models/business_models.dart';
import '../core/network/api_client.dart';

class CourierService {
  final ApiClient _apiClient = ApiClient();

  // 1. 获取可抢任务列表
  Future<Result<Page<TaskVO>>> getAvailableTasks({
    int page = 1,
    int size = 10,
  }) async {
    return _apiClient.get<Page<TaskVO>>(
      '/courier/tasks/available',
      queryParameters: {'page': page, 'size': size},
      fromJsonT: (data) => Page.fromJson(data, (json) => TaskVO.fromJson(json)),
    );
  }

  Future<Result<Page<TaskVO>>> getMyTasks({
    String status = 'ALL',
    int page = 1,
    int size = 50,
  }) async {
    return _apiClient.get<Page<TaskVO>>(
      '/courier/tasks/mine',
      queryParameters: {'status': status, 'page': page, 'size': size},
      fromJsonT: (data) => Page.fromJson(data, (json) => TaskVO.fromJson(json)),
    );
  }

  // 2. 配送员抢单
  Future<Result<bool>> grabTask(String taskId) async {
    return _postTaskAction('/courier/tasks/$taskId/grab');
  }

  // 3. 确认取件 (前往取件位置)
  Future<Result<bool>> pickupTask(String taskId) async {
    return _postTaskAction('/courier/tasks/$taskId/pickup');
  }

  // 4. 确认送达 (到达送达位置)
  Future<Result<bool>> deliverTask(
    String taskId, {
    String? deliverImage,
  }) async {
    return _postTaskAction(
      '/courier/tasks/$taskId/deliver',
      data: deliverImage != null ? {'deliver_image': deliverImage} : null,
    );
  }

  Future<Result<bool>> verifyPickupCode(
    String taskId,
    String pickupCode,
  ) async {
    return _postTaskAction(
      '/courier/tasks/$taskId/verify-pickup-code',
      data: {'pickup_code': pickupCode},
    );
  }

  // 5. 查看收益
  Future<Result<EarningsVO>> getEarnings() async {
    final result = await _apiClient.get<EarningsVO>(
      '/courier/earnings',
      fromJsonT: (data) => EarningsVO.fromJson(data),
    );
    return result;
  }

  Future<Result<CourierProfileVO>> getProfile() async {
    final result = await _apiClient.get<CourierProfileVO>(
      '/courier/profile',
      fromJsonT: (data) => CourierProfileVO.fromJson(data),
    );
    return result;
  }

  Future<Result<bool>> _postTaskAction(String path, {dynamic data}) async {
    final result = await _apiClient.post<TaskVO>(
      path,
      data: data,
      fromJsonT: (data) => TaskVO.fromJson(data as Map<String, dynamic>),
    );
    return Result(
      code: result.code,
      message: result.message,
      timestamp: result.timestamp,
      data: result.isSuccess && result.data != null,
    );
  }
}
