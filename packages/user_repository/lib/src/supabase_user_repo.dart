import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;
import 'package:user_repository/user_repository.dart';

class SupabaseUserRepo implements UserRepository {
  final SupabaseClient _client;
  bool _requiresEmailConfirmation = false;

  SupabaseUserRepo(this._client);

  AuthUser? _toUser(User? user) => user == null
      ? null
      : AuthUser(
          id: user.id,
          email: user.email ?? '',
          name: user.userMetadata?['name']?.toString() ?? '',
        );

  @override
  bool get requiresEmailConfirmation => _requiresEmailConfirmation;

  @override
  Stream<AuthUser?> get user async* {
    yield _toUser(_client.auth.currentUser);
    yield* _client.auth.onAuthStateChange.map(
        (event) => _toUser(event.session?.user ?? _client.auth.currentUser));
  }

  @override
  Future<void> signIn(String email, String password) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  @override
  Future<MyUser> signUp(MyUser user, String password) async {
    final response = await _client.auth.signUp(
      email: user.email,
      password: password,
      data: {'name': user.name},
    );
    final createdUser = response.user;
    if (createdUser == null) {
      throw StateError('Supabase did not return the created user.');
    }
    _requiresEmailConfirmation = response.session == null;
    return user.copyWith(userId: createdUser.id);
  }

  @override
  Future<void> setUserData(MyUser user) async {
    await _client.auth.updateUser(
      UserAttributes(email: user.email, data: {'name': user.name}),
    );
    await _client.from('profiles').update({
      'name': user.name,
    }).eq('id', user.userId);
  }

  @override
  Future<void> logOut() async => _client.auth.signOut();
}
