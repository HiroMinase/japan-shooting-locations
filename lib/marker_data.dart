class MarkerData {
  MarkerData({
    required this.firestoreDocumentId,
    required this.userId,
    required this.name,
    required this.imageUrl,
    required this.cameraModel,
    required this.dateTime,
    required this.shutterSpeed,
    required this.fNumber,
    required this.iso,
    required this.focalLength,
  });

  final String firestoreDocumentId;
  final String userId;
  final String name;
  final String imageUrl;
  final String cameraModel;
  final String dateTime;
  final String shutterSpeed;
  final String fNumber;
  final String iso;
  final String focalLength;
}
