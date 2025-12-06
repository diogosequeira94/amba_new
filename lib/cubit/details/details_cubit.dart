import 'package:amba_new/models/member.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

part 'details_state.dart';

class DetailsCubit extends Cubit<DetailsState> {
  DetailsCubit() : super(DetailsInitial());

  void detailsStarted(Member member) {
    emit(DetailsSuccess(
      member: member,
    ));
  }

  void deleteMember(Member member) async {
    print('Deleting IN PROGRESS!!');
    emit(const DetailsDeleteInProgress());
    try {
      final socios = FirebaseFirestore.instance.collection('socios');
      await socios.doc(member.id).delete();
      await Future<void>.delayed(const Duration(seconds: 1));

      emit(const DetailsDeleteSuccess());
      print('Deleting IN SUCCESS!!');
    } on Object catch (e) {
      print(e);
      emit(const DetailsDeleteFailure());
    }
  }
}
