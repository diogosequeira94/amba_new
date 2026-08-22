import 'package:amba_new/features/finances/model/financial_movement.dart';

abstract class EditMovementState {}

class EditMovementInitial extends EditMovementState {}

class EditMovementSubmitting extends EditMovementState {}

class EditMovementSuccess extends EditMovementState {
  final FinancialMovement movement;
  EditMovementSuccess(this.movement);
}

class EditMovementFailure extends EditMovementState {
  final String message;
  EditMovementFailure(this.message);
}
