

// inside build:
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_api_app/feature/home/presentation/view/homePageScreen.dart';
import 'package:news_api_app/feature/auth/presentation/auth_controller.dart';
import 'package:news_api_app/feature/auth/presentation/login_page_ui.dart';
import 'package:news_api_app/feature/auth/spalsh_screen/splash_screen_ui.dart';
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);

    // Only the very first session check shows the splash.
    if (auth.isLoading && !auth.hasValue && !auth.hasError) {
      return const SplashScreenUi();
    }

    return auth.value != null ? const Homepagescreen() : const LoginPage();
  }
}




