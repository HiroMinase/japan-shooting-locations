import "package:cached_network_image/cached_network_image.dart";
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
      title: imageUrl != ""
          ? CachedNetworkImage(
              imageUrl: imageUrl,
              placeholder: (context, url) => const SizedBox(
                width: 50,
                height: 50,
                child: Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            )
          : null,
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(name),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            onPressed: () => showDialog<void>(
              context: context,
              builder: (_) => SetLocationDialog(
                id: id,
                name: name,
                geoFirePoint: geoFirePoint,
                imageUrl: imageUrl,
                imagePath: imagePath,
              ),
            ),
            child: const Text("編集する"),
          ),
          const SizedBox(height: 16),
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
            child: const Text("削除する"),
          ),
        ],
      ),
    );
  }
}
