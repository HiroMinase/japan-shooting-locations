import "package:flutter/material.dart";
import "package:geoflutterfire_plus/geoflutterfire_plus.dart";

import "delete_location.dart";
import "set_location.dart";

// ロケーションの詳細ダイアログ
class SetOrDeleteLocationDialog extends StatelessWidget {
  const SetOrDeleteLocationDialog({
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
      title: Image.network(imageUrl, height: 200, fit: BoxFit.cover),
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("名前: $name"),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => SetLocationDialog(
                    id: id,
                    name: name,
                    geoFirePoint: geoFirePoint,
                  ),
                ),
                child: const Text("編集"),
              ),
              const SizedBox(width: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => DeleteLocationDialog(
                    id: id,
                    name: name,
                    geoFirePoint: geoFirePoint,
                    imageUrl: imageUrl,
                    imagePath: imagePath,
                  ),
                ),
                child: const Text("削除"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
