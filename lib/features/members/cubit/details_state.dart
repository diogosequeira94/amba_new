part of 'details_cubit.dart';

abstract class DetailsState extends Equatable {
  const DetailsState();
}

class DetailsInitial extends DetailsState {
  @override
  List<Object> get props => [];
}

class DetailsSuccess extends DetailsState {
  final Member member;

  const DetailsSuccess({required this.member});
  @override
  List<Object> get props => [member];
}

class DetailsDeleteInProgress extends DetailsState {
  const DetailsDeleteInProgress();
  @override
  List<Object> get props => [];
}

class DetailsDeleteSuccess extends DetailsState {
  const DetailsDeleteSuccess();
  @override
  List<Object> get props => [];
}

class DetailsDeleteFailure extends DetailsState {
  const DetailsDeleteFailure();
  @override
  List<Object> get props => [];
}
