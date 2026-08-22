import 'package:amba_new/features/finances/cubit/edit_movement_state.dart';
import 'package:amba_new/features/finances/model/financial_movement.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditMovementCubit extends Cubit<EditMovementState> {
  EditMovementCubit() : super(EditMovementInitial());

  Future<void> submit({
    required FinancialMovement original,
    required String title,
    required double amount,
    required String notes,
    required FinanceType type,
    required DateTime occurredAt,
    String category = 'Outros',
  }) async {
    if (original.id.isEmpty) {
      emit(EditMovementFailure('Movimento sem id. Não é possível editar.'));
      return;
    }

    emit(EditMovementSubmitting());

    try {
      final updated = original.copyWith(
        title: title.trim(),
        amount: amount,
        notes: notes.trim(),
        type: type,
        category: category.trim(),
        occurredAt: DateTime(occurredAt.year, occurredAt.month, occurredAt.day),
        year: occurredAt.year,
        month: occurredAt.month,
      );

      await FirebaseFirestore.instance
          .collection('financial_movements')
          .doc(original.id)
          .update(updated.toUpdateMap());

      emit(EditMovementSuccess(updated));
    } catch (e) {
      emit(EditMovementFailure(e.toString()));
    }
  }
}
