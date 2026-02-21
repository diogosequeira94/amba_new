part of 'edit_bloc.dart';

class EditState extends Equatable {
  const EditState({
    this.name = const Name.pure(),
    this.joiningDate = const JoiningDate.pure(),
    this.memberNumber = const MemberNumber.pure(),
    this.dateOfBirth = const DateOfBirth.pure(),
    this.phone = const Phone.pure(),
    this.notes = const Notes.pure(),
    this.email = const Email.pure(),
    this.isActive = true,
    this.isValid = false,
    this.status = FormzSubmissionStatus.initial,
    this.newMember,
  });

  final Name name;
  final JoiningDate joiningDate;
  final MemberNumber memberNumber;
  final DateOfBirth dateOfBirth;
  final Phone phone;
  final Email email;
  final Notes notes;
  final bool isActive;
  final bool isValid;
  final FormzSubmissionStatus status;
  final Member? newMember;

  EditState copyWith({
    Name? name,
    JoiningDate? joiningDate,
    MemberNumber? memberNumber,
    DateOfBirth? dateOfBirth,
    Phone? phone,
    Notes? notes,
    Email? email,
    bool? isActive,
    bool? isValid,
    FormzSubmissionStatus? status,
    Member? newMember,
  }) {
    return EditState(
      name: name ?? this.name,
      joiningDate: joiningDate ?? this.joiningDate,
      memberNumber: memberNumber ?? this.memberNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      isValid: isValid ?? this.isValid,
      status: status ?? this.status,
      newMember: newMember ?? this.newMember,
    );
  }

  @override
  List<Object?> get props => [
        name,
        joiningDate,
        memberNumber,
        dateOfBirth,
        phone,
        email,
        isActive,
        notes,
        status,
        newMember,
      ];
}