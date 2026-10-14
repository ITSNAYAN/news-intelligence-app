import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_api_app/feature/auth/domain/user_data_entity.dart';
import 'package:news_api_app/feature/auth/presentation/auth_provider.dart';


class AuthController extends AsyncNotifier<UserEntity?> {
  //we use the AsyncNotifier to handle the data asynchronously 
  @override
  Future<UserEntity?> build() {
    return ref.watch(userDataRepoProvider).getCurrentUser();
  }

  Future<void> login({required String email, required String password}) async {
    // copyWithPrevious keeps the old value, so the UI stays on the login
    // page while loading instead of flashing the splash screen.
    state = const AsyncLoading<UserEntity?>();

    state = await AsyncValue.guard(
      () => ref
          .read(userDataRepoProvider)
          .login(email: email, password: password),
    );
  }

  Future<void> logout() async {
    state = await AsyncValue.guard(() async {
      await ref.read(userDataRepoProvider).onLogout();
      return null;
    });
  }
}

final authControllerProvider =
    AsyncNotifierProvider<AuthController, UserEntity?>(AuthController.new);