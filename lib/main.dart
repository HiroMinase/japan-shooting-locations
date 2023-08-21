import "package:flutter/material.dart";

import "package:firebase_core/firebase_core.dart";
import "package:flutter_dotenv/flutter_dotenv.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";

import 'router/router.dart';
import "scaffold_messenger_controller.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await dotenv.load(fileName: ".env");
  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}

final _appRouterProvider = Provider.autoDispose<AppRouter>((_) => AppRouter());

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'フォトピン',
      theme: ThemeData(
        useMaterial3: true,
        sliderTheme: SliderThemeData(
          overlayShape: SliderComponentShape.noOverlay,
        ),
        appBarTheme: Theme.of(context).appBarTheme.copyWith(
              centerTitle: true,
              elevation: 4,
              shadowColor: Theme.of(context).shadowColor,
            ),
      ),
      debugShowCheckedModeBanner: false,
      routerConfig: ref.watch(_appRouterProvider).config(),
      builder: (context, child) {
        return Navigator(
          key: ref.watch(navigatorKeyProvider),
          onPopPage: (route, dynamic _) => false,
          pages: [
            MaterialPage<Widget>(
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                    child: ScaffoldMessenger(
                      key: ref.watch(scaffoldMessengerKeyProvider),
                      child: child!,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
