import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../scaffold_messenger_controller.dart';
import 'auth_service.dart';

final authControllerProvider = Provider.autoDispose<AuthController>(
  (ref) => AuthController(
    authService: ref.watch(authServiceProvider),
    scaffoldMessengerController: ref.watch(scaffoldMessengerControllerProvider),
  ),
);

class AuthController {
  const AuthController({
    required AuthService authService,
    required ScaffoldMessengerController scaffoldMessengerController,
  })  : _authService = authService,
        _scaffoldMessengerController = scaffoldMessengerController;

  final AuthService _authService;
  final ScaffoldMessengerController _scaffoldMessengerController;

  /// 選択された [SignInMethod] でログインする。
  Future<void> signIn(SignInMethod authenticator) async {
    switch (authenticator) {
      case SignInMethod.google:
        try {
          await _authService.signInWithGoogle();
        }
        // キャンセル時
        on PlatformException catch (e) {
          if (e.code == 'network_error') {
            _scaffoldMessengerController.showSnackBarByException(e);
          }
          _scaffoldMessengerController.showSnackBarByException(e);
        }

      case SignInMethod.apple:
        // Apple はキャンセルやネットワークエラーの判定ができないので、try-catchしない
        await _authService.signInWithApple();
      default:
        throw UnimplementedError();
    }

    _scaffoldMessengerController.showSnackBar('ログインしました');
    return;
  }

  /// [FirebaseAuth] からログアウトする。
  Future<void> signOut() async {
    _authService.signOut();

    _scaffoldMessengerController.showSnackBar('ログアウトしました');
    return;
  }
}
