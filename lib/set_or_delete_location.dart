import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:geoflutterfire_plus/geoflutterfire_plus.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:japan_shooting_locations/auth/auth_service.dart";
import "package:japan_shooting_locations/marker_data.dart";

import "delete_location.dart";
import "exif_table_container.dart";
import "set_location.dart";

// 撮影スポットの詳細ダイアログ
class SetOrDeleteLocationDialog extends ConsumerWidget {
  const SetOrDeleteLocationDialog({
    super.key,
    required this.geoFirePoint,
    required this.markerdata,
  });

  final GeoFirePoint geoFirePoint;
  final MarkerData markerdata;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      content: Column(
        mainAxisAlignment: MainAxisAlignment.start,
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
              imageUrl: markerdata.imageUrl,
              placeholder: (context, url) => const SizedBox(
                width: 50,
                height: 50,
                child: Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  markerdata.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ExifTableContainer(markerdata: markerdata),
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
                        imageUrl: markerdata.imageUrl,
                      ),
                    ),
                    child: const Text("編集する"),
                  ),
                  if (ref.watch(userIdProvider) == markerdata.userId)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () => showDialog<void>(
                        context: context,
                        builder: (_) => DeleteLocationDialog(
                          id: markerdata.firestoreDocumentId,
                          name: markerdata.name,
                          imageUrl: markerdata.imageUrl,
                        ),
                      ),
                      child: const Text("削除する"),
                    ),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}
