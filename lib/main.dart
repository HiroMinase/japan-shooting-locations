import "dart:async";
import "dart:ui";
import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";

import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_core/firebase_core.dart";
import "package:flutter/services.dart";
import "package:geoflutterfire_plus/geoflutterfire_plus.dart";
import "package:geolocator/geolocator.dart";
import "package:google_maps_flutter/google_maps_flutter.dart";
import "package:rxdart/rxdart.dart";

import "add_location.dart";
import "marker_data.dart";
import "set_or_delete_location.dart";

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
      title: "Japan Shooting Locations",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        sliderTheme: SliderThemeData(
          overlayShape: SliderComponentShape.noOverlay,
        ),
      ),
      home: const MapView(),
    );
  }
}

// 初期位置に使用しているSSSの座標
const shibuyaScrambleSquare = LatLng(35.6583931, 139.7023043);

// 位置データが格納されているコレクションへの参照
final _collectionReference = FirebaseFirestore.instance.collection("locations");

bool isDisplayThumbnail = false;

// 検索半径やカメラ位置などを管理
class _GeoQueryCondition {
  _GeoQueryCondition({
    required this.radiusInKm,
    required this.cameraPosition,
  });

  final double radiusInKm;
  final CameraPosition cameraPosition;
}

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  MapViewState createState() => MapViewState();
}

// GoogleMap を表示
class MapViewState extends State<MapView> {
  Set<Marker> _markers = {};
  List<MarkerData> markerDataList = []; // _markers に対応する画像やタイトル、Exif情報を持つ

  // 現在の検索半径とカメラ位置
  final _geoQueryCondition = BehaviorSubject<_GeoQueryCondition>.seeded(
    _GeoQueryCondition(
      radiusInKm: _initialRadiusInKm,
      cameraPosition: _initialCameraPosition,
    ),
  );

  // locations の Stream
  // switchMap によって最新の _GeoQueryCondition によるクエリが発行される
  late final Stream<List<DocumentSnapshot<Map<String, dynamic>>>> _stream = _geoQueryCondition.switchMap(
    (geoQueryCondition) => GeoCollectionReference(_collectionReference).subscribeWithin(
      center: GeoFirePoint(
        GeoPoint(
          _cameraPosition.target.latitude,
          _cameraPosition.target.longitude,
        ),
      ),
      radiusInKm: geoQueryCondition.radiusInKm,
      field: "geo",
      geopointFrom: (data) => (data["geo"] as Map<String, dynamic>)["geopoint"] as GeoPoint,
      queryBuilder: (query) => query.where('isVisible', isEqualTo: true),
      strictMode: true,
    ),
  );

  // Stream の更新に合わせてピンを描画し直す
  Future<void> _updateMarkersByDocumentSnapshots(
    List<DocumentSnapshot<Map<String, dynamic>>> documentSnapshots,
  ) async {
    final markers = <Marker>{};
    final List<MarkerData> dataList = [];
    for (final ds in documentSnapshots) {
      final id = ds.id;
      final data = ds.data();
      if (data == null) {
        continue;
      }
      final name = data["name"] as String;
      final geoPoint = (data["geo"] as Map<String, dynamic>)["geopoint"] as GeoPoint;
      final imageUrl = data["imageUrl"] as String;
      final imagePath = data["imagePath"] as String;

      // マーカーにサムネイルを表示する場合
      if (imageUrl != "" && isDisplayThumbnail) {
        // 画像サイズを指定しつつ、 Cloud Storage の画像を Uint8List に変換
        final Uint8List uintData = await imageToUint8List(imageUrl, 100, 100);
        // Marker の icon に渡せるように Uint8List を BitmapDescriptor に変換
        final BitmapDescriptor imageBitmapDescriptor = BitmapDescriptor.fromBytes(uintData);
        markers.add(_createImageMarker(geoPoint, imageBitmapDescriptor));
      } else {
        markers.add(_createMarker(geoPoint));
      }

      // markers に合わせ、 MarkerData も作成
      dataList.add(
        MarkerData(
          firestoreDocumentId: id,
          name: name,
          imageUrl: imageUrl,
          imagePath: imagePath,
        ),
      );
    }
    debugPrint("📍 ピンの数: ${markers.length}");
    setState(() {
      _markers = markers;
      markerDataList = dataList;
    });
  }

  // 画像URLを受け取り、 Uint8List に変換して返す
  Future<Uint8List> imageToUint8List(String imageUrl, int height, int width) async {
    final ByteData byteData = await NetworkAssetBundle(Uri.parse(imageUrl)).load(imageUrl);
    final Codec codec = await instantiateImageCodec(
      byteData.buffer.asUint8List(),
      targetHeight: height,
      targetWidth: width,
    );
    final FrameInfo uiFrameInfo = await codec.getNextFrame();

    return (await uiFrameInfo.image.toByteData(format: ImageByteFormat.png))!.buffer.asUint8List();
  }

  // マップに落とすサムネイルマーカーを作成
  Marker _createImageMarker(GeoPoint geoPoint, BitmapDescriptor imageBitmapDescriptor) {
    return Marker(
      markerId: MarkerId("(${geoPoint.latitude}, ${geoPoint.longitude})"),
      position: LatLng(geoPoint.latitude, geoPoint.longitude),
      icon: imageBitmapDescriptor,
    );
  }

  // マップに落とすマーカーを作成
  Marker _createMarker(GeoPoint geoPoint) {
    return Marker(
      markerId: MarkerId("(${geoPoint.latitude}, ${geoPoint.longitude})"),
      position: LatLng(geoPoint.latitude, geoPoint.longitude),
    );
  }

