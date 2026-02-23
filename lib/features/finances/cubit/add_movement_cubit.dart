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
    required DateTime occurredAt,
    required int year,
    required int month,
    String category = 'Outros',
  }) async {
    emit(AddMovementSubmitting());

    try {
      final movement = FinancialMovement(
        id: '',
        title: title.trim(),
        amount: amount,
        notes: notes.trim(),
        type: type,
        category: category.trim(),
        occurredAt: DateTime(occurredAt.year, occurredAt.month, occurredAt.day),
        createdAt: DateTime.now(),
        year: occurredAt.year,
        month: occurredAt.month,
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
