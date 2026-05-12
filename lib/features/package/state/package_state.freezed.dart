// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'package_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$VillagePackage {

 String get id; String get name; String get sender; String get receiver; String get address; int get reward; PackageStatus get status; List<String> get timeline; String? get courier; double get lat; double get lng;
/// Create a copy of VillagePackage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VillagePackageCopyWith<VillagePackage> get copyWith => _$VillagePackageCopyWithImpl<VillagePackage>(this as VillagePackage, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VillagePackage&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.sender, sender) || other.sender == sender)&&(identical(other.receiver, receiver) || other.receiver == receiver)&&(identical(other.address, address) || other.address == address)&&(identical(other.reward, reward) || other.reward == reward)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.timeline, timeline)&&(identical(other.courier, courier) || other.courier == courier)&&(identical(other.lat, lat) || other.lat == lat)&&(identical(other.lng, lng) || other.lng == lng));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,sender,receiver,address,reward,status,const DeepCollectionEquality().hash(timeline),courier,lat,lng);

@override
String toString() {
  return 'VillagePackage(id: $id, name: $name, sender: $sender, receiver: $receiver, address: $address, reward: $reward, status: $status, timeline: $timeline, courier: $courier, lat: $lat, lng: $lng)';
}


}

/// @nodoc
abstract mixin class $VillagePackageCopyWith<$Res>  {
  factory $VillagePackageCopyWith(VillagePackage value, $Res Function(VillagePackage) _then) = _$VillagePackageCopyWithImpl;
@useResult
$Res call({
 String id, String name, String sender, String receiver, String address, int reward, PackageStatus status, List<String> timeline, String? courier, double lat, double lng
});




}
/// @nodoc
class _$VillagePackageCopyWithImpl<$Res>
    implements $VillagePackageCopyWith<$Res> {
  _$VillagePackageCopyWithImpl(this._self, this._then);

  final VillagePackage _self;
  final $Res Function(VillagePackage) _then;

/// Create a copy of VillagePackage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? sender = null,Object? receiver = null,Object? address = null,Object? reward = null,Object? status = null,Object? timeline = null,Object? courier = freezed,Object? lat = null,Object? lng = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,sender: null == sender ? _self.sender : sender // ignore: cast_nullable_to_non_nullable
as String,receiver: null == receiver ? _self.receiver : receiver // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,reward: null == reward ? _self.reward : reward // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PackageStatus,timeline: null == timeline ? _self.timeline : timeline // ignore: cast_nullable_to_non_nullable
as List<String>,courier: freezed == courier ? _self.courier : courier // ignore: cast_nullable_to_non_nullable
as String?,lat: null == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double,lng: null == lng ? _self.lng : lng // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [VillagePackage].
extension VillagePackagePatterns on VillagePackage {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VillagePackage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VillagePackage() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VillagePackage value)  $default,){
final _that = this;
switch (_that) {
case _VillagePackage():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VillagePackage value)?  $default,){
final _that = this;
switch (_that) {
case _VillagePackage() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String sender,  String receiver,  String address,  int reward,  PackageStatus status,  List<String> timeline,  String? courier,  double lat,  double lng)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VillagePackage() when $default != null:
return $default(_that.id,_that.name,_that.sender,_that.receiver,_that.address,_that.reward,_that.status,_that.timeline,_that.courier,_that.lat,_that.lng);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String sender,  String receiver,  String address,  int reward,  PackageStatus status,  List<String> timeline,  String? courier,  double lat,  double lng)  $default,) {final _that = this;
switch (_that) {
case _VillagePackage():
return $default(_that.id,_that.name,_that.sender,_that.receiver,_that.address,_that.reward,_that.status,_that.timeline,_that.courier,_that.lat,_that.lng);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String sender,  String receiver,  String address,  int reward,  PackageStatus status,  List<String> timeline,  String? courier,  double lat,  double lng)?  $default,) {final _that = this;
switch (_that) {
case _VillagePackage() when $default != null:
return $default(_that.id,_that.name,_that.sender,_that.receiver,_that.address,_that.reward,_that.status,_that.timeline,_that.courier,_that.lat,_that.lng);case _:
  return null;

}
}

}

/// @nodoc


class _VillagePackage implements VillagePackage {
  const _VillagePackage({required this.id, required this.name, required this.sender, required this.receiver, required this.address, required this.reward, required this.status, required final  List<String> timeline, this.courier, required this.lat, required this.lng}): _timeline = timeline;
  

@override final  String id;
@override final  String name;
@override final  String sender;
@override final  String receiver;
@override final  String address;
@override final  int reward;
@override final  PackageStatus status;
 final  List<String> _timeline;
@override List<String> get timeline {
  if (_timeline is EqualUnmodifiableListView) return _timeline;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_timeline);
}

@override final  String? courier;
@override final  double lat;
@override final  double lng;

/// Create a copy of VillagePackage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VillagePackageCopyWith<_VillagePackage> get copyWith => __$VillagePackageCopyWithImpl<_VillagePackage>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VillagePackage&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.sender, sender) || other.sender == sender)&&(identical(other.receiver, receiver) || other.receiver == receiver)&&(identical(other.address, address) || other.address == address)&&(identical(other.reward, reward) || other.reward == reward)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._timeline, _timeline)&&(identical(other.courier, courier) || other.courier == courier)&&(identical(other.lat, lat) || other.lat == lat)&&(identical(other.lng, lng) || other.lng == lng));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,sender,receiver,address,reward,status,const DeepCollectionEquality().hash(_timeline),courier,lat,lng);

@override
String toString() {
  return 'VillagePackage(id: $id, name: $name, sender: $sender, receiver: $receiver, address: $address, reward: $reward, status: $status, timeline: $timeline, courier: $courier, lat: $lat, lng: $lng)';
}


}

