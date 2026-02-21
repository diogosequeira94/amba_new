import 'package:formz/formz.dart';

enum JoiningDateValidationError { invalid }

class JoiningDate extends FormzInput<String, JoiningDateValidationError> {
  const JoiningDate.pure([super.value = '']) : super.pure();
  const JoiningDate.dirty([super.value = '']) : super.dirty();

  static final _passwordRegex =
      RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$');

  @override
  JoiningDateValidationError? validator(String? value) {
    return _passwordRegex.hasMatch(value ?? '')
        ? null
        : JoiningDateValidationError.invalid;
  }
}
