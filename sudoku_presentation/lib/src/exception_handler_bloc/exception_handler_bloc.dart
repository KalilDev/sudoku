import 'package:bloc/bloc.dart';
import 'package:sudoku_presentation/errors.dart';

class ExceptionHandlerBloc extends Bloc<UserFriendly<Object>, UserFriendly<Object>>{
  @override
  UserFriendly<Object> get initialState => const UserFriendly<String>('Ok', 'Everything is fine');

  void handler(Object exception) {
    if (exception is UserFriendly) {
      add(exception);
      return;
    }
    add(exception.withErrorMessage('Ocorreu um erro inesperado'));
  }

  @override
  Stream<UserFriendly<Object>> mapEventToState(UserFriendly<Object> event) async* {
    yield event;
  }

}