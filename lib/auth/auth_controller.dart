import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'auth_service.dart';

final authControllerProvider = Provider.autoDispose<AuthController>(
  (ref) => AuthController(
    authService: ref.watch(authServiceProvider),
  ),
);

class AuthController {
  const AuthController({
    required AuthService authService,
  }) : _authService = authService;

  final AuthService _authService;

  /// 選択した [SignInMethod] でサインインする。
  Future<void> signIn(SignInMethod authenticator) async {
    switch (authenticator) {
      case SignInMethod.google:
        try {
          await _authService.signInWithGoogle();
        }
        // キャンセル時
        on PlatformException catch (e) {
          if (e.code == 'network_error') {
            debugPrint("🚨 ネットワークに接続されていません $e");
          }
          debugPrint("🚨 キャンセルされました $e");
        }

      case SignInMethod.apple:
        // Apple はキャンセルやネットワークエラーの判定ができないので、try-catchしない
        await _authService.signInWithApple();
        throw UnimplementedError();
    }
    return;
  }

  /// [FirebaseAuth] からサインアウトする。
  Future<void> signOut() => _authService.signOut();
}
