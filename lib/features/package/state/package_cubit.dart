import 'package:flutter_bloc/flutter_bloc.dart';
import 'package_state.dart';

class PackageCubit extends Cubit<PackageState> {
  PackageCubit() : super(const PackageState()) {
    _initMockData();
  }

  void _initMockData() {
    emit(
      state.copyWith(
        packages: [
          const VillagePackage(
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
          const VillagePackage(
            id: 'PKG-002',
            name: '生鲜包裹',
            sender: '李阿姨',
            receiver: '县城亲友',
            address: '村口驿站',
            reward: 10,
            status: PackageStatus.pendingInbound,
            timeline: ['村民提交寄件申请'],
            lat: 30.52,
            lng: 114.32,
          ),
          const VillagePackage(
            id: 'PKG-003',
            name: '药品快件',
            sender: '县医院',
            receiver: '赵奶奶',
            address: '清河村卫生室旁',
            reward: 12,
            status: PackageStatus.readyForPickup,
            timeline: ['站点完成入库', '配送员送达站点', '等待村民取件'],
            courier: '张师傅',
            lat: 30.50,
            lng: 114.30,
          ),
        ],
        nextPackageNo: 4,
      ),
    );
  }

  void addPackage(String name, String receiver, String address) {
    final packageNo = state.nextPackageNo;

    final newPackage = VillagePackage(
      id: 'PKG-${packageNo.toString().padLeft(3, '0')}',
      name: name,
      sender: '当前村民',
      receiver: receiver,
      address: address,
      reward: 9,
      status: PackageStatus.pendingInbound,
      timeline: const ['村民提交寄件申请'],
      lat: 30.50 + (packageNo * 0.005),
      lng: 114.30 + (packageNo * 0.005),
    );

    emit(
      state.copyWith(
        packages: [newPackage, ...state.packages],
        nextPackageNo: packageNo + 1,
      ),
    );
  }

  void changeStatus(
    String packageId,
    PackageStatus status,
    String timelineText, {
    String? courier,
  }) {
    final updatedPackages = state.packages.map((package) {
      if (package.id != packageId) {
        return package;
      }
      return package.copyWith(
        status: status,
        courier: courier ?? package.courier,
        timeline: [...package.timeline, timelineText],
      );
    }).toList();

    emit(state.copyWith(packages: updatedPackages));
  }
}
