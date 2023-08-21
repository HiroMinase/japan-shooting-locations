import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sign_in_button/sign_in_button.dart';

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
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
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
                  ref.read(authControllerProvider).signIn(SignInMethod.apple);

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
