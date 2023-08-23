class CollectingExifData {
  CollectingExifData({
    this.cameraManufacturer, // カメラメーカー
    this.cameraModel, // カメラ機種
    this.lensManufacturer, // レンズメーカー
    this.lensModel, // レンズ名
    this.lensSpecification, // レンズの仕様 焦点距離・F値
    this.fNumber, // F値
    this.cameraMode, // 撮影設定
    this.shutterSpeed, // シャッタースピード
    this.iso, // ISO
    this.dateTime, // 撮影時刻
    this.timeZone, // タイムゾーン
    this.focalLength, // 焦点距離
    this.focalLength35mm, // 焦点距離(35mm換算)
    this.whiteBalance, // ホワイトバランス
    this.latitudeDirection, // 北緯か南緯
    this.longitudeDirection, // 東経か西経
    this.latitude, // 緯度
    this.longitude, // 経度
    this.software, // 編集ソフト
    this.imageType, // 画像種別
  });

  final String? cameraManufacturer;
  final String? cameraModel;
  final String? lensManufacturer;
  final String? lensModel;
  final String? lensSpecification;
  final String? fNumber;
  final String? cameraMode;
  final String? shutterSpeed;
  final String? iso;
  final String? dateTime;
  final String? timeZone;
  final String? focalLength;
  final String? whiteBalance;
  final String? focalLength35mm;
  final String? latitudeDirection;
  final String? longitudeDirection;
  final double? latitude;
  final double? longitude;
  final String? software;
  final String? imageType;
}
