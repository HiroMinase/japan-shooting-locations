import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/material.dart";
import "package:geoflutterfire_plus/geoflutterfire_plus.dart";
import "package:google_maps_flutter/google_maps_flutter.dart";

/// AlertDialog widget to add location data to Cloud Firestore.
class AddLocationDialog extends StatefulWidget {
  const AddLocationDialog({super.key, this.latLng});

  final LatLng? latLng;

  @override
  AddLocationDialogState createState() => AddLocationDialogState();
}

class AddLocationDialogState extends State<AddLocationDialog> {
  final _nameEditingController = TextEditingController();
  final _latitudeEditingController = TextEditingController();
  final _longitudeEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.latLng != null) {
      _latitudeEditingController.text = widget.latLng!.latitude.toString();
      _longitudeEditingController.text = widget.latLng!.longitude.toString();
    }
  }

  @override
  void dispose() {
    _nameEditingController.dispose();
    _latitudeEditingController.dispose();
    _longitudeEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Center(
        child: Text("ロケーションを登録"),
      ),
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameEditingController,
            keyboardType: TextInputType.name,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              label: const Text("名前"),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _latitudeEditingController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              label: const Text("緯度"),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _longitudeEditingController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              label: const Text("経度"),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final name = _nameEditingController.value.text;
              if (name.isEmpty) {
                throw Exception("名前を入力してください");
              }
              final latitude = double.tryParse(_latitudeEditingController.value.text);
              final longitude = double.tryParse(_longitudeEditingController.value.text);
              if (latitude == null || longitude == null) {
                throw Exception(
                  "緯度経度に不正な値があります",
                );
              }
              try {
                await _addLocation(
                  name,
                  latitude,
                  longitude,
                );
              } on Exception catch (e) {
                debugPrint(
                  "🚨 ロケーション作成に失敗 $e",
                );
              }
              navigator.pop();
            },
            child: const Text("作成"),
          ),
        ],
      ),
    );
  }

  /// Adds location data to Cloud Firestore.
  Future<void> _addLocation(
    String name,
    double latitude,
    double longitude,
  ) async {
    final geoFirePoint = GeoFirePoint(GeoPoint(latitude, longitude));
    await GeoCollectionReference<Map<String, dynamic>>(
      FirebaseFirestore.instance.collection("locations"),
    ).add(<String, dynamic>{
      "geo": geoFirePoint.data,
      "name": name,
      "isVisible": true,
    });
    debugPrint(
      "🌍 ロケーションを作成: "
      "name: $name"
      "lat: $latitude, "
      "lng: $longitude, "
      "geohash: ${geoFirePoint.geohash}",
    );
  }
}
