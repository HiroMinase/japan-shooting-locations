import "dart:async";

import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_core/firebase_core.dart";
import "package:flutter/material.dart";
import "package:geoflutterfire_plus/geoflutterfire_plus.dart";
import "package:google_maps_flutter/google_maps_flutter.dart";
import "package:rxdart/rxdart.dart";

import "add_location.dart";
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
  void _updateMarkersByDocumentSnapshots(
    List<DocumentSnapshot<Map<String, dynamic>>> documentSnapshots,
  ) {
    final markers = <Marker>{};
    for (final ds in documentSnapshots) {
      final id = ds.id;
      final data = ds.data();
      if (data == null) {
        continue;
      }
      final name = data["name"] as String;
      final geoPoint = (data["geo"] as Map<String, dynamic>)["geopoint"] as GeoPoint;
      markers.add(_createMarker(id: id, name: name, geoPoint: geoPoint));
    }
    debugPrint("📍 ピンの数: ${markers.length}");
    setState(() {
      _markers = markers;
    });
  }

  // マップに落とすマーカーを作成
  Marker _createMarker({
    required String id,
    required String name,
    required GeoPoint geoPoint,
  }) =>
      Marker(
        markerId: MarkerId("(${geoPoint.latitude}, ${geoPoint.longitude})"),
        position: LatLng(geoPoint.latitude, geoPoint.longitude),
        infoWindow: InfoWindow(title: name),
        onTap: () => showDialog<void>(
          context: context,
          builder: (context) => SetOrDeleteLocationDialog(
            id: id,
            name: name,
            geoFirePoint: GeoFirePoint(
              GeoPoint(geoPoint.latitude, geoPoint.longitude),
            ),
          ),
        ),
      );

  // 現在の検索半径をセット
  double get _radiusInKm => _geoQueryCondition.value.radiusInKm;

  // 現在のカメラ位置をセット
  CameraPosition get _cameraPosition => _geoQueryCondition.value.cameraPosition;

  // デフォルトの検索半径
  static const double _initialRadiusInKm = 1;

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
            onMapCreated: (_) => _stream.listen(_updateMarkersByDocumentSnapshots),
            markers: _markers,
            circles: {
              Circle(
                circleId: const CircleId("value"),
                center: LatLng(
                  _cameraPosition.target.latitude,
                  _cameraPosition.target.longitude,
                ),
                // キロメートルからメートルへの変換
                radius: _radiusInKm * 1000,
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
                  "検索半径: ${_radiusInKm.toStringAsFixed(1)} (km)",
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
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog<void>(
          context: context,
          builder: (context) => const AddLocationDialog(),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
