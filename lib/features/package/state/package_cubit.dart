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
            orderCode: 'XYJ25001',
            pickupCode: 'QJ25001',
            name: '农资工具箱',
            sender: '镇上仓库',
            receiver: '王大爷',
            address: '清河村 3 组 18 号',
            reward: 8,
            status: PackageStatus.inStock,
            timeline: ['站点完成入库', '等待管理员确认出库'],
            lat: 30.51,
            lng: 114.31,
          ),
          const VillagePackage(
            id: 'PKG-002',
            orderCode: 'XYJ25002',
            pickupCode: 'QJ25002',
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
            orderCode: 'XYJ25003',
            pickupCode: 'QJ25003',
            name: '药品快件',
            sender: '县医院',
            receiver: '赵奶奶',
            address: '清河村卫生室旁',
            reward: 12,
            status: PackageStatus.assigned,
            timeline: ['站点完成入库', '站点管理员确认出库', '骑手正在送货上门'],
            courier: '张师傅',
            lat: 30.50,
            lng: 114.30,
          ),
        ],
        nextPackageNo: 4,
      ),
    );
  }

  String addPackage(
    String name,
    String receiver,
    String address, {
    required double lat,
    required double lng,
  }) {
    final packageNo = state.nextPackageNo;
    final orderCode = 'XYJ25${packageNo.toString().padLeft(3, '0')}';
    final pickupCode = 'QJ25${packageNo.toString().padLeft(3, '0')}';

    final newPackage = VillagePackage(
      id: 'PKG-${packageNo.toString().padLeft(3, '0')}',
      orderCode: orderCode,
      pickupCode: pickupCode,
      name: name,
      sender: '当前村民',
      receiver: receiver,
      address: address,
      reward: 9,
      status: PackageStatus.pendingInbound,
      timeline: ['村民提交寄件申请，取件订单号：$orderCode'],
      lat: lat,
      lng: lng,
    );

    emit(
      state.copyWith(
        packages: [newPackage, ...state.packages],
        nextPackageNo: packageNo + 1,
      ),
    );
    return orderCode;
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

  VillagePackage? verifyInboundOrder(String orderCode) {
    final normalizedCode = orderCode.trim().toUpperCase();
    VillagePackage? matchedPackage;

    final updatedPackages = state.packages.map((package) {
      if (package.orderCode.toUpperCase() != normalizedCode) {
        return package;
      }

      matchedPackage = package;
      if (package.status != PackageStatus.pendingInbound) {
        return package;
      }

      return package.copyWith(
        status: PackageStatus.inStock,
        timeline: [...package.timeline, '管理员核验订单号，包裹完成入库'],
      );
    }).toList();

    if (matchedPackage != null) {
      emit(state.copyWith(packages: updatedPackages));
    }

    return matchedPackage;
  }

  VillagePackage? verifyPickupCode(String pickupCode) {
    final normalizedCode = pickupCode.trim().toUpperCase();
    VillagePackage? matchedPackage;

    final updatedPackages = state.packages.map((package) {
      if (package.pickupCode.toUpperCase() != normalizedCode) {
        return package;
      }

      matchedPackage = package;
      if (package.status != PackageStatus.assigned) {
        return package;
      }

      return package.copyWith(
        status: PackageStatus.completed,
        timeline: [...package.timeline, '骑手上门核验取件码，订单完成签收'],
      );
    }).toList();

    if (matchedPackage != null) {
      emit(state.copyWith(packages: updatedPackages));
    }

    return matchedPackage;
  }
}
