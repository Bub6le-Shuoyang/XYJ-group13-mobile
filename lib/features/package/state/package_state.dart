import 'package:freezed_annotation/freezed_annotation.dart';

part 'package_state.freezed.dart';

enum PackageStatus {
  pendingInbound('待入库'),
  inStock('已入库'),
  taskPublished('待抢单'),
  assigned('派送中'),
  readyForPickup('待取件'),
  completed('已完成');

  const PackageStatus(this.label);
  final String label;
}

@freezed
abstract class VillagePackage with _$VillagePackage {
  const factory VillagePackage({
    required String id,
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
    @Default(4) int nextPackageNo,
  }) = _PackageState;
}
