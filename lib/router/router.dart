import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../auth/sign_in.dart';
import '../map/search_place.dart';
import '../map_view.dart';
import '../splash_screen.dart';

part 'router.gr.dart';

@AutoRouterConfig()
class AppRouter extends _$AppRouter {
  @override
  final List<AutoRoute> routes = [
    AutoRoute(path: SplashScreen.path, page: SplashScreenRoute.page, initial: true),
    CustomRoute(path: SignIn.path, page: SignInRoute.page, transitionsBuilder: TransitionsBuilders.fadeIn),
    CustomRoute(path: MapView.path, page: MapViewRoute.page, transitionsBuilder: TransitionsBuilders.fadeIn),
    AutoRoute(path: SearchPlace.path, page: SearchPlaceRoute.page),
  ];
}
