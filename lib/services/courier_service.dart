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

  // 2. 配送员抢单
  Future<Result<bool>> grabTask(String taskId) async {
    return _apiClient.post<bool>(
      '/courier/tasks/$taskId/grab',
      fromJsonT: (data) => data as bool,
    );
  }

  // 3. 确认取件 (前往取件位置)
  Future<Result<bool>> pickupTask(String taskId) async {
    return _apiClient.post<bool>(
      '/courier/tasks/$taskId/pickup',
      fromJsonT: (data) => data as bool,
    );
  }

  // 4. 确认送达 (到达送达位置)
  Future<Result<bool>> deliverTask(
    String taskId, {
    String? deliverImage,
  }) async {
    return _apiClient.post<bool>(
      '/courier/tasks/$taskId/deliver',
      data: deliverImage != null ? {'deliver_image': deliverImage} : null,
      fromJsonT: (data) => data as bool,
    );
  }

  // 5. 查看收益
  Future<Result<EarningsVO>> getEarnings() async {
    return _apiClient.get<EarningsVO>(
      '/courier/earnings',
      fromJsonT: (data) => EarningsVO.fromJson(data),
    );
  }
}
