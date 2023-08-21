import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:japan_shooting_locations/auth/sign_in.dart';
import 'package:japan_shooting_locations/user/user_service.dart';

import 'auth/auth_controller.dart';
import 'auth/auth_service.dart';
import 'color_table.dart';
import 'request_form_dialog.dart';

class InfomationPanel extends ConsumerWidget {
  const InfomationPanel({
    super.key,
    required int markersCount,
  }) : _markersCount = markersCount;

  final int _markersCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(userIdProvider);
    final displayName = userId != null ? ref.watch(userDisplayNameProvider(userId)) : "";

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 64, left: 16, right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorTable.primaryBlackColor.withOpacity(0.8),
        borderRadius: const BorderRadius.all(Radius.circular(15)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Text(
            "$displayNameでログイン中",
            style: const TextStyle(
              color: ColorTable.primaryWhiteColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
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
          const SizedBox(height: 8),
          Text(
            "範囲内の撮影スポット: $_markersCount個",
            style: const TextStyle(
              color: ColorTable.primaryWhiteColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorTable.primaryWhiteColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            onPressed: () {
              showDialog<void>(
                context: context,
                builder: (context) => const RequestFormDialog(),
              );
            },
            icon: const Icon(
              Icons.emoji_objects,
              color: Colors.amber,
            ),
            label: const Text(
              "機能の要望やバグ報告",
              style: TextStyle(
                color: ColorTable.primaryBlackColor,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          )
        ],
      ),
    );
  }
}
