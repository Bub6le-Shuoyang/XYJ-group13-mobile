import '../core/models/result.dart';
import '../core/models/business_models.dart';
import '../core/network/api_client.dart';

class UserService {
  final ApiClient _apiClient = ApiClient();

  // 1. 获取我的包裹列表
  Future<Result<Page<PackageVO>>> getPackages(
    String type, {
    int page = 1,
    int size = 10,
  }) async {
    return _apiClient.get<Page<PackageVO>>(
      '/user/packages',
      queryParameters: {'type': type, 'page': page, 'size': size},
      fromJsonT: (data) =>
          Page.fromJson(data, (json) => PackageVO.fromJson(json)),
    );
  }

  // 2. 确认签收
  Future<Result<bool>> confirmReceipt(String packageId) async {
    return _apiClient.post<bool>(
      '/user/packages/$packageId/confirm',
      fromJsonT: (data) => data as bool,
    );
  }

  // 3. 评价包裹服务
  Future<Result<bool>> ratePackage(
    String packageId,
    int score,
    String comment,
  ) async {
    return _apiClient.post<bool>(
      '/user/packages/$packageId/rate',
      data: {'score': score, 'comment': comment},
      fromJsonT: (data) => data as bool,
    );
  }

  // 4. 提交投诉
  Future<Result<bool>> complainPackage(
    String packageId,
    String reason,
    String description,
    List<String> images,
  ) async {
    return _apiClient.post<bool>(
      '/user/packages/$packageId/complain',
      data: {'reason': reason, 'description': description, 'images': images},
      fromJsonT: (data) => data as bool,
    );
  }
}
