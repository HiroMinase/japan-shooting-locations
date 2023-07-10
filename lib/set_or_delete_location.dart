import "package:flutter/material.dart";
import "package:geoflutterfire_plus/geoflutterfire_plus.dart";

import "delete_location.dart";
import "set_location.dart";

/// AlertDialog widget to add location data to Cloud Firestore.
class SetOrDeleteLocationDialog extends StatelessWidget {
  const SetOrDeleteLocationDialog({
    super.key,
    required this.id,
    required this.name,
    required this.geoFirePoint,
  });

  final String id;
  final String name;
  final GeoFirePoint geoFirePoint;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Center(
        child: Text(name),
      ),
      content: Row(
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
              ),
            ),
            child: const Text("削除"),
          ),
        ],
      ),
    );
  }
}
