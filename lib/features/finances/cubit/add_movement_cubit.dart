import 'package:amba_new/features/finances/cubit/add_movement_state.dart';
import 'package:amba_new/features/finances/model/financial_movement.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddMovementCubit extends Cubit<AddMovementState> {
  AddMovementCubit() : super(AddMovementInitial());

  Future<void> submit({
    required String title,
    required double amount,
    required String notes,
    required FinanceType type,
    required int year,
    required int month,
    String category = 'Outros',
  }) async {
    emit(AddMovementSubmitting());

    try {
      final movement = FinancialMovement(
        id: '',
        title: title,
        amount: amount,
        notes: notes,
        type: type,
        category: category,
        createdAt: DateTime.now(),
        year: year,
        month: month,
      );

      await FirebaseFirestore.instance
          .collection('financial_movements')
          .add(movement.toMap());

      emit(AddMovementSuccess());
    } catch (e) {
      emit(AddMovementFailure(e.toString()));
    }
  }
}
