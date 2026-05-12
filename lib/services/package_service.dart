import '../core/models/result.dart';
import '../core/network/api_client.dart';
import '../features/package/state/package_state.dart';

class PackageService {
  final ApiClient _apiClient = ApiClient();

  // 获取所有包裹
  Future<Result<List<VillagePackage>>> getPackages() async {
    // 假设后端接口为 /packages
    // return _apiClient.get<List<VillagePackage>>(
    //   '/packages',
    //   fromJsonT: (data) => (data as List).map((e) => VillagePackage.fromJson(e)).toList(),
    // );

    // 目前先模拟异步网络请求
    await Future.delayed(const Duration(seconds: 1));
    return Result(
      code: 200,
      message: 'success',
      timestamp: DateTime.now().millisecondsSinceEpoch,
      data: [
        VillagePackage(
          id: 'PKG-001',
          name: '农资工具箱',
          sender: '镇上仓库',
          receiver: '王大爷',
          address: '清河村 3 组 18 号',
          reward: 8,
          status: PackageStatus.taskPublished,
          timeline: ['站点完成入库', '管理员发布配送任务'],
          lat: 30.51,
          lng: 114.31,
        ),
      ],
    );
  }

  // 村民寄件
  Future<Result<VillagePackage>> createPackage(
    String name,
    String receiver,
    String address,
  ) async {
    // return _apiClient.post<VillagePackage>(
    //   '/packages',
    //   data: {'name': name, 'receiver': receiver, 'address': address},
    //   fromJsonT: (data) => VillagePackage.fromJson(data),
    // );
    await Future.delayed(const Duration(milliseconds: 500));
    return Result(
      code: 200,
      message: 'success',
      timestamp: DateTime.now().millisecondsSinceEpoch,
      data: VillagePackage(
        id: 'PKG-${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        sender: '当前村民',
        receiver: receiver,
        address: address,
        reward: 9,
        status: PackageStatus.pendingInbound,
        timeline: ['村民提交寄件申请'],
        lat: 30.50,
        lng: 114.30,
      ),
    );
  }

  // 更新包裹状态
  Future<Result<bool>> updatePackageStatus(
    String id,
    PackageStatus status,
  ) async {
    // return _apiClient.post<bool>(
    //   '/packages/$id/status',
    //   data: {'status': status.name},
    //   fromJsonT: (data) => data as bool,
    // );
    await Future.delayed(const Duration(milliseconds: 500));
    return Result(
      code: 200,
      message: 'success',
      timestamp: DateTime.now().millisecondsSinceEpoch,
      data: true,
    );
  }
}
