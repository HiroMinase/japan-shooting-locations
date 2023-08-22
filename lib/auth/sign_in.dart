import 'dart:math';

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
    final Random random = Random();
    final int backgroundImageNum = random.nextInt(28);

    return Scaffold(
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image(
                image: AssetImage("lib/assets/images/background/$backgroundImageNum.jpg"),
                fit: BoxFit.cover,
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: Colors.black.withOpacity(0.4),
            ),
            Positioned(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 500),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Google
                      Container(
                        height: 50,
                        margin: const EdgeInsets.symmetric(vertical: 20.0),
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
                        margin: const EdgeInsets.symmetric(vertical: 20.0),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
