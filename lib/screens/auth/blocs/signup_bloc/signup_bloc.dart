import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:user_repository/user_repository.dart';

part 'signup_state.dart';
part 'signup_event.dart';

class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  final UserRepository _userRepository;

  SignUpBloc({required UserRepository userRepository})
      : _userRepository = userRepository,
        super(SignUpInitial()) {
    on<SignUpRequired>((event, emit) async {
      emit(SignUpProcess());
      try {
        await _userRepository.signUp(event.user, event.password);
        emit(SignUpSuccess(
          requiresEmailConfirmation: _userRepository.requiresEmailConfirmation,
        ));
      } catch (e) {
        emit(SignUpFailure(message: e.toString()));
      }
    });
  }
}
