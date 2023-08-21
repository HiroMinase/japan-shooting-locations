// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'router.dart';

abstract class _$AppRouter extends RootStackRouter {
  // ignore: unused_element
  _$AppRouter({super.navigatorKey});

  @override
  final Map<String, PageFactory> pagesMap = {
    MapViewRoute.name: (routeData) {
      final args = routeData.argsAs<MapViewArgs>(orElse: () => const MapViewArgs());
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: MapView(
          key: args.key,
          placeLatLng: args.placeLatLng,
        ),
      );
    },
    SearchPlaceRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const SearchPlace(),
      );
    },
    SignInRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const SignIn(),
      );
    },
    SplashScreenRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const SplashScreen(),
      );
    },
  };
}

/// generated route for
/// [MapView]
class MapViewRoute extends PageRouteInfo<MapViewArgs> {
  MapViewRoute({
    Key? key,
    LatLng? placeLatLng,
    List<PageRouteInfo>? children,
  }) : super(
          MapViewRoute.name,
          args: MapViewArgs(
            key: key,
            placeLatLng: placeLatLng,
          ),
          initialChildren: children,
        );

  static const String name = 'mapView';

  static const PageInfo<MapViewArgs> page = PageInfo<MapViewArgs>(name);
}

class MapViewArgs {
  const MapViewArgs({
    this.key,
    this.placeLatLng,
  });

  final Key? key;

  final LatLng? placeLatLng;

  @override
  String toString() {
    return 'MapViewArgs{key: $key, placeLatLng: $placeLatLng}';
  }
}

/// generated route for
/// [SearchPlace]
class SearchPlaceRoute extends PageRouteInfo<void> {
  const SearchPlaceRoute({List<PageRouteInfo>? children})
      : super(
          SearchPlaceRoute.name,
          initialChildren: children,
        );

  static const String name = 'searchPlace';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [SignIn]
class SignInRoute extends PageRouteInfo<void> {
  const SignInRoute({List<PageRouteInfo>? children})
      : super(
          SignInRoute.name,
          initialChildren: children,
        );

  static const String name = 'signIn';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [SplashScreen]
class SplashScreenRoute extends PageRouteInfo<void> {
  const SplashScreenRoute({List<PageRouteInfo>? children})
      : super(
          SplashScreenRoute.name,
          initialChildren: children,
        );

  static const String name = 'splashRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}
