class MarkerData {
  MarkerData({
    required this.firestoreDocumentId,
    required this.name,
    required this.imageUrl,
    required this.imagePath,
    required this.camera,
    required this.software,
    required this.dateTime,
    required this.shutterSpeed,
    required this.fNumber,
    required this.iso,
    required this.focalLength,
  });

  final String firestoreDocumentId;
  final String name;
  final String imageUrl;
  final String imagePath;
  final String camera;
  final String software;
  final String dateTime;
  final String shutterSpeed;
  final String fNumber;
  final String iso;
  final String focalLength;
}
