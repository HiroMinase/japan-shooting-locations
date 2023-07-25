import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:geoflutterfire_plus/geoflutterfire_plus.dart";
import "package:japan_shooting_locations/marker_data.dart";

import "delete_location.dart";
import "set_location.dart";

// ロケーションの詳細ダイアログ
class SetOrDeleteLocationDialog extends StatelessWidget {
  const SetOrDeleteLocationDialog({
    super.key,
    required this.geoFirePoint,
    required this.markerdata,
  });

  final GeoFirePoint geoFirePoint;
  final MarkerData markerdata;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: markerdata.imageUrl != ""
          ? CachedNetworkImage(
              imageUrl: markerdata.imageUrl,
              placeholder: (context, url) => const SizedBox(
                width: 50,
                height: 50,
                child: Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            )
          : null,
      content: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(markerdata.name),
            Text(
              "SS: ${markerdata.shutterSpeed}",
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              "F値: ${markerdata.fNumber}",
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              "ISO: ${markerdata.iso}",
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              "焦点距離: ${markerdata.focalLength}",
              style: const TextStyle(fontSize: 12),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (_) => SetLocationDialog(
                      id: markerdata.firestoreDocumentId,
                      name: markerdata.name,
                      geoFirePoint: geoFirePoint,
                      imageUrl: markerdata.imageUrl,
                      imagePath: markerdata.imagePath,
                    ),
                  ),
                  child: const Text("編集する"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (_) => DeleteLocationDialog(
                      id: markerdata.firestoreDocumentId,
                      name: markerdata.name,
                      geoFirePoint: geoFirePoint,
                      imageUrl: markerdata.imageUrl,
                      imagePath: markerdata.imagePath,
                    ),
                  ),
                  child: const Text("削除する"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
