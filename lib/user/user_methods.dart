import 'package:cloud_firestore/cloud_firestore.dart';

class ReadUser {
  const ReadUser({
    required this.userId,
    required this.path,
    required this.displayName,
    required this.imageUrl,
    required this.isHost,
    required this.createdAt,
    required this.updatedAt,
  });

  final String userId;

  final String path;

  final String displayName;

  final String imageUrl;

  final bool isHost;

  final Timestamp createdAt;

  final Timestamp updatedAt;

  factory ReadUser._fromJson(Map<String, dynamic> json) {
    return ReadUser(
      userId: json['userId'] as String,
      path: json['path'] as String,
      displayName: json['displayName'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      isHost: json['isHost'] as bool? ?? false,
      createdAt: json['createdAt'] ?? Timestamp.now(),
      updatedAt: json['updatedAt'] ?? Timestamp.now(),
    );
  }

  factory ReadUser.fromDocumentSnapshot(DocumentSnapshot ds) {
    final data = ds.data()! as Map<String, dynamic>;
    return ReadUser._fromJson(<String, dynamic>{
      ...data,
      'userId': ds.id,
      'path': ds.reference.path,
    });
  }
}

class CreateUser {
  const CreateUser({
    required this.displayName,
    this.imageUrl = '',
  });

  final String displayName;
  final String imageUrl;

  Map<String, dynamic> toJson() {
    return {
      'displayName': displayName,
      'imageUrl': imageUrl,
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
    };
  }
}

class UpdateUser {
  const UpdateUser({
    this.displayName,
    this.imageUrl,
    this.isHost,
    this.createdAt,
    this.updatedAt,
  });

  final String? displayName;
  final String? imageUrl;
  final bool? isHost;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  Map<String, dynamic> toJson() {
    return {
      if (displayName != null) 'displayName': displayName,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (isHost != null) 'isHost': isHost,
      if (createdAt != null) 'createdAt': createdAt,
      'updatedAt': Timestamp.now(),
    };
  }
}

/// A [CollectionReference] to users collection to read.
final readUserCollectionReference = FirebaseFirestore.instance.collection('users').withConverter<ReadUser>(
      fromFirestore: (ds, _) => ReadUser.fromDocumentSnapshot(ds),
      toFirestore: (obj, _) => throw UnimplementedError(),
    );

/// A [DocumentReference] to user document to read.
DocumentReference<ReadUser> readUserDocumentReference({
  required String userId,
}) =>
    readUserCollectionReference.doc(userId);

/// A [CollectionReference] to users collection to create.
final createUserCollectionReference = FirebaseFirestore.instance.collection('users').withConverter<CreateUser>(
      fromFirestore: (ds, _) => throw UnimplementedError(),
      toFirestore: (obj, _) => obj.toJson(),
    );

/// A [DocumentReference] to user document to create.
DocumentReference<CreateUser> createUserDocumentReference({
  required String userId,
}) =>
    createUserCollectionReference.doc(userId);

/// A [CollectionReference] to users collection to update.
final updateUserCollectionReference = FirebaseFirestore.instance.collection('users').withConverter<UpdateUser>(
      fromFirestore: (ds, _) => throw UnimplementedError(),
      toFirestore: (obj, _) => obj.toJson(),
    );

/// A [DocumentReference] to user document to update.
DocumentReference<UpdateUser> updateUserDocumentReference({
  required String userId,
}) =>
    updateUserCollectionReference.doc(userId);

/// A [CollectionReference] to users collection to delete.
final deleteUserCollectionReference = FirebaseFirestore.instance.collection('users');

/// A [DocumentReference] to user document to delete.
DocumentReference<Object?> deleteUserDocumentReference({
  required String userId,
}) =>
    deleteUserCollectionReference.doc(userId);

/// A query manager to execute query against [User].
class UserQuery {
  /// Fetches [ReadUser] documents.
  Future<List<ReadUser>> fetchDocuments({
    GetOptions? options,
    Query<ReadUser>? Function(Query<ReadUser> query)? queryBuilder,
    int Function(ReadUser lhs, ReadUser rhs)? compare,
  }) async {
    Query<ReadUser> query = readUserCollectionReference;
    if (queryBuilder != null) {
      query = queryBuilder(query)!;
    }
    final qs = await query.get(options);
    final result = qs.docs.map((qds) => qds.data()).toList();
    if (compare != null) {
      result.sort(compare);
    }
    return result;
  }

  /// Subscribes [User] documents.
  Stream<List<ReadUser>> subscribeDocuments({
    Query<ReadUser>? Function(Query<ReadUser> query)? queryBuilder,
    int Function(ReadUser lhs, ReadUser rhs)? compare,
    bool includeMetadataChanges = false,
    bool excludePendingWrites = false,
  }) {
    Query<ReadUser> query = readUserCollectionReference;
    if (queryBuilder != null) {
      query = queryBuilder(query)!;
    }
    var streamQs = query.snapshots(includeMetadataChanges: includeMetadataChanges);
    if (excludePendingWrites) {
      streamQs = streamQs.where((qs) => !qs.metadata.hasPendingWrites);
    }
    return streamQs.map((qs) {
      final result = qs.docs.map((qds) => qds.data()).toList();
      if (compare != null) {
        result.sort(compare);
      }
      return result;
    });
  }

  /// Fetches a specified [ReadUser] document.
  Future<ReadUser?> fetchDocument({
    required String userId,
    GetOptions? options,
  }) async {
    final ds = await readUserDocumentReference(
      userId: userId,
    ).get(options);
    return ds.data();
  }

  /// Subscribes a specified [User] document.
  Stream<ReadUser?> subscribeDocument({
    required String userId,
    bool includeMetadataChanges = false,
    bool excludePendingWrites = false,
  }) {
    var streamDs = readUserDocumentReference(
      userId: userId,
    ).snapshots(includeMetadataChanges: includeMetadataChanges);
    if (excludePendingWrites) {
      streamDs = streamDs.where((ds) => !ds.metadata.hasPendingWrites);
    }
    return streamDs.map((ds) => ds.data());
  }

  /// Adds a [User] document.
  Future<DocumentReference<CreateUser>> add({
    required CreateUser createUser,
  }) =>
      createUserCollectionReference.add(createUser);

  /// Sets a [User] document.
  Future<void> set({
    required String userId,
    required CreateUser createUser,
    SetOptions? options,
  }) =>
      createUserDocumentReference(
        userId: userId,
      ).set(createUser, options);

  /// Updates a specified [User] document.
  Future<void> update({
    required String userId,
    required UpdateUser updateUser,
  }) =>
      updateUserDocumentReference(
        userId: userId,
      ).update(updateUser.toJson());

  /// Deletes a specified [User] document.
  Future<void> delete({
    required String userId,
  }) =>
      deleteUserDocumentReference(
        userId: userId,
      ).delete();
}
