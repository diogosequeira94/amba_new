abstract class AddMovementState {}

class AddMovementInitial extends AddMovementState {}

class AddMovementSubmitting extends AddMovementState {}

class AddMovementSuccess extends AddMovementState {}

class AddMovementFailure extends AddMovementState {
  final String message;
  AddMovementFailure(this.message);
}