/// @nodoc
abstract mixin class _$VillagePackageCopyWith<$Res> implements $VillagePackageCopyWith<$Res> {
  factory _$VillagePackageCopyWith(_VillagePackage value, $Res Function(_VillagePackage) _then) = __$VillagePackageCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String sender, String receiver, String address, int reward, PackageStatus status, List<String> timeline, String? courier, double lat, double lng
});




}
/// @nodoc
class __$VillagePackageCopyWithImpl<$Res>
    implements _$VillagePackageCopyWith<$Res> {
  __$VillagePackageCopyWithImpl(this._self, this._then);

  final _VillagePackage _self;
  final $Res Function(_VillagePackage) _then;

/// Create a copy of VillagePackage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? sender = null,Object? receiver = null,Object? address = null,Object? reward = null,Object? status = null,Object? timeline = null,Object? courier = freezed,Object? lat = null,Object? lng = null,}) {
  return _then(_VillagePackage(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,sender: null == sender ? _self.sender : sender // ignore: cast_nullable_to_non_nullable
as String,receiver: null == receiver ? _self.receiver : receiver // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,reward: null == reward ? _self.reward : reward // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PackageStatus,timeline: null == timeline ? _self._timeline : timeline // ignore: cast_nullable_to_non_nullable
as List<String>,courier: freezed == courier ? _self.courier : courier // ignore: cast_nullable_to_non_nullable
as String?,lat: null == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double,lng: null == lng ? _self.lng : lng // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

/// @nodoc
mixin _$PackageState {

 List<VillagePackage> get packages; int get nextPackageNo;
/// Create a copy of PackageState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PackageStateCopyWith<PackageState> get copyWith => _$PackageStateCopyWithImpl<PackageState>(this as PackageState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PackageState&&const DeepCollectionEquality().equals(other.packages, packages)&&(identical(other.nextPackageNo, nextPackageNo) || other.nextPackageNo == nextPackageNo));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(packages),nextPackageNo);

@override
String toString() {
  return 'PackageState(packages: $packages, nextPackageNo: $nextPackageNo)';
}


}

/// @nodoc
abstract mixin class $PackageStateCopyWith<$Res>  {
  factory $PackageStateCopyWith(PackageState value, $Res Function(PackageState) _then) = _$PackageStateCopyWithImpl;
@useResult
$Res call({
 List<VillagePackage> packages, int nextPackageNo
});




}
/// @nodoc
class _$PackageStateCopyWithImpl<$Res>
    implements $PackageStateCopyWith<$Res> {
  _$PackageStateCopyWithImpl(this._self, this._then);

  final PackageState _self;
  final $Res Function(PackageState) _then;

/// Create a copy of PackageState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? packages = null,Object? nextPackageNo = null,}) {
  return _then(_self.copyWith(
packages: null == packages ? _self.packages : packages // ignore: cast_nullable_to_non_nullable
as List<VillagePackage>,nextPackageNo: null == nextPackageNo ? _self.nextPackageNo : nextPackageNo // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PackageState].
extension PackageStatePatterns on PackageState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PackageState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PackageState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PackageState value)  $default,){
final _that = this;
switch (_that) {
case _PackageState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PackageState value)?  $default,){
final _that = this;
switch (_that) {
case _PackageState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<VillagePackage> packages,  int nextPackageNo)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PackageState() when $default != null:
return $default(_that.packages,_that.nextPackageNo);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<VillagePackage> packages,  int nextPackageNo)  $default,) {final _that = this;
switch (_that) {
case _PackageState():
return $default(_that.packages,_that.nextPackageNo);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<VillagePackage> packages,  int nextPackageNo)?  $default,) {final _that = this;
switch (_that) {
case _PackageState() when $default != null:
return $default(_that.packages,_that.nextPackageNo);case _:
  return null;

}
}

}

/// @nodoc


class _PackageState implements PackageState {
  const _PackageState({final  List<VillagePackage> packages = const [], this.nextPackageNo = 4}): _packages = packages;
  

 final  List<VillagePackage> _packages;
@override@JsonKey() List<VillagePackage> get packages {
  if (_packages is EqualUnmodifiableListView) return _packages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_packages);
}

@override@JsonKey() final  int nextPackageNo;

/// Create a copy of PackageState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PackageStateCopyWith<_PackageState> get copyWith => __$PackageStateCopyWithImpl<_PackageState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PackageState&&const DeepCollectionEquality().equals(other._packages, _packages)&&(identical(other.nextPackageNo, nextPackageNo) || other.nextPackageNo == nextPackageNo));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_packages),nextPackageNo);

@override
String toString() {
  return 'PackageState(packages: $packages, nextPackageNo: $nextPackageNo)';
}


}

/// @nodoc
abstract mixin class _$PackageStateCopyWith<$Res> implements $PackageStateCopyWith<$Res> {
  factory _$PackageStateCopyWith(_PackageState value, $Res Function(_PackageState) _then) = __$PackageStateCopyWithImpl;
@override @useResult
$Res call({
 List<VillagePackage> packages, int nextPackageNo
});




}
/// @nodoc
class __$PackageStateCopyWithImpl<$Res>
    implements _$PackageStateCopyWith<$Res> {
  __$PackageStateCopyWithImpl(this._self, this._then);

  final _PackageState _self;
  final $Res Function(_PackageState) _then;

/// Create a copy of PackageState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? packages = null,Object? nextPackageNo = null,}) {
  return _then(_PackageState(
packages: null == packages ? _self._packages : packages // ignore: cast_nullable_to_non_nullable
as List<VillagePackage>,nextPackageNo: null == nextPackageNo ? _self.nextPackageNo : nextPackageNo // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
