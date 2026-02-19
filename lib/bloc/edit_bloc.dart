import 'dart:async';
import 'dart:io';

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
import 'package:firebase_storage/firebase_storage.dart';
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

    on<PhotoPicked>(_onPhotoPicked);
    on<PhotoCleared>(_onPhotoCleared);

    on<FormSubmitted>(_onFormSubmitted);
    on<EditingPressed>(_onEditingPressed);
  }

  // ---------------------------
  // Form fields
  // ---------------------------

  void _onEmailChanged(EmailChanged event, Emitter<EditState> emit) {
    final email = Email.dirty(event.email);
    emit(
      state.copyWith(
        email: email.isValid ? email : Email.pure(event.email),
        isValid: _validateAll(email: email),
      ),
    );
  }

  void _onNameChanged(NameChanged event, Emitter<EditState> emit) {
    final name = Name.dirty(event.name);
    emit(
      state.copyWith(
        name: name,
        isValid: _validateAll(name: name),
      ),
    );
  }

  void _onMemberNumberChanged(
      MemberNumberChanged event,
      Emitter<EditState> emit,
      ) {
    final memberNumber = MemberNumber.dirty(event.memberNumber);
    emit(
      state.copyWith(
        memberNumber: memberNumber,
        isValid: _validateAll(memberNumber: memberNumber),
      ),
    );
  }

  void _onPhoneChanged(PhoneChanged event, Emitter<EditState> emit) {
    final phone = Phone.dirty(event.phone);
    emit(
      state.copyWith(
        phone: phone,
        isValid: _validateAll(phone: phone),
      ),
    );
  }

  void _onDateOfBirthChanged(
      DateOfBirthChanged event,
      Emitter<EditState> emit,
      ) {
    final dob = DateOfBirth.dirty(event.dateOfBirth);
    emit(
      state.copyWith(
        dateOfBirth: dob,
        isValid: _validateAll(dateOfBirth: dob),
      ),
    );
  }

  void _onJoiningDateChanged(
      JoiningDateChanged event,
      Emitter<EditState> emit,
      ) {
    final joiningDate = JoiningDate.dirty(event.joiningDate);
    emit(
      state.copyWith(
        joiningDate: joiningDate,
        isValid: _validateAll(joiningDate: joiningDate),
      ),
    );
  }

  void _onNotesChanged(NotesChanged event, Emitter<EditState> emit) {
    final notes = Notes.dirty(event.notes);
    emit(
      state.copyWith(
        notes: notes,
        isValid: _validateAll(notes: notes),
      ),
    );
  }

  void _onActiveCheckBoxChanged(
      IsActiveCheckBoxChanged event,
      Emitter<EditState> emit,
      ) {
    emit(
      state.copyWith(
        isActive: event.isActive,
        isValid: _validateAll(),
      ),
    );
  }

  bool _validateAll({
    Email? email,
    Name? name,
    DateOfBirth? dateOfBirth,
    JoiningDate? joiningDate,
    MemberNumber? memberNumber,
    Phone? phone,
    Notes? notes,
  }) {
    return Formz.validate([
      email ?? state.email,
      name ?? state.name,
      dateOfBirth ?? state.dateOfBirth,
      joiningDate ?? state.joiningDate,
      memberNumber ?? state.memberNumber,
      phone ?? state.phone,
      notes ?? state.notes,
    ]);
  }

  // ---------------------------
  // Photo
  // ---------------------------

  void _onPhotoPicked(PhotoPicked event, Emitter<EditState> emit) {
    emit(state.copyWith(localPhoto: event.file, photoChanged: true));
  }

  void _onPhotoCleared(PhotoCleared event, Emitter<EditState> emit) {
    emit(state.copyWith(localPhoto: null, photoChanged: false));
  }

  // ---------------------------
  // Submit (Create)
  // ---------------------------

  Future<void> _onFormSubmitted(
      FormSubmitted event,
      Emitter<EditState> emit,
      ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

    try {
      final socios = FirebaseFirestore.instance.collection('socios');

      // 1) Create doc first (need its ID for Storage path)
      final docRef = await socios.add({
        "name": state.name.value,
        "email": state.email.value,
        "dateOfBirth": state.dateOfBirth.value,
        "memberNumber": state.memberNumber.value,
        "phoneNumber": state.phone.value,
        "isActive": state.isActive,
        "joiningDate": state.joiningDate.value,
        "notes": state.notes.value,
      });

      // 2) If photo selected, upload + update doc
      if (state.photoChanged && state.localPhoto != null) {
        final url = await _uploadMemberPhoto(
          memberId: docRef.id,
          file: state.localPhoto!,
        );

        await docRef.update({
          "avatarUrl": url,
          "avatarUpdatedAt": FieldValue.serverTimestamp(),
        });
      }

      emit(
        state.copyWith(
          status: FormzSubmissionStatus.success,
          localPhoto: null,
          photoChanged: false,
        ),
      );
    } on Object catch (e) {
      print(e);
      emit(state.copyWith(status: FormzSubmissionStatus.failure));
    }
  }

  // ---------------------------
  // Submit (Edit)
  // ---------------------------

  Future<void> _onEditingPressed(
      EditingPressed event,
      Emitter<EditState> emit,
      ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

    try {
      final socios = FirebaseFirestore.instance.collection('socios');

      // 1) Upload photo if changed
      String? uploadedUrl;
      if (state.photoChanged && state.localPhoto != null) {
        uploadedUrl = await _uploadMemberPhoto(
          memberId: event.memberId,
          file: state.localPhoto!,
        );
      }

      // 2) Update Firestore
      final updateData = <String, dynamic>{
        "name": state.name.value,
        "email": state.email.value,
        "dateOfBirth": state.dateOfBirth.value,
        "memberNumber": state.memberNumber.value,
        "phoneNumber": state.phone.value,
        "isActive": state.isActive,
        "joiningDate": state.joiningDate.value,
        "notes": state.notes.value,
      };

      if (uploadedUrl != null) {
        updateData["avatarUrl"] = uploadedUrl;
        updateData["avatarUpdatedAt"] = FieldValue.serverTimestamp();
      }

      await socios.doc(event.memberId).update(updateData);

      // 3) Emit success (+ newMember for your DetailsCubit)
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
        avatarUrl: uploadedUrl, // may be null if unchanged
      );

      print('################ SUCCESS EDIT $uploadedUrl');
      emit(
        state.copyWith(
          status: FormzSubmissionStatus.success,
          newMember: newMember,
          localPhoto: null,
          photoChanged: false,
        ),
      );
    } on Object catch (e) {
      print('################ ERROR ERROR EDIT $e');
      emit(state.copyWith(status: FormzSubmissionStatus.failure));
    }
  }

  // ---------------------------
  // Storage helper
  // ---------------------------

  Future<String> _uploadMemberPhoto({
    required String memberId,
    required File file,
  }) async {
    final path = 'users/$memberId/avatar.jpg';
    final ref = FirebaseStorage.instance.ref(path);

    final metadata = SettableMetadata(
      contentType: 'image/jpeg',
      cacheControl: 'public,max-age=86400',
    );

    await ref.putFile(file, metadata);
    return ref.getDownloadURL();
  }
}