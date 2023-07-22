import "dart:io";

import "package:cloud_firestore/cloud_firestore.dart";
import "package:file_picker/file_picker.dart";
import "package:firebase_storage/firebase_storage.dart";
import "package:flutter/material.dart";
import "package:geoflutterfire_plus/geoflutterfire_plus.dart";
import "package:google_maps_flutter/google_maps_flutter.dart";

// ロケーション作成用のダイアログ
class AddLocationDialog extends StatefulWidget {
  const AddLocationDialog({super.key, this.latLng});

  final LatLng? latLng;

  @override
  AddLocationDialogState createState() => AddLocationDialogState();
}

class AddLocationDialogState extends State<AddLocationDialog> {
  final _nameEditingController = TextEditingController();
  final _latitudeEditingController = TextEditingController();
  final _longitudeEditingController = TextEditingController();
  String imageUploadedPath = "";
  String imageUploadedUrl = "";

  @override
  void initState() {
    super.initState();
    if (widget.latLng != null) {
      _latitudeEditingController.text = widget.latLng!.latitude.toString();
      _longitudeEditingController.text = widget.latLng!.longitude.toString();
    }
  }

  @override
  void dispose() {
    _nameEditingController.dispose();
    _latitudeEditingController.dispose();
    _longitudeEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Center(
        child: Text("ロケーションを登録"),
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
          TextField(
            controller: _latitudeEditingController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              label: const Text("緯度"),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _longitudeEditingController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              label: const Text("経度"),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              _uploadImage();
            },
            child: const Text("写真を選ぶ"),
          ),
          const SizedBox(height: 16),
          // TODO: Exif 情報も保存したい
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final name = _nameEditingController.value.text;
              if (name.isEmpty) {
                throw Exception("名前を入力してください");
              }
              final latitude = double.tryParse(_latitudeEditingController.value.text);
              final longitude = double.tryParse(_longitudeEditingController.value.text);
              if (latitude == null || longitude == null) {
                throw Exception(
                  "緯度経度に不正な値があります",
                );
              }
              try {
                await _addLocation(
                  name,
                  latitude,
                  longitude,
                  imageUploadedUrl,
                  imageUploadedPath,
                );
              } on Exception catch (e) {
                debugPrint(
                  "🚨 ロケーション作成に失敗 $e",
                );
              }
              navigator.pop();
            },
            child: const Text("作成"),
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
    String imageUrl,
    String imagePath,
  ) async {
    final geoFirePoint = GeoFirePoint(GeoPoint(latitude, longitude));
    await GeoCollectionReference<Map<String, dynamic>>(
      FirebaseFirestore.instance.collection("locations"),
    ).add(<String, dynamic>{
      "geo": geoFirePoint.data,
      "name": name,
      "imageUrl": imageUrl,
      "imagePath": imagePath,
      "isVisible": true,
    });
    debugPrint(
      "🌍 ロケーションを作成: "
      "name: $name"
      "lat: $latitude, "
      "lng: $longitude, "
      "geohash: ${geoFirePoint.geohash}, "
      "imageURL: $imageUrl, "
      "imagePath: $imagePath, ",
    );
  }

  // 画像を Cloud Storage にアップロードし、 URL と Path を取得
  Future<void> _uploadImage() async {
    // 画像ファイルを選択
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    // 画像ファイルが選択された場合
    if (result != null) {
      // フォルダとファイル名を指定し画像ファイルをアップロード
      // 日時をエポックミリ秒に変換
      final int timestamp = DateTime.now().microsecondsSinceEpoch;
      // ファイルのパス
      final File file = File(result.files.single.path!);
      // パスを/で区切った最後の値をnameに入れる
      final String name = file.path.split('/').last;
      final String path = '${timestamp}_$name';
      final TaskSnapshot task = await FirebaseStorage.instance
          .ref()
          .child("images") // フォルダ名
          .child(path) // ファイル名
          .putFile(file); // 画像ファイル

      // アップロードした画像のURLを取得
      final String imageUrl = await task.ref.getDownloadURL();
      // アップロードした画像の保存先を取得
      final String imagePath = task.ref.fullPath;

      setState(() {
        imageUploadedUrl = imageUrl;
        imageUploadedPath = imagePath;
      });
    }
  }
}
