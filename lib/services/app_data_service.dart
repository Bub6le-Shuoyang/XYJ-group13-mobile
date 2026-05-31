import '../core/models/business_models.dart';
import '../core/models/result.dart';
import '../core/network/api_client.dart';
import '../features/package/state/package_state.dart';

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
    return _emptyList(result);
  }

  Future<Result<NewsPostVO>> publishNews(String content) async {
    return _apiClient.post<NewsPostVO>(
      '/content/news',
      data: {
        'title': '村民发布',
        'content': content,
        'tag': '村民分享',
        'is_urgent': false,
      },
      fromJsonT: (data) => NewsPostVO.fromJson(data as Map<String, dynamic>),
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
    return _emptyList(result);
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
    return Result(
      code: result.code,
      message: result.message,
      timestamp: result.timestamp,
    );
  }

  Future<Result<Map<String, dynamic>>> addAddress({
    required String name,
    required String phone,
    required String address,
    required bool isDefault,
  }) async {
    return _apiClient.post<Map<String, dynamic>>(
      '/user/addresses',
      data: {
        'name': name,
        'phone': phone,
        'address': address,
        'is_default': isDefault,
      },
      fromJsonT: (data) => data as Map<String, dynamic>,
    );
  }

  Future<Result<Map<String, dynamic>>> redeemMallItem(String itemId) async {
    return _apiClient.post<Map<String, dynamic>>(
      '/user/mall/items/$itemId/redeem',
      fromJsonT: (data) => data as Map<String, dynamic>,
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

  Result<List<T>> _emptyList<T>(Result<dynamic> result) {
    return Result(
      code: result.code,
      message: result.message,
      timestamp: result.timestamp,
      data: const [],
    );
  }
}
