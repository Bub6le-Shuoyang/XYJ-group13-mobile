import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../core/models/app_role.dart';
import '../../../core/models/auth_models.dart';

part 'auth_state.freezed.dart';

@freezed
abstract class AuthState with _$AuthState {
  const factory AuthState({
    @Default(null) AppRole? role,
    @Default(false) bool isLoading,
    @Default(null) UserVO? user,
  }) = _AuthState;
}
