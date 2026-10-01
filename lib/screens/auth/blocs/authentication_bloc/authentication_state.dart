part of 'authentication_bloc.dart';

// Consider using a more descriptive enum name like AuthenticationUserStatus
enum AuthenticationUserStatus {
  authenticated,
  unauthenticated,
  unknown,
}

class AuthenticationState extends Equatable {
  final AuthenticationUserStatus status;
  final AuthUser? user;

  const AuthenticationState._({
    this.status = AuthenticationUserStatus.unknown,
    this.user,
  });

  factory AuthenticationState.unknown() =>
      AuthenticationState._(status: AuthenticationUserStatus.unknown);

  factory AuthenticationState.authenticated(AuthUser user) =>
      AuthenticationState._(
          status: AuthenticationUserStatus.authenticated, user: user);

  factory AuthenticationState.unauthenticated() =>
      AuthenticationState._(status: AuthenticationUserStatus.unauthenticated);

  @override
  List<Object?> get props => [status, user];
}
