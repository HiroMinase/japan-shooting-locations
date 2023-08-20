import 'package:flutter/material.dart';

import 'color_table.dart';
import 'marker_data.dart';

class ExifTableContainer extends StatelessWidget {
  const ExifTableContainer({
    super.key,
    required this.markerdata,
  });

  final MarkerData markerdata;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
      child: Table(
        border: TableBorder(
          top: BorderSide(
            color: ColorTable.primaryBlackColor[100] as Color,
            width: 1.0,
          ),
          horizontalInside: BorderSide(
            color: ColorTable.primaryBlackColor[100] as Color,
            width: 1.0,
          ),
          bottom: BorderSide(
            color: ColorTable.primaryBlackColor[100] as Color,
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
              VerticalPaddingTableCell(verticalPaddingValue: 3.0, text: markerdata.focalLength, fontSizeValue: 14.0),
            ],
          ),
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
