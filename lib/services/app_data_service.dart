import 'package:dio/dio.dart';

import '../core/models/business_models.dart';
import '../core/models/result.dart';
import '../core/network/api_client.dart';
import '../features/package/state/package_state.dart';
import 'location_service.dart';

const double _defaultNearbyLat = 39.9499;
const double _defaultNearbyLng = 116.3420;

class AppDataService {
  final ApiClient _apiClient = ApiClient();
  final LocationService _locationService = const LocationService();

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

  Future<Result<List<StationVO>>> getNearbyStations({
    double? lat,
    double? lng,
  }) async {
    final currentLocation = (lat != null && lng != null)
        ? LocationPoint(lat: lat, lng: lng)
        : await _locationService.getCurrentLocation();
    final resolvedLat = currentLocation?.lat ?? _defaultNearbyLat;
    final resolvedLng = currentLocation?.lng ?? _defaultNearbyLng;
    final result = await _apiClient.get<List<StationVO>>(
      '/stations/nearby',
      queryParameters: {'lat': resolvedLat, 'lng': resolvedLng},
      fromJsonT: (data) => (data as List)
          .map((json) => StationVO.fromJson(json as Map<String, dynamic>))
          .toList(),
    );
    if (result.isSuccess && result.data != null) {
      return _success(result.data!);
    }
    return _emptyList(result);
  }

  Future<Result<SplashAdVO>> getSplashAd() async {
    return _apiClient.get<SplashAdVO>(
      '/sys/ads/splash',
      fromJsonT: (data) => SplashAdVO.fromJson(data as Map<String, dynamic>),
    );
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

  Future<Result<String>> uploadAvatar({
    required List<int> bytes,
    required String filename,
  }) async {
    final result = await _apiClient.postForm<UploadVO>(
      '/upload',
      data: FormData.fromMap({
        'scene': 'avatar',
        'file': MultipartFile.fromBytes(bytes, filename: filename),
      }),
      fromJsonT: (data) => UploadVO.fromJson(data as Map<String, dynamic>),
    );
    if (result.isSuccess && result.data != null) {
      return _success(result.data!.url);
    }
    return Result(
      code: result.code,
      message: result.message,
      timestamp: result.timestamp,
    );
  }

  Future<Result<UserProfileVO>> updateAvatar(String avatarUrl) {
    return _apiClient.put<UserProfileVO>(
      '/user/profile/avatar',
      data: {'avatar_url': avatarUrl},
      fromJsonT: (data) => UserProfileVO.fromJson(data as Map<String, dynamic>),
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

  Future<Result<Page<MallItemVO>>> getMallItems({
    int page = 1,
    int size = 50,
  }) async {
    return _apiClient.get<Page<MallItemVO>>(
      '/user/mall/items',
      queryParameters: {'page': page, 'size': size},
      fromJsonT: (data) => Page.fromJson(
        data as Map<String, dynamic>,
        (json) => MallItemVO.fromJson(json as Map<String, dynamic>),
      ),
    );
  }

  Future<Result<Page<RedeemRecordVO>>> getRedeemRecords({
    int page = 1,
    int size = 20,
  }) async {
    return _apiClient.get<Page<RedeemRecordVO>>(
      '/user/mall/redeem-records',
      queryParameters: {'page': page, 'size': size},
      fromJsonT: (data) => Page.fromJson(
        data as Map<String, dynamic>,
        (json) => RedeemRecordVO.fromJson(json as Map<String, dynamic>),
      ),
    );
  }

  Future<Result<RedeemRecordVO>> redeemMallItem(String itemId) async {
    return _apiClient.post<RedeemRecordVO>(
      '/user/mall/items/$itemId/redeem',
      fromJsonT: (data) =>
          RedeemRecordVO.fromJson(data as Map<String, dynamic>),
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
