import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/app_role.dart';
import '../../../services/auth_service.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._authService) : super(const AuthState());

  final AuthService _authService;

  Future<void> login(AppRole role, String account, String password) async {
    if (account.trim().isEmpty || password.trim().isEmpty) {
      throw Exception('请输入账号和密码');
    }

    emit(state.copyWith(isLoading: true));
    final result = await _authService.login(role, account, password);

    if (result.isSuccess && result.data != null) {
      emit(
        state.copyWith(isLoading: false, role: role, user: result.data!.user),
      );
    } else {
      emit(state.copyWith(isLoading: false));
      throw Exception(result.message);
    }
  }

  Future<void> loginAsAdmin(String email, String password) async {
    await login(AppRole.admin, email, password);
  }

  Future<void> loginAsStaff(
    AppRole role,
    String account,
    String password,
  ) async {
    await login(role, account, password);
  }

  Future<void> register({
    required AppRole role,
    required String email,
    required String emailCode,
    required String password,
    required String confirmPassword,
  }) async {
    if (email.trim().isEmpty ||
        emailCode.trim().isEmpty ||
        password.trim().isEmpty ||
        confirmPassword.trim().isEmpty) {
      throw Exception('请完整填写注册信息');
    }
    if (password != confirmPassword) {
      throw Exception('两次输入的密码不一致');
    }

    emit(state.copyWith(isLoading: true));
    final result = await _authService.register(
      role: role,
      email: email,
      emailCode: emailCode,
      password: password,
      confirmPassword: confirmPassword,
    );

    if (result.isSuccess && result.data != null) {
      emit(
        state.copyWith(isLoading: false, role: role, user: result.data!.user),
      );
    } else {
      emit(state.copyWith(isLoading: false));
      throw Exception(result.message);
    }
  }

  void logout() {
    emit(const AuthState());
  }
}
