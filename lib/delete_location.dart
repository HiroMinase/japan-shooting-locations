import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_storage/firebase_storage.dart";
import "package:flutter/material.dart";
import "package:geoflutterfire_plus/geoflutterfire_plus.dart";

// ロケーション削除用のダイアログ
class DeleteLocationDialog extends StatelessWidget {
  const DeleteLocationDialog({
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
  Widget build(BuildContext context) {
    return AlertDialog(
      // title: const Text("撮影地を削除しますか？"),
      title: Image.network(imageUrl, height: 200, fit: BoxFit.cover),
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("名前: $name"),
          const SizedBox(height: 8),
          Text("緯度: ${geoFirePoint.latitude}"),
          const SizedBox(height: 8),
          Text("経度: ${geoFirePoint.longitude}"),
          const SizedBox(height: 8),
          Align(
            child: ElevatedButton(
              onPressed: () async {
                final navigator = Navigator.of(context);
                try {
                  await _deleteLocationWithImage(id, imagePath);
                } on Exception catch (e) {
                  debugPrint(
                    "🚨 ロケーション削除に失敗 $e",
                  );
                }
                navigator.popUntil((route) => route.isFirst);
              },
              child: const Text("削除"),
            ),
          ),
        ],
      ),
    );
  }

  /// Deletes location data from Cloud Firestore.
  Future<void> _deleteLocationWithImage(String id, String imagePath) async {
    await GeoCollectionReference<Map<String, dynamic>>(
      FirebaseFirestore.instance.collection("locations"),
    ).delete(id);
    await FirebaseStorage.instance.refFromURL(imageUrl).delete();

    debugPrint(
      "🌍 ロケーションを削除 id: $id",
    );
  }
}
