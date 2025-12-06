import 'package:formz/formz.dart';

enum NotesValidationError { valid }

class Notes extends FormzInput<String, NotesValidationError> {
  const Notes.pure([super.value = '']) : super.pure();
  const Notes.dirty([super.value = '']) : super.dirty();

  @override
  NotesValidationError? validator(String? value) {
    return NotesValidationError.valid;
  }
}