  // 現在の検索半径をセット
  double get _radiusInKm => _geoQueryCondition.value.radiusInKm;

  // 現在のカメラ位置をセット
  CameraPosition get _cameraPosition => _geoQueryCondition.value.cameraPosition;

  // デフォルトの検索半径
  static const double _initialRadiusInKm = 2;

  // Google Map の初期ズームレベル
  static const double _initialZoom = 14;

  // Google Map の初期位置
  static final LatLng _initialTarget = LatLng(
    shibuyaScrambleSquare.latitude,
    shibuyaScrambleSquare.longitude,
  );

  // Google Map の初期設定
  static final _initialCameraPosition = CameraPosition(
    target: _initialTarget,
    zoom: _initialZoom,
  );

  // PageView 用のコントローラー
  final PageController pageController = PageController(
    viewportFraction: 0.85,
  );

  // 位置情報
  late LocationPermission locationPermission;
  final Completer<GoogleMapController> _googleMapController = Completer<GoogleMapController>();

  // 現在地を取得するための権限を取得
  Future<void> _getLocationPermission() async {
    LocationPermission currentPermission;

    currentPermission = await Geolocator.requestPermission();

    setState(() {
      locationPermission = currentPermission;
    });

    _getCurrentPosition(currentPermission);
  }

  // 現在地を取得するための権限を取得
  Future<void> _getCurrentPosition(locationPermission) async {
    bool serviceEnabled;
    Position currentPosition;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error("位置情報サービスが使えない状態です");
    }

    if (locationPermission == LocationPermission.whileInUse || locationPermission == LocationPermission.always) {
      currentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      final completer = await _googleMapController.future;
      completer.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(
              currentPosition.latitude,
              currentPosition.longitude,
            ),
            zoom: _initialZoom,
          ),
        ),
      );
    } else {
      return Future.error("位置情報への権限が無いため、現在地を取得できません");
    }
  }

  @override
  void dispose() {
    _geoQueryCondition.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            zoomControlsEnabled: false,
            myLocationButtonEnabled: false,
            initialCameraPosition: _initialCameraPosition,
            onMapCreated: (GoogleMapController googleMap) {
              _googleMapController.complete(googleMap);

              _stream.listen(_updateMarkersByDocumentSnapshots);
            },
            markers: _markers,
            circles: {
              Circle(
                circleId: const CircleId("value"),
                center: LatLng(
                  _cameraPosition.target.latitude,
                  _cameraPosition.target.longitude,
                ),
                radius: _radiusInKm * 1000, // キロメートルからメートルへの変換
                fillColor: Colors.black12,
                strokeWidth: 0,
              ),
            },
            // カメラ位置の変化によって _geoQueryCondition を追加
            onCameraMove: (cameraPosition) {
              debugPrint("📷 緯度: ${cameraPosition.target.latitude}, "
                  "経度: ${cameraPosition.target.latitude}");
              _geoQueryCondition.add(
                _GeoQueryCondition(
                  radiusInKm: _radiusInKm,
                  cameraPosition: cameraPosition,
                ),
              );
            },
            onLongPress: (latLng) => showDialog<void>(
              context: context,
              builder: (context) => AddLocationDialog(latLng: latLng),
            ),
          ),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 64, left: 16, right: 16),
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                Text(
                  "範囲内のピン: ${_markers.length}個",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "検索半径: ${_radiusInKm.toStringAsFixed(1)}km",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Slider(
                  value: _radiusInKm,
                  min: 1,
                  max: 100,
                  divisions: 99,
                  label: _radiusInKm.toStringAsFixed(1),
                  // 検索半径の変化によって _geoQueryCondition を追加
                  onChanged: (value) => _geoQueryCondition.add(
                    _GeoQueryCondition(
                      radiusInKm: value,
                      cameraPosition: _cameraPosition,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.15 * 1.2),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: GestureDetector(
                onTap: () {
                  _getLocationPermission();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.yellow,
                    border: Border.all(color: Colors.white, width: 1.0),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Text(
                    "現在地を取得",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (markerDataList != [])
            Positioned(
              bottom: 0,
              child: Container(
                color: Colors.black26,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.15,
                child: Container(
                  margin: const EdgeInsets.all(5.0),
                  child: PageView.builder(
                    controller: pageController,
                    itemCount: markerDataList.length,
                    onPageChanged: (int index) async {
                      // スワイプ後のマーカー
                      // final marker = _markers.elementAt(index);

                      // _geoQueryCondition.add(
                      //   _GeoQueryCondition(
                      //     radiusInKm: _radiusInKm,
                      //     cameraPosition: CameraPosition(
                      //       target: marker.position,
                      //       zoom: _initialZoom,
                      //     ),
                      //   ),
                      // );
                    },
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          showDialog<void>(
                            context: context,
                            builder: (context) => SetOrDeleteLocationDialog(
                              id: markerDataList[index].firestoreDocumentId,
                              name: markerDataList[index].name,
                              geoFirePoint: GeoFirePoint(
                                GeoPoint(
                                  _markers.elementAt(index).position.latitude,
                                  _markers.elementAt(index).position.longitude,
                                ),
                              ),
                              imageUrl: markerDataList[index].imageUrl,
                              imagePath: markerDataList[index].imagePath,
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.all(10),
                          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              if (markerDataList[index].imageUrl != "") CachedNetworkImage(imageUrl: markerDataList[index].imageUrl),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      markerDataList[index].name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
