import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'user_methods.dart';
import 'user_repositories.dart';

final userRepositoryProvider = Provider.autoDispose<UserRepository>((_) => UserRepository());

/// 指定した [User] ドキュメントを購読する [StreamProvider].
final userStreamProvider = StreamProvider.family.autoDispose<ReadUser?, String>(
  (ref, userId) => ref.watch(userRepositoryProvider).subscribeUser(userId: userId),
);

/// 指定した [User] の画像 URL を返す [Provider].
/// 画像が存在しない場合や読み込み中・エラーの場合でもから文字を返す。
final userImageUrlProvider = Provider.family.autoDispose<String, String>((ref, userId) {
  final user = ref.watch(userStreamProvider(userId)).valueOrNull;
  return user?.imageUrl ?? '';
});

/// 指定した [User] の名前を返す [Provider].
/// 読み込み中・エラーの場合は空文字を返す。
final userDisplayNameProvider = Provider.family.autoDispose<String, String>((ref, userId) {
  final user = ref.watch(userStreamProvider(userId)).valueOrNull;
  return user?.displayName ?? '';
});

/// 指定した [User] を返す [FutureProvider].
final userFutureProvider = FutureProvider.family.autoDispose<ReadUser?, String>(
  (ref, userId) => ref.watch(userServiceProvider).fetchUser(userId: userId),
);

final userServiceProvider = Provider.autoDispose<UserService>(
  (ref) => UserService(
    userRepository: ref.watch(userRepositoryProvider),
  ),
);

class UserService {
  const UserService({required UserRepository userRepository}) : _userRepository = userRepository;

  final UserRepository _userRepository;

  /// 指定した [Worker] を取得する。
  Future<ReadUser?> fetchUser({required String userId}) => _userRepository.fetchUser(userId: userId);

  /// 指定した [User] が存在するかどうかを返す。
  Future<bool> userExists({required String userId}) async {
    final worker = await _userRepository.fetchUser(userId: userId);
    return worker != null;
  }

  /// [User] を作成する。
  Future<void> createUser({
    required String userId,
    required String displayName,
    String imageUrl = '',
  }) =>
      _userRepository.setUser(
        userId: userId,
        displayName: displayName,
        imageUrl: imageUrl,
      );
}
