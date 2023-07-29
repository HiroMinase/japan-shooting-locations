import "package:cached_network_image/cached_network_image.dart";
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
    required this.imageUrl,
  });

  final String id;
  final String name;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: 10.0),
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
            ),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              placeholder: (context, url) => const SizedBox(
                width: 50,
                height: 50,
                child: Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),
          Text("$nameを削除します"),
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
