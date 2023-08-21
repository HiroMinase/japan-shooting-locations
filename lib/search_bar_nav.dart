import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'auth/auth_controller.dart';
import 'auth/sign_in.dart';
import 'color_table.dart';
import 'scaffold_messenger_controller.dart';

class SearchBarNav extends ConsumerWidget {
  const SearchBarNav({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 64, left: 10, right: 10),
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              color: ColorTable.primaryWhiteColor,
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  spreadRadius: 1.0,
                  blurRadius: 10.0,
                  offset: Offset(10, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      // 住所検索
                      await ref.watch(scaffoldMessengerControllerProvider).showDialogByBuilder<void>(
                            builder: (_) => const AlertDialog(
                              title: Text('住所検索について'),
                              content: Text('住所検索機能は現在開発中です。もうしばらくお待ちください。'),
                            ),
                          );
                    },
                    child: Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Icon(
                            Icons.search,
                            color: ColorTable.primaryBlackColor,
                            size: 28,
                          ),
                        ),
                        Text(
                          "ここで検索",
                          style: TextStyle(
                            fontSize: 20,
                            color: ColorTable.primaryBlackColor[300],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    // ログアウト
                    // 問い合わせ
                    await ref.watch(scaffoldMessengerControllerProvider).showDialogByBuilder<void>(
                          builder: (_) => AlertDialog(
                            title: const Text('マイページについて'),
                            content: const Text('マイページ機能は現在開発中です。もうしばらくお待ちください。'),
                            actions: [
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: ColorTable.primaryWhiteColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                onPressed: () async {
                                  await ref.read(authControllerProvider).signOut();

                                  if (context.mounted) {
                                    context.router.pushNamed(SignIn.location);
                                  }
                                },
                                icon: const Icon(
                                  Icons.logout,
                                  color: Colors.red,
                                ),
                                label: const Text(
                                  "サインアウト",
                                  style: TextStyle(
                                    color: ColorTable.primaryBlackColor,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                            ],
                            actionsAlignment: MainAxisAlignment.center,
                          ),
                        );
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Icon(
                      Icons.account_circle,
                      color: ColorTable.primaryBlackColor,
                      size: 28,
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
