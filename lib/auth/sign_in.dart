import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sign_in_button/sign_in_button.dart';

import '../color_table.dart';
import '../map_view.dart';
import 'auth_service.dart';
import 'auth_controller.dart';

@RoutePage()
class SignIn extends ConsumerWidget {
  const SignIn({super.key});

  /// [AutoRoute] で指定するパス文字列。
  static const path = '/signIn';

  /// [SignIn] に遷移する際に `context.router.pushNamed` で指定する文字列。
  static const location = path;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(-1.2, -0.5),
            end: Alignment(2.0, 1.0),
            stops: [0.2, 0.8],
            colors: [
              ColorTable.lightGradientBeginColor,
              ColorTable.lightGradientEndColor,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 30.0),
              child: const Text(
                "登録方法を選ぶ",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Google
            Container(
              height: 50,
              margin: const EdgeInsets.symmetric(vertical: 10.0),
              child: SignInButton(
                Buttons.google,
                text: 'Google でサインイン',
                onPressed: () async {
                  await ref.read(authControllerProvider).signIn(SignInMethod.google);

                  final isSignIn = ref.watch(isSignedInProvider);
                  if (isSignIn && context.mounted) {
                    context.router.pushNamed(MapView.location);
                  }
                },
              ),
            ),
            // Apple
            Container(
              height: 50,
              margin: const EdgeInsets.symmetric(vertical: 10.0),
              child: SignInButton(
                Buttons.apple,
                text: 'Apple でサインイン',
                onPressed: () async {
                  await ref.read(authControllerProvider).signIn(SignInMethod.apple);

                  final isSignIn = ref.watch(isSignedInProvider);
                  if (isSignIn && context.mounted) {
                    context.router.pushNamed(MapView.location);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
