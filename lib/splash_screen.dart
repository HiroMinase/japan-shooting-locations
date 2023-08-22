import 'dart:async';
import 'dart:core';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'auth/auth_service.dart';
import 'auth/sign_in.dart';
import 'map_view.dart';
import 'color_table.dart';

@RoutePage()
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  /// [AutoRoute] で指定するパス文字列。
  static const path = '/splashScreen';

  /// [DevelopmentItemsPage] に遷移する際に `context.router.pushNamed` で指定する文字列。
  static const location = path;

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 2), () {
      if (ref.watch(isSignedInProvider)) {
        context.router.pushNamed(MapView.location);
      } else {
        context.router.pushNamed(SignIn.location);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(-1.6, -0.1),
            end: Alignment(2.5, 1.3),
            stops: [0.2, 0.7],
            colors: [
              ColorTable.lightGradientBeginColor,
              ColorTable.lightGradientEndColor,
            ],
          ),
        ),
        child: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text(
              "フォトピン",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
                color: ColorTable.primaryBlackColor,
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 30),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  "lib/assets/images/icon.png",
                  width: MediaQuery.of(context).size.width / 4,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(width: 1.0, color: ColorTable.primaryBlackColor),
                  bottom: BorderSide(width: 1.0, color: ColorTable.primaryBlackColor),
                ),
              ),
              child: const Text(
                "撮影スポット共有アプリ",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  height: 1.6,
                  letterSpacing: 3,
                  color: ColorTable.primaryBlackColor,
                ),
                // line-heightに対して上下中央に配置するため
                textHeightBehavior: TextHeightBehavior(
                  applyHeightToFirstAscent: false,
                  applyHeightToLastDescent: false,
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
