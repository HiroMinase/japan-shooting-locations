import 'user.dart';
import 'user_methods.dart';

class UserRepository {
  final _query = UserQuery();

  /// 指定した [User] を購読する。
  Stream<ReadUser?> subscribeUser({required String userId}) => _query.subscribeDocument(userId: userId);

  /// 指定した [User] を取得する。
  Future<ReadUser?> fetchUser({required String userId}) => _query.fetchDocument(userId: userId);

  /// [Worker] を作成する。
  Future<void> setUser({
    required String userId,
    required String displayName,
    String imageUrl = '',
  }) =>
      _query.set(
        userId: userId,
        createUser: CreateUser(
          displayName: displayName,
          imageUrl: imageUrl,
        ),
      );
}
