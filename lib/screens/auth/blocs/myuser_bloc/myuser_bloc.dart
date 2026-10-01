import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'myuser_event.dart';
part 'myuser_state.dart';

class MyuserBloc extends Bloc<MyuserEvent, MyuserState> {
  MyuserBloc() : super(MyuserInitial()) {
    on<MyuserEvent>((event, emit) {});
  }
}
