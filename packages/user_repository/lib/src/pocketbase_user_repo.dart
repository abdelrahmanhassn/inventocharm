import 'dart:developer';
import 'package:pocketbase/pocketbase.dart';
import 'package:user_repository/user_repository.dart';

class PocketBaseUserRepo implements UserRepository {
  final PocketBase _client;

  PocketBaseUserRepo(this._client);

  AuthUser? _toUser(RecordModel? record) => record == null
      ? null
      : AuthUser(
          id: record.id,
          email: record.getStringValue('email'),
          name: record.getStringValue('name'),
        );

  @override
  bool get requiresEmailConfirmation => false;

  @override
  Stream<AuthUser?> get user async* {
    yield _toUser(_client.authStore.record);
    yield* _client.authStore.onChange
        .map((_) => _toUser(_client.authStore.record));
  }

  @override
  Future<void> signIn(String email, String password) async {
    try {
      await _client.collection('users').authWithPassword(email, password);
    } catch (error) {
      log(error.toString());
      rethrow;
    }
  }

  @override
  Future<MyUser> signUp(MyUser user, String password) async {
    try {
      final record = await _client.collection('users').create(body: {
        'email': user.email,
        'password': password,
        'passwordConfirm': password,
        'name': user.name,
      });
      await signIn(user.email, password);
      return user.copyWith(userId: record.id);
    } catch (error) {
      log('PocketBase sign-up failed: $error');
      rethrow;
    }
  }

  @override
  Future<void> setUserData(MyUser user) async {
    await _client.collection('users').update(user.userId, body: {
      'email': user.email,
      'name': user.name,
    });
  }

  @override
  Future<void> logOut() async => _client.authStore.clear();
}
