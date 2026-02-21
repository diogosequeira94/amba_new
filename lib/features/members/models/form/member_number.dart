import 'package:formz/formz.dart';

enum MemberNumberValidationError { invalid }

class MemberNumber extends FormzInput<String, MemberNumberValidationError> {
  const MemberNumber.pure([super.value = '']) : super.pure();
  const MemberNumber.dirty([super.value = '']) : super.dirty();

  static final _passwordRegex =
      RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$');

  @override
  MemberNumberValidationError? validator(String? value) {
    return _passwordRegex.hasMatch(value ?? '')
        ? null
        : MemberNumberValidationError.invalid;
  }
}
