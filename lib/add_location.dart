import "dart:io";

import "package:cloud_firestore/cloud_firestore.dart";
import "package:file_picker/file_picker.dart";
import 'package:exif/exif.dart';
import "package:firebase_storage/firebase_storage.dart";
import "package:flutter/material.dart";
import "package:geoflutterfire_plus/geoflutterfire_plus.dart";
import "package:google_maps_flutter/google_maps_flutter.dart";
import "package:japan_shooting_locations/marker_data.dart";

import "color_table.dart";
import "exif_table_container.dart";

// 撮影スポット作成用のダイアログ
class AddLocationDialog extends StatefulWidget {
  const AddLocationDialog({super.key, this.latLng});

  final LatLng? latLng;

  @override
  AddLocationDialogState createState() => AddLocationDialogState();
}

class AddLocationDialogState extends State<AddLocationDialog> {
  final _nameEditingController = TextEditingController();
  late double latitude;
  late double longitude;
  File? imageFile;
  MarkerData markerdata = MarkerData(
    firestoreDocumentId: "",
    name: "",
    imageUrl: "",
    camera: "",
    software: "",
    dateTime: "",
    shutterSpeed: "",
    fNumber: "",
    iso: "",
    focalLength: "",
  );
  String imageUploadedUrl = "";
  String camera = "";
  String software = "";
  String dateTime = "";
  String shutterSpeed = "";
  String fNumber = "";
  String iso = "";
  String focalLength = "";

  @override
  void initState() {
    latitude = widget.latLng!.latitude;
    longitude = widget.latLng!.longitude;

    super.initState();
  }

  @override
  void dispose() {
    _nameEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Center(
        child: Text("撮影スポットを登録"),
      ),
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameEditingController,
            keyboardType: TextInputType.name,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              label: const Text("名前"),
            ),
          ),
          const SizedBox(height: 16),
          if (imageFile != null) Image.file(imageFile!, height: MediaQuery.of(context).size.height * 0.2),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              _importImage();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow),
            child: Text(
              "写真を選ぶ",
              style: TextStyle(color: ColorTable.primaryBlackColor[400]),
            ),
          ),
          const SizedBox(height: 16),
          ExifTableContainer(markerdata: markerdata),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final name = _nameEditingController.value.text;
              if (name.isEmpty) {
                throw Exception("名前を入力してください");
              }
              if (imageFile == null) {
                throw Exception("写真を選択してください");
              }
              try {
                await _addLocation(name, latitude, longitude, imageFile!, markerdata);
              } on Exception catch (e) {
                debugPrint(
                  "🚨 撮影スポット作成に失敗 $e",
                );
              }
              navigator.pop();
            },
            child: const Text(
              "作成",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  //　Firestore に登録
  Future<void> _addLocation(
    String name,
    double latitude,
    double longitude,
    File file,
    MarkerData markerdata,
  ) async {
    final geoFirePoint = GeoFirePoint(GeoPoint(latitude, longitude));

    final uploadedLink = await _uploadImage(file);

    await GeoCollectionReference<Map<String, dynamic>>(
      FirebaseFirestore.instance.collection("locations"),
    ).add(<String, dynamic>{
      "geo": geoFirePoint.data,
      "name": name,
      "imageUrl": uploadedLink,
      "camera": markerdata.camera,
      "software": markerdata.software,
      "dateTime": markerdata.dateTime,
      "shutterSpeed": markerdata.shutterSpeed,
      "fNumber": markerdata.fNumber,
      "iso": markerdata.iso,
      "focalLength": markerdata.focalLength,
      "isVisible": true,
      "createdAt": Timestamp.now(),
    });
    debugPrint(
      "🌍 撮影スポットを作成: "
      "name: $name"
      "lat: $latitude, "
      "lng: $longitude, "
      "geohash: ${geoFirePoint.geohash}, "
      "imageURL: $uploadedLink, ",
    );
  }

  // 画像を選択させ、
  Future<void> _importImage() async {
    // 画像ファイルを選択
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    // 画像ファイルが選択された場合
    if (result != null) {
      setState(() {
        imageFile = File(result.files.single.path!);
      });

      final File file = File(result.files.single.path!);
      final exifData = await readExifFromBytes(await file.readAsBytes());

      exifData.forEach((key, value) {
        print("$key: $value");
      });

      final cameraFromExif = exifData["Image Model"].toString(); // カメラの種類
      final softwareFromExif = exifData["Image Software"].toString(); // 編集ソフト
      final dateTimeFromExif = exifData["EXIF DateTimeOriginal"].toString().replaceFirst(':', '-').replaceFirst(':', '-'); // 撮影日
      final shutterSpeedFromExif = exifData["EXIF ExposureTime"].toString(); // シャッタースピード
      final fNumberList = exifData["EXIF FNumber"].toString().split("/"); // F値の分数
      final fullFNumber = fNumberList.length == 2 ? int.parse(fNumberList[0]) / int.parse(fNumberList[1]) : 0.0; // 小数に変換
      final fNumberFromExif = fullFNumber == 0 ? "null" : fullFNumber.toStringAsFixed(1); // 文字列に変換
      final isoFromExif = exifData["EXIF ISOSpeedRatings"].toString(); // ISO
      final focalLengthFromExif = exifData["EXIF FocalLengthIn35mmFilm"].toString(); // レンズの焦点距離

      setState(() {
        markerdata = MarkerData(
          firestoreDocumentId: "",
          name: _nameEditingController.value.text,
          imageUrl: "",
          camera: cameraFromExif,
          software: softwareFromExif,
          dateTime: dateTimeFromExif,
          shutterSpeed: shutterSpeedFromExif,
          fNumber: fNumberFromExif,
          iso: isoFromExif,
          focalLength: "${focalLengthFromExif}mm",
        );
      });
    }
  }

  // 画像を Cloud Storage にアップロードし、 URL と Path を取得
  Future<String> _uploadImage(file) async {
    final int timestamp = DateTime.now().microsecondsSinceEpoch; // 日時をエポックミリ秒に変換
    final String fileExtension = file.path.split(".").last; // 画像パスから拡張子を取得
    final String path = "$timestamp.$fileExtension"; // 日付 + 拡張子のファイル名を生成
    final TaskSnapshot task = await FirebaseStorage.instance
        .ref()
        .child("images") // フォルダ名
        .child(path) // ファイル名
        .putFile(file); // 画像ファイル

    // アップロードした画像のURLを返す
    return await task.ref.getDownloadURL();
  }
}
