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
      content: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: 10.0),
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
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
              Text(
                markerdata.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
                child: Table(
                  border: const TableBorder(
                    top: BorderSide(
                      color: Colors.black12,
                      width: 1.0,
                    ),
                    horizontalInside: BorderSide(
                      color: Colors.black12,
                      width: 1.0,
                    ),
                    bottom: BorderSide(
                      color: Colors.black12,
                      width: 1.0,
                    ),
                  ),
                  columnWidths: const <int, TableColumnWidth>{
                    0: FlexColumnWidth(1),
                    1: FlexColumnWidth(2),
                  },
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: <TableRow>[
                    TableRow(
                      children: <Widget>[
                        const VerticalPaddingTableCell(verticalPaddingValue: 3.0, text: "カメラ", fontSizeValue: 14.0),
                        VerticalPaddingTableCell(verticalPaddingValue: 3.0, text: markerdata.camera, fontSizeValue: 14.0),
                      ],
                    ),
                    TableRow(
                      children: <Widget>[
                        const VerticalPaddingTableCell(verticalPaddingValue: 3.0, text: "SS", fontSizeValue: 14.0),
                        VerticalPaddingTableCell(verticalPaddingValue: 3.0, text: markerdata.shutterSpeed, fontSizeValue: 14.0),
                      ],
                    ),
                    TableRow(
                      children: <Widget>[
                        const VerticalPaddingTableCell(verticalPaddingValue: 3.0, text: "F値", fontSizeValue: 14.0),
                        VerticalPaddingTableCell(verticalPaddingValue: 3.0, text: markerdata.fNumber, fontSizeValue: 14.0),
                      ],
                    ),
                    TableRow(
                      children: <Widget>[
                        const VerticalPaddingTableCell(verticalPaddingValue: 3.0, text: "ISO", fontSizeValue: 14.0),
                        VerticalPaddingTableCell(verticalPaddingValue: 3.0, text: markerdata.iso, fontSizeValue: 14.0),
                      ],
                    ),
                    TableRow(
                      children: <Widget>[
                        const VerticalPaddingTableCell(verticalPaddingValue: 3.0, text: "焦点距離", fontSizeValue: 14.0),
                        VerticalPaddingTableCell(verticalPaddingValue: 3.0, text: "${markerdata.focalLength}mm", fontSizeValue: 14.0),
                      ],
                    ),
                  ],
                ),
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
          )
        ],
      ),
    );
  }
}

class VerticalPaddingTableCell extends StatelessWidget {
  const VerticalPaddingTableCell({
    required this.verticalPaddingValue,
    required this.text,
    required this.fontSizeValue,
    super.key,
  });

  final double verticalPaddingValue;
  final String text;
  final double fontSizeValue;

  @override
  Widget build(BuildContext context) {
    return TableCell(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: verticalPaddingValue),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: fontSizeValue,
          ),
        ),
      ),
    );
  }
}
