part of 'signup_bloc.dart';

sealed class SignUpState extends Equatable {
  const SignUpState();

  @override
  List<Object> get props => [];
}

final class SignUpInitial extends SignUpState {}

class SignUpSuccess extends SignUpState {
  final bool requiresEmailConfirmation;

  const SignUpSuccess({this.requiresEmailConfirmation = false});

  @override
  List<Object> get props => [requiresEmailConfirmation];
}

class SignUpFailure extends SignUpState {
  final String message;

  const SignUpFailure({this.message = 'Unable to create your account.'});

  @override
  List<Object> get props => [message];
}

class SignUpProcess extends SignUpState {}
