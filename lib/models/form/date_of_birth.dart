import 'package:formz/formz.dart';

enum DateOfBirthValidationError { invalid }

class DateOfBirth extends FormzInput<String, DateOfBirthValidationError> {
  const DateOfBirth.pure([super.value = '']) : super.pure();
  const DateOfBirth.dirty([super.value = '']) : super.dirty();

  static final _passwordRegex =
      RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$');

  @override
  DateOfBirthValidationError? validator(String? value) {
    return _passwordRegex.hasMatch(value ?? '')
        ? null
        : DateOfBirthValidationError.invalid;
  }
}
