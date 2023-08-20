import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'user_methods.dart';
import 'user_repositories.dart';

final userRepositoryProvider = Provider.autoDispose<UserRepository>((_) => UserRepository());

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
