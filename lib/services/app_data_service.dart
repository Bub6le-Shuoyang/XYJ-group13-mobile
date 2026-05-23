import '../core/models/business_models.dart';
import '../core/models/result.dart';
import '../core/network/api_client.dart';
import '../features/package/state/package_state.dart';
import 'mock_data.dart';

class AppDataService {
  final ApiClient _apiClient = ApiClient();

  Future<Result<List<NewsPostVO>>> getNewsPosts() async {
    final result = await _apiClient.get<Page<NewsPostVO>>(
      '/content/news',
      queryParameters: {'page': 1, 'size': 20},
      fromJsonT: (data) => Page.fromJson(
        data as Map<String, dynamic>,
        (json) => NewsPostVO.fromJson(json as Map<String, dynamic>),
      ),
    );
    if (result.isSuccess && result.data != null) {
      return _success(result.data!.records);
    }
    return _fallback(MockData.newsPosts, '资讯接口失败，已使用模拟资讯：${result.message}');
  }

  Future<Result<bool>> publishNews(String content) async {
    final result = await _apiClient.post<bool>(
      '/content/news',
      data: {'content': content},
      fromJsonT: (data) => data as bool,
    );
    if (result.isSuccess) {
      return result;
    }
    return Result(
      code: 200,
      message: '发布接口失败，已在本地模拟发布：${result.message}',
      timestamp: DateTime.now().millisecondsSinceEpoch,
      data: true,
    );
  }

  Future<Result<List<StationVO>>> getNearbyStations() async {
    final result = await _apiClient.get<List<StationVO>>(
      '/stations/nearby',
      queryParameters: {'lat': 30.51, 'lng': 114.31},
      fromJsonT: (data) => (data as List)
          .map((json) => StationVO.fromJson(json as Map<String, dynamic>))
          .toList(),
    );
    if (result.isSuccess && result.data != null) {
      return _success(result.data!);
    }
    return _fallback(MockData.stations, '驿站接口失败，已使用模拟驿站：${result.message}');
  }

  Future<Result<UserProfileVO>> getUserProfile(
    List<VillagePackage> packages,
  ) async {
    final result = await _apiClient.get<UserProfileVO>(
      '/user/profile',
      fromJsonT: (data) => UserProfileVO.fromJson(data as Map<String, dynamic>),
    );
    if (result.isSuccess && result.data != null) {
      return _success(result.data!);
    }
    return _fallback(
      MockData.userProfile(packages),
      '用户资料接口失败，已使用模拟用户数据：${result.message}',
    );
  }

  Future<Result<bool>> addAddress(String address) async {
    final result = await _apiClient.post<bool>(
      '/user/addresses',
      data: {'address': address},
      fromJsonT: (data) => data as bool,
    );
    if (result.isSuccess) {
      return result;
    }
    return Result(
      code: 200,
      message: '地址接口失败，已在本地模拟保存：${result.message}',
      timestamp: DateTime.now().millisecondsSinceEpoch,
      data: true,
    );
  }

  Future<Result<bool>> redeemMallItem(String itemId) async {
    final result = await _apiClient.post<bool>(
      '/user/mall/items/$itemId/redeem',
      fromJsonT: (data) => data as bool,
    );
    if (result.isSuccess) {
      return result;
    }
    return Result(
      code: 200,
      message: '兑换接口失败，已在本地模拟兑换：${result.message}',
      timestamp: DateTime.now().millisecondsSinceEpoch,
      data: true,
    );
  }

  Result<T> _success<T>(T data) {
    return Result(
      code: 200,
      message: 'success',
      timestamp: DateTime.now().millisecondsSinceEpoch,
      data: data,
    );
  }

  Result<T> _fallback<T>(T data, String message) {
    return Result(
      code: 200,
      message: message,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      data: data,
    );
  }
}
