import "package:flutter/material.dart";

import "package:firebase_core/firebase_core.dart";

import "splash_screen.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "フォトピン",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        sliderTheme: SliderThemeData(
          overlayShape: SliderComponentShape.noOverlay,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
