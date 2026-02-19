import 'package:equatable/equatable.dart';

abstract class AddQuotaState extends Equatable {
  const AddQuotaState();

  @override
  List<Object?> get props => [];
}

class AddQuotaInitial extends AddQuotaState {}

class AddQuotaSubmitting extends AddQuotaState {}

class AddQuotaSuccess extends AddQuotaState {}

class AddQuotaFailure extends AddQuotaState {
  final String message;

  const AddQuotaFailure(this.message);

  @override
  List<Object?> get props => [message];
}
