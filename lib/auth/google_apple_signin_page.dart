import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sign_in_button/sign_in_button.dart';

import '../map_view.dart';
import 'auth_service.dart';
import 'auth_controller.dart';

class GoogleAppleSigninPage extends ConsumerWidget {
  const GoogleAppleSigninPage({super.key});

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
                    Navigator.of(context).pushReplacement(
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) {
                          return const MapView();
                        },
                      ),
                    );
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
                    Navigator.of(context).pushReplacement(
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) {
                          return const MapView();
                        },
                      ),
                    );
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
