import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/app_role.dart';
import '../../../services/auth_service.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._authService) : super(const AuthState());

  final AuthService _authService;

  Future<void> loginAsAdmin(String email, String password) async {
    emit(state.copyWith(isLoading: true));
    final result = await _authService.login(email, password);

    if (result.isSuccess) {
      emit(
        state.copyWith(
          isLoading: false,
          role: AppRole.admin,
          user: result.data?.user,
        ),
      );
    } else {
      emit(state.copyWith(isLoading: false));
      // Throw error to be caught by UI
      throw Exception(result.message);
    }
  }

  void forceLogin(AppRole role) {
    emit(state.copyWith(role: role));
  }

  void logout() {
    emit(const AuthState());
  }
}
