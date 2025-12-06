import 'dart:async';

import 'package:amba_new/models/form/date_of_birth.dart';
import 'package:amba_new/models/form/email.dart';
import 'package:amba_new/models/form/joining_date.dart';
import 'package:amba_new/models/form/member_number.dart';
import 'package:amba_new/models/form/name.dart';
import 'package:amba_new/models/form/notes.dart';
import 'package:amba_new/models/form/phone.dart';
import 'package:amba_new/models/member.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';

part 'edit_event.dart';
part 'edit_state.dart';

class EditBloc extends Bloc<EditEvent, EditState> {
  EditBloc() : super(const EditState()) {
    on<EmailChanged>(_onEmailChanged);
    on<NameChanged>(_onNameChanged);
    on<MemberNumberChanged>(_onMemberNumberChanged);
    on<PhoneChanged>(_onPhoneChanged);
    on<DateOfBirthChanged>(_onDateOfBirthChanged);
    on<JoiningDateChanged>(_onJoiningDateChanged);
    on<NotesChanged>(_onNotesChanged);
    on<IsActiveCheckBoxChanged>(_onActiveCheckBoxChanged);
    on<FormSubmitted>(_onFormSubmitted);
    on<EditingPressed>(_onEditingPressed);
  }

  void _onEmailChanged(EmailChanged event, Emitter<EditState> emit) {
    print('EMAIL WAS CALLED');
    final email = Email.dirty(event.email);
    emit(
      state.copyWith(
        email: email.isValid ? email : Email.pure(event.email),
        isValid: Formz.validate([
          email,
          state.name,
          state.dateOfBirth,
          state.joiningDate,
          state.memberNumber,
          state.phone,
          state.notes,
        ]),
      ),
    );
  }

  void _onNameChanged(NameChanged event, Emitter<EditState> emit) {
    print('NAME WAS CALLED');
    final name = Name.dirty(event.name);
    print('### THE NAME IS: ${name.value}');
    emit(
      state.copyWith(
        name: name,
        isValid: Formz.validate([
          state.email,
          name,
          state.dateOfBirth,
          state.joiningDate,
          state.memberNumber,
          state.phone,
          state.notes,
        ]),
      ),
    );
  }

  void _onMemberNumberChanged(
      MemberNumberChanged event, Emitter<EditState> emit) {
    final memberNumber = MemberNumber.dirty(event.memberNumber);
    emit(
      state.copyWith(
        memberNumber: memberNumber,
        isValid: Formz.validate([
          state.email,
          memberNumber,
          state.name,
          state.dateOfBirth,
          state.joiningDate,
          state.phone,
          state.notes,
        ]),
      ),
    );
  }

  void _onPhoneChanged(PhoneChanged event, Emitter<EditState> emit) {
    final phone = Phone.dirty(event.phone);
    emit(
      state.copyWith(
        phone: phone,
        isValid: Formz.validate([
          state.email,
          phone,
          state.name,
          state.dateOfBirth,
          state.joiningDate,
          state.memberNumber,
          state.notes,
        ]),
      ),
    );
  }

  void _onDateOfBirthChanged(
      DateOfBirthChanged event, Emitter<EditState> emit) {
    final dateOfBirth = DateOfBirth.dirty(event.dateOfBirth);
    emit(
      state.copyWith(
        dateOfBirth: dateOfBirth,
        isValid: Formz.validate([
          state.email,
          dateOfBirth,
          state.name,
          state.joiningDate,
          state.memberNumber,
          state.phone,
          state.notes,
        ]),
      ),
    );
  }

  void _onJoiningDateChanged(
      JoiningDateChanged event, Emitter<EditState> emit) {
    final joiningDate = JoiningDate.dirty(event.joiningDate);
    emit(
      state.copyWith(
        joiningDate: joiningDate,
        isValid: Formz.validate([
          state.email,
          joiningDate,
          state.name,
          state.dateOfBirth,
          state.memberNumber,
          state.phone,
          state.notes,
        ]),
      ),
    );
  }

  void _onActiveCheckBoxChanged(
      IsActiveCheckBoxChanged event, Emitter<EditState> emit) {
    emit(
      state.copyWith(
        isActive: event.isActive,
        isValid: Formz.validate([
          state.email,
          state.joiningDate,
          state.name,
          state.dateOfBirth,
          state.memberNumber,
          state.phone,
          state.notes,
        ]),
      ),
    );
  }

  void _onNotesChanged(NotesChanged event, Emitter<EditState> emit) {
    final notes = Notes.dirty(event.notes);
    emit(
      state.copyWith(
        notes: notes,
        isValid: Formz.validate([
          state.email,
          notes,
          state.name,
          state.dateOfBirth,
          state.joiningDate,
          state.memberNumber,
          state.phone,
        ]),
      ),
    );
  }

  Future<void> _onFormSubmitted(
    FormSubmitted event,
    Emitter<EditState> emit,
  ) async {
    print('Emitting IN PROGRESS!!');
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

    try {
      final socios = FirebaseFirestore.instance.collection('socios');
      await socios.add({
        "name": state.name.value,
        "email": state.email.value,
        "dateOfBirth": state.dateOfBirth.value,
        "memberNumber": state.memberNumber.value,
        "phoneNumber": state.phone.value,
        "isActive": state.isActive,
        "joiningDate": state.joiningDate.value,
        "notes": state.notes.value,
      });
      await Future<void>.delayed(const Duration(seconds: 1));
      emit(state.copyWith(status: FormzSubmissionStatus.success));
      print('Emitting SCUCCESS!!');
    } on Object catch (e) {
      print(e);
      emit(state.copyWith(status: FormzSubmissionStatus.failure));
    }
  }

  Future<void> _onEditingPressed(
    EditingPressed event,
    Emitter<EditState> emit,
  ) async {
    print('Editing IN PROGRESS!!');
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

    try {
      final socios = FirebaseFirestore.instance.collection('socios');
      await socios.doc(event.memberId).update({
        "name": state.name.value,
        "email": state.email.value,
        "dateOfBirth": state.dateOfBirth.value,
        "memberNumber": state.memberNumber.value,
        "phoneNumber": state.phone.value,
        "isActive": state.isActive,
        "joiningDate": state.joiningDate.value,
        "notes": state.notes.value,
      });

      final newMember = Member(
        id: event.memberId,
        name: state.name.value,
        memberNumber: state.memberNumber.value,
        joiningDate: state.joiningDate.value,
        dateOfBirth: state.dateOfBirth.value,
        phoneNumber: state.phone.value,
        email: state.email.value,
        isActive: state.isActive,
        notes: state.notes.value,
      );
      await Future<void>.delayed(const Duration(seconds: 1));
      emit(state.copyWith(status: FormzSubmissionStatus.success, newMember: newMember));
    } on Object catch (e) {
      print(e);
      emit(state.copyWith(status: FormzSubmissionStatus.failure));
    }
  }
}
