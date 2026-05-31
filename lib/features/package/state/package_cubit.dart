import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../services/package_service.dart';
import 'package_state.dart';

class PackageCubit extends Cubit<PackageState> {
  PackageCubit(this._packageService) : super(const PackageState());

  final PackageService _packageService;

  void clearPackages() {
    emit(const PackageState());
  }

  Future<void> loadPackages() async {
    emit(state.copyWith(isLoading: true, message: null));
    final result = await _packageService.getPackages();
    emit(
      state.copyWith(
        packages: result.data ?? const [],
        isLoading: false,
        isFallbackData: false,
        message: result.message,
      ),
    );
  }

  Future<void> createPackage({
    required String orderNo,
    required String stationId,
    required String receiverName,
    required String receiverPhone,
    required String address,
    required double rewardAmount,
  }) async {
    final result = await _packageService.createPackage(
      orderNo: orderNo,
      stationId: stationId,
      receiverName: receiverName,
      receiverPhone: receiverPhone,
      address: address,
      rewardAmount: rewardAmount,
    );
    if (!result.isSuccess || result.data == null) {
      emit(state.copyWith(message: result.message));
      return;
    }
    emit(
      state.copyWith(
        packages: [result.data!, ...state.packages],
        message: '包裹信息已提交，等待站点管理员审批',
      ),
    );
  }

  Future<void> changeStatus(
    String packageId,
    PackageStatus status,
    String timelineText, {
    String? courier,
  }) async {
    VillagePackage? currentPackage;
    for (final package in state.packages) {
      if (package.id == packageId) {
        currentPackage = package;
        break;
      }
    }
    final result = await _packageService.updatePackageStatus(
      packageId,
      status,
      rewardAmount: currentPackage?.reward.toDouble() ?? 8,
    );
    if (!result.isSuccess || result.data != true) {
      emit(state.copyWith(message: result.message));
      return;
    }

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

    emit(
      state.copyWith(
        packages: updatedPackages,
        isFallbackData: false,
        message: result.message,
      ),
    );
  }

  Future<VillagePackage?> verifyPickupCode(String pickupCode) async {
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
      final result = await _packageService.updatePackageStatus(
        matchedPackage!.id,
        PackageStatus.completed,
        rewardAmount: matchedPackage!.reward.toDouble(),
      );
      if (!result.isSuccess || result.data != true) {
        emit(state.copyWith(message: result.message));
        return matchedPackage;
      }
      emit(
        state.copyWith(
          packages: updatedPackages,
          isFallbackData: false,
          message: result.message,
        ),
      );
    }

    return matchedPackage;
  }
}
