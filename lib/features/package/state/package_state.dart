import 'package:freezed_annotation/freezed_annotation.dart';

part 'package_state.freezed.dart';

enum PackageStatus {
  pendingInbound('待审批'),
  inStock('已审批'),
  taskPublished('待骑手接单'),
  assigned('派送中'),
  completed('已完成');

  const PackageStatus(this.label);
  final String label;
}

@freezed
abstract class VillagePackage with _$VillagePackage {
  const factory VillagePackage({
    required String id,
    required String pickupCode,
    required String name,
    required String sender,
    required String receiver,
    required String address,
    required int reward,
    required PackageStatus status,
    required List<String> timeline,
    String? courier,
    required double lat,
    required double lng,
  }) = _VillagePackage;
}

@freezed
abstract class PackageState with _$PackageState {
  const factory PackageState({
    @Default([]) List<VillagePackage> packages,
    @Default(false) bool isLoading,
    @Default(false) bool isFallbackData,
    String? message,
  }) = _PackageState;
}
