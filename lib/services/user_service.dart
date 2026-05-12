import '../core/models/result.dart';
import '../core/models/business_models.dart';
import '../core/network/api_client.dart';

class UserService {
  final ApiClient _apiClient = ApiClient();

  // 1. 发起寄件
  Future<Result<PackageVO>> createPackage(
    String name,
    String receiverName,
    String receiverPhone,
    String address,
    double weight,
  ) async {
    return _apiClient.post<PackageVO>(
      '/user/packages',
      data: {
        'name': name,
        'receiver_name': receiverName,
        'receiver_phone': receiverPhone,
        'address': address,
        'weight': weight,
      },
      fromJsonT: (data) => PackageVO.fromJson(data),
    );
  }

  // 2. 支付费用
  Future<Result<bool>> payPackage(
    String packageId,
    String payMethod,
    double amount,
  ) async {
    return _apiClient.post<bool>(
      '/user/packages/$packageId/pay',
      data: {'pay_method': payMethod, 'amount': amount},
      fromJsonT: (data) => data as bool,
    );
  }

  // 3. 获取我的收件/寄件列表
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

  // 4. 确认签收
  Future<Result<bool>> confirmReceipt(String packageId) async {
    return _apiClient.post<bool>(
      '/user/packages/$packageId/confirm',
      fromJsonT: (data) => data as bool,
    );
  }

  // 5. 评价包裹服务
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

  // 6. 提交投诉
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
