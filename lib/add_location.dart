import "dart:io";

import "package:cloud_firestore/cloud_firestore.dart";
import "package:file_picker/file_picker.dart";
import 'package:exif/exif.dart';
import "package:firebase_storage/firebase_storage.dart";
import "package:flutter/material.dart";
import "package:geoflutterfire_plus/geoflutterfire_plus.dart";
import "package:google_maps_flutter/google_maps_flutter.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";

import "auth/auth_service.dart";
import "color_table.dart";
import "marker_data.dart";
import "exif_data.dart";
import "exif_table_container.dart";

// 撮影スポット作成用のダイアログ
class AddLocationDialog extends ConsumerStatefulWidget {
  const AddLocationDialog({super.key, this.latLng});

  final LatLng? latLng;

  @override
  AddLocationDialogState createState() => AddLocationDialogState();
}

class AddLocationDialogState extends ConsumerState<AddLocationDialog> {
  final _nameEditingController = TextEditingController();
  late double latitude;
  late double longitude;
  File? imageFile;
  MarkerData markerdata = MarkerData(
    firestoreDocumentId: "",
    userId: "",
    name: "",
    imageUrl: "",
    cameraModel: "",
    dateTime: "",
    shutterSpeed: "",
    fNumber: "",
    iso: "",
    focalLength: "",
  );
  CollectingExifData collectingExifData = CollectingExifData(
    cameraManufacturer: null,
    cameraModel: null,
    lensManufacturer: null,
    lensModel: null,
    lensSpecification: null,
    fNumber: null,
    cameraMode: null,
    shutterSpeed: null,
    iso: null,
    dateTime: null,
    timeZone: null,
    focalLength: null,
    whiteBalance: null,
    focalLength35mm: null,
    latitudeDirection: null,
    longitudeDirection: null,
    latitude: null,
    longitude: null,
    software: null,
    imageType: null,
  );
  String imageUploadedUrl = "";
  String camera = "";
  String software = "";
  String dateTime = "";
  String shutterSpeed = "";
  String fNumber = "";
  String iso = "";
  String focalLength = "";
  bool isProgress = false;

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
      content: Stack(
        children: [
          Column(
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
                    await _addLocation(name, latitude, longitude, imageFile!, markerdata, collectingExifData);
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
          if (isProgress)
            Center(
              child: Container(
                width: 200,
                height: 200,
                color: Colors.black54,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: ColorTable.primaryWhiteColor,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  //　Firestore に登録
  Future<void> _addLocation(String name, double latitude, double longitude, File file, MarkerData markerdata, CollectingExifData collectingExifData) async {
    setState(() {
      isProgress = true;
    });

    final geoFirePoint = GeoFirePoint(GeoPoint(latitude, longitude));

    final uploadedLink = await _uploadImage(file);

    await GeoCollectionReference<Map<String, dynamic>>(
      FirebaseFirestore.instance.collection("locations"),
    ).add(<String, dynamic>{
      "userId": ref.read(userIdProvider),
      "geo": geoFirePoint.data,
      "name": name,
      "imageUrl": uploadedLink,
      "dateTime": markerdata.dateTime,
      "timeZone": collectingExifData.timeZone,
      "shutterSpeed": markerdata.shutterSpeed,
      "fNumber": markerdata.fNumber,
      "iso": markerdata.iso,
      "focalLength": markerdata.focalLength,
      "focalLength35mm": collectingExifData.focalLength35mm,
      "cameraManufacturer": collectingExifData.cameraManufacturer,
      "cameraModel": markerdata.cameraModel,
      "lensManufacturer": collectingExifData.lensManufacturer,
      "lensModel": collectingExifData.lensModel,
      "lensSpecification": collectingExifData.lensSpecification,
      "cameraMode": collectingExifData.cameraMode,
      "whiteBalance": collectingExifData.whiteBalance,
      "latitudeDirection": collectingExifData.latitudeDirection,
      "longitudeDirection": collectingExifData.longitudeDirection,
      "latitude": collectingExifData.latitude,
      "longitude": collectingExifData.longitude,
      "software": collectingExifData.software,
      "imageType": collectingExifData.imageType,
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

    setState(() {
      isProgress = false;
    });
  }

  // 画像を選択させ、 Exif を取得し、 MarkerData, CollectingExifData を生成
  Future<void> _importImage() async {
    // 画像ファイルを選択
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    // 画像ファイルが選択された場合
    if (result != null) {
      setState(() {
        imageFile = File(result.files.single.path!);

        markerdata = MarkerData(
          firestoreDocumentId: "",
          userId: "",
          name: "",
          imageUrl: "",
          cameraModel: "",
          dateTime: "",
          shutterSpeed: "",
          fNumber: "",
          iso: "",
          focalLength: "",
        );
        collectingExifData = CollectingExifData(
          cameraManufacturer: null,
          cameraModel: null,
          lensManufacturer: null,
          lensModel: null,
          lensSpecification: null,
          fNumber: null,
          cameraMode: null,
          shutterSpeed: null,
          iso: null,
          dateTime: null,
          timeZone: null,
          focalLength: null,
          whiteBalance: null,
          focalLength35mm: null,
          latitudeDirection: null,
          longitudeDirection: null,
          latitude: null,
          longitude: null,
          software: null,
          imageType: null,
        );
      });

      final File file = File(result.files.single.path!);
      final exifData = await readExifFromBytes(await file.readAsBytes());

      exifData.forEach((key, value) {
        debugPrint("$key: $value");
      });

      final String cameraManufacturerFromExif = exifData["Image Make"].toString(); // カメラメーカー
      final String cameraModelFromExif = exifData["Image Model"].toString(); // カメラ機種
      final String lensManufacturerFromExif = exifData["EXIF LensMake"].toString(); // レンズメーカー
      final String lensModelFromExif = exifData["EXIF LensModel"].toString(); // レンズ名
      final String lensSpecificationFromExif = exifData["EXIF LensSpecification"].toString(); // レンズの仕様 焦点距離・F値

      // F値が分数または数値で登録されているので変換
      String fNumberFromExif = "";
      final List<String> rawFNumberArray = exifData["EXIF FNumber"].toString().split("/"); // 保存されているF値

      if (rawFNumberArray[0] == "null") {
        fNumberFromExif = "null";
      } else {
        final dynamic calcFNumber = rawFNumberArray.length == 1 ? int.parse(rawFNumberArray[0]) : int.parse(rawFNumberArray[0]) / int.parse(rawFNumberArray[1]); // 小数か数値に変換
        fNumberFromExif = calcFNumber is int ? calcFNumber.toString() : calcFNumber.toStringAsFixed(1); // 数値ならそのまま/少数なら第一位までの、文字列に変換
      }

      final String cameraModeFromExif = exifData["EXIF ExposureProgram"].toString(); // 撮影設定
      final String shutterSpeedFromExif = exifData["EXIF ExposureTime"].toString(); // シャッタースピード
      final String isoFromExif = exifData["EXIF ISOSpeedRatings"].toString(); // ISO
      final String dateTimeFromExif = exifData["EXIF DateTimeOriginal"].toString().replaceFirst(':', '-').replaceFirst(':', '-'); // 撮影時刻
      final String timeZoneFromExif = exifData["EXIF OffsetTime"].toString(); // タイムゾーン

      // 焦点距離が分数または数値で登録されているので変換
      String focalLengthFromExif = "";
      final List<String> rawFocalLengthArray = exifData["EXIF FocalLength"].toString().split("/"); // 保存されている焦点距離

      if (rawFocalLengthArray[0] == "null") {
        focalLengthFromExif = "null";
      } else {
        final dynamic calcFocalLength = rawFocalLengthArray.length == 1 ? rawFocalLengthArray[0] : int.parse(rawFocalLengthArray[0]) / int.parse(rawFocalLengthArray[1]); // 小数か数値に変換
        focalLengthFromExif = calcFocalLength is String ? calcFocalLength : calcFocalLength.floor().toString(); // 数値ならそのまま/少数なら切り捨てて、文字列に変換
      }

      final String focalLength35mmFromExif = exifData["EXIF FocalLengthIn35mmFilm"].toString(); // 焦点距離(35mm換算)
      final String whiteBalanceFromExif = exifData["EXIF WhiteBalance"].toString(); // ホワイトバランス

      final String latitudeDirectionFromExif = exifData["GPS GPSLatitudeRef"].toString(); // 南緯 or 北緯 S なら GPSLatitude がマイナス
      final String longitudeDirectionFromExif = exifData["GPS GPSLongitudeRef"].toString(); // 東経 or 西経 W なら GPSLongitude がマイナス

      // 緯度(60進数なので10進数に変換する必要あり)
      // [24, 2403201/50000, 0] -> 24 + (2403201/50000 / 60) + (0/0 / 3600) -> 24.801067
      final List<String> latitude60thDigit = exifData["GPS GPSLatitude"].toString().replaceAll("[", "").replaceAll("]", "").split(",");
      final double latitudeFromExif =
          latitude60thDigit[0] == "null" ? 0 : int.parse(latitude60thDigit[0]) + convertStringToDouble(latitude60thDigit[1]) / 60 + convertStringToDouble(latitude60thDigit[2]) / 3600;

      // 経度(60進数なので10進数に変換する必要あり)
      // [125, 849567/50000, 0] -> 125 + (849567/50000 / 60) + (0/0 / 3600) -> 125.283189
      final List<String> longitude60thDigit = exifData["GPS GPSLongitude"].toString().replaceAll("[", "").replaceAll("]", "").split(",");
      final double longitudeFromExif =
          longitude60thDigit[0] == "null" ? 0 : int.parse(longitude60thDigit[0]) + convertStringToDouble(longitude60thDigit[1]) / 60 + convertStringToDouble(longitude60thDigit[2]) / 3600;

      final softwareFromExif = exifData["Image Software"].toString(); // 編集ソフト
      final imageTypeFromExif = exifData["Thumbnail Compression"].toString(); // 画像種別

      setState(() {
        markerdata = MarkerData(
          firestoreDocumentId: "",
          userId: ref.read(userIdProvider)!,
          name: _nameEditingController.value.text,
          imageUrl: "",
          cameraModel: cameraModelFromExif,
          dateTime: dateTimeFromExif,
          shutterSpeed: shutterSpeedFromExif,
          fNumber: fNumberFromExif,
          iso: isoFromExif,
          focalLength: "${focalLengthFromExif}mm",
        );

        collectingExifData = CollectingExifData(
          cameraManufacturer: cameraManufacturerFromExif,
          cameraModel: cameraModelFromExif,
          lensManufacturer: lensManufacturerFromExif,
          lensModel: lensModelFromExif,
          lensSpecification: lensSpecificationFromExif,
          fNumber: fNumberFromExif,
          cameraMode: cameraModeFromExif,
          shutterSpeed: shutterSpeedFromExif,
          iso: isoFromExif,
          dateTime: dateTimeFromExif,
          timeZone: timeZoneFromExif,
          focalLength: focalLengthFromExif,
          whiteBalance: whiteBalanceFromExif,
          focalLength35mm: focalLength35mmFromExif,
          latitudeDirection: latitudeDirectionFromExif,
          longitudeDirection: longitudeDirectionFromExif,
          latitude: latitudeFromExif,
          longitude: longitudeFromExif,
          software: softwareFromExif,
          imageType: imageTypeFromExif,
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

  // "/" を含む文字列を double に変換
  // "/" が含まない文字列も受け付ける
  // "9/5" -> 1.8
  // "2" -> 2.0
  double convertStringToDouble(String target) {
    var splitArray = target.split("/");
    return splitArray.length == 1 ? double.parse(splitArray[0]) : int.parse(splitArray[0]) / int.parse(splitArray[1]);
  }
}
