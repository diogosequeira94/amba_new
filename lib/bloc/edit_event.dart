part of 'edit_bloc.dart';

class EditEvent extends Equatable {
  const EditEvent();

  @override
  List<Object> get props => [];
}

class EmailChanged extends EditEvent {
  const EmailChanged({required this.email});

  final String email;

  @override
  List<Object> get props => [email];
}

class NameChanged extends EditEvent {
  const NameChanged({required this.name});

  final String name;

  @override
  List<Object> get props => [name];
}

class NotesChanged extends EditEvent {
  const NotesChanged({required this.notes});

  final String notes;

  @override
  List<Object> get props => [notes];
}

class PhoneChanged extends EditEvent {
  const PhoneChanged({required this.phone});

  final String phone;

  @override
  List<Object> get props => [phone];
}

class MemberNumberChanged extends EditEvent {
  const MemberNumberChanged({required this.memberNumber});

  final String memberNumber;

  @override
  List<Object> get props => [memberNumber];
}

class DateOfBirthChanged extends EditEvent {
  const DateOfBirthChanged({required this.dateOfBirth});

  final String dateOfBirth;

  @override
  List<Object> get props => [dateOfBirth];
}

class JoiningDateChanged extends EditEvent {
  const JoiningDateChanged({required this.joiningDate});

  final String joiningDate;

  @override
  List<Object> get props => [joiningDate];
}

class IsActiveCheckBoxChanged extends EditEvent {
  const IsActiveCheckBoxChanged({required this.isActive});

  final bool isActive;

  @override
  List<Object> get props => [isActive];
}

class PhotoPicked extends EditEvent {
  const PhotoPicked({required this.file});

  final File file;

  @override
  List<Object> get props => [file.path];
}

class PhotoCleared extends EditEvent {}

class FormSubmitted extends EditEvent {}

class EditingPressed extends EditEvent {
  final String memberId;
  const EditingPressed({required this.memberId});
}
