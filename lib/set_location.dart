import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/material.dart";
import "package:geoflutterfire_plus/geoflutterfire_plus.dart";

// ロケーション更新用のダイアログ
class SetLocationDialog extends StatefulWidget {
  const SetLocationDialog({
    super.key,
    required this.id,
    required this.name,
    required this.geoFirePoint,
    required this.imageUrl,
    required this.imagePath,
  });

  final String id;
  final String name;
  final GeoFirePoint geoFirePoint;
  final String imageUrl;
  final String imagePath;

  @override
  State<SetLocationDialog> createState() => _SetLocationDialogState();
}

class _SetLocationDialogState extends State<SetLocationDialog> {
  final _nameEditingController = TextEditingController();
  final _latitudeEditingController = TextEditingController();
  final _longitudeEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameEditingController.text = widget.name;
    _latitudeEditingController.text = widget.geoFirePoint.latitude.toString();
    _longitudeEditingController.text = widget.geoFirePoint.longitude.toString();
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
      title: widget.imageUrl != "" ? Image.network(widget.imageUrl, height: 200, fit: BoxFit.cover) : null,
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("${widget.name}を編集"),
          const SizedBox(height: 16),
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
              final newName = _nameEditingController.value.text;
              if (newName.isEmpty) {
                throw Exception("名前を入力してください");
              }
              final newLatitude = double.tryParse(_latitudeEditingController.text);
              final newLongitude = double.tryParse(_longitudeEditingController.text);
              if (newLatitude == null || newLongitude == null) {
                throw Exception(
                  "緯度経度に不正な値があります",
                );
              }
              try {
                await _set(
                  widget.id,
                  newName,
                  newLatitude,
                  newLongitude,
                );
              } on Exception catch (e) {
                debugPrint(
                  "🚨 ロケーション更新に失敗 $e",
                );
              }
              navigator.popUntil((route) => route.isFirst);
            },
            child: const Text("更新"),
          ),
        ],
      ),
    );
  }

  // Frestore のデータを更新
  Future<void> _set(
    String id,
    String newName,
    double newLatitude,
    double newLongitude,
  ) async {
    final geoFirePoint = GeoFirePoint(GeoPoint(newLatitude, newLongitude));
    await GeoCollectionReference<Map<String, dynamic>>(
      FirebaseFirestore.instance.collection("locations"),
    ).set(
      id: id,
      data: {
        "geo": geoFirePoint.data,
        "name": newName,
      },
      options: SetOptions(merge: true),
    );
    debugPrint(
      "🌍 ロケーションを更新: "
      "id: $id"
      "latitude: $newLatitude"
      "longitude: $newLongitude",
    );
  }
}
