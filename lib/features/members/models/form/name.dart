import 'package:formz/formz.dart';

enum NameValidationError { valid }

class Name extends FormzInput<String, NameValidationError> {
  const Name.pure([super.value = '']) : super.pure();
  const Name.dirty([super.value = '']) : super.dirty();

  @override
  NameValidationError? validator(String? value) {
    return NameValidationError.valid;
  }
}
