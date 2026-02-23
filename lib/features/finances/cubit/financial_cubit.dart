import 'package:amba_new/features/finances/cubit/financial_state.dart';
import 'package:amba_new/features/finances/model/financial_movement.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FinanceCubit extends Cubit<FinanceState> {
  FinanceCubit() : super(FinanceInitial());

  Future<void> fetchMovements({
    required int year,
    int month = 0,
    String type = 'all',
    String category = 'all',
  }) async {
    emit(FinanceLoading());

    try {
      // Busca só pelo ano (menos dependência em month gravado errado)
      Query<Map<String, dynamic>> q = FirebaseFirestore.instance
          .collection('financial_movements')
          .where('year', isEqualTo: year);

      final snap = await q.get();
      final list = snap.docs.map(FinancialMovement.fromDoc).toList();

      // Ordena por occurredAt desc
      list.sort((a, b) => b.occurredAt.compareTo(a.occurredAt));

      // ✅ Filtra pelo occurredAt REAL, não pelo campo month gravado
      final filtered = list.where((m) {
        final okMonth = (month == 0) ? true : (m.occurredAt.month == month);
        final okType = (type == 'all') ? true : (m.typeStr == type);
        final okCat = (category == 'all') ? true : (m.category == category);
        final okYear = m.occurredAt.year == year;

        return okYear && okMonth && okType && okCat;
      }).toList();

      emit(FinanceSuccess(filtered));
    } catch (e) {
      emit(FinanceFailure(e.toString()));
    }
  }

  Future<void> deleteMovement({
    required String id,
    required int yearToRefresh,
    required int monthToRefresh,
    String typeToRefresh = 'all',
    String categoryToRefresh = 'all',
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection('financial_movements')
          .doc(id)
          .delete();

      // refresca mantendo filtros (opcional mas UX melhor)
      await fetchMovements(
        year: yearToRefresh,
        month: monthToRefresh,
        type: typeToRefresh,
        category: categoryToRefresh,
      );
    } catch (e) {
      emit(FinanceFailure(e.toString()));
    }
  }
}
