import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  const User({
    this.displayName = '',
    this.imageUrl = '',
    required this.createdAt,
    required this.updatedAt,
  });

  final String displayName;
  final String imageUrl;
  final Timestamp createdAt;
  final Timestamp updatedAt;
}
