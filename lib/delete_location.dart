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
  });

  final String id;
  final String name;
  final GeoFirePoint geoFirePoint;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: imageUrl != "" ? Image.network(imageUrl, height: 200, fit: BoxFit.cover) : null,
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("$nameを削除します"),
          const SizedBox(height: 16),
          Text("緯度: ${geoFirePoint.latitude}"),
          const SizedBox(height: 16),
          Text("経度: ${geoFirePoint.longitude}"),
          const SizedBox(height: 16),
          Align(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                final navigator = Navigator.of(context);
                try {
                  await _deleteLocationWithImage(id, imageUrl);
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

  // location を Firestore から削除し、画像を Cloud Storage から削除
  Future<void> _deleteLocationWithImage(String id, String imageUrl) async {
    await GeoCollectionReference<Map<String, dynamic>>(
      FirebaseFirestore.instance.collection("locations"),
    ).delete(id);
    if (imageUrl != "") {
      await FirebaseStorage.instance.refFromURL(imageUrl).delete();
    }

    debugPrint(
      "🌍 ロケーションを削除 id: $id",
    );
  }
}
