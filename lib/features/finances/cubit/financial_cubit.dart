import 'package:amba_new/features/finances/cubit/financial_state.dart';
import 'package:amba_new/features/finances/model/financial_movement.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FinanceCubit extends Cubit<FinanceState> {
  FinanceCubit() : super(FinanceInitial());

  Future<void> fetchMovements({
    required int year,
    int month = 0,
    String type = 'all', // 'all' | 'income' | 'expense'
    String category = 'all', // 'all' | ...
  }) async {
    emit(FinanceLoading());

    try {
      // 1) Só filtra ano/mês no Firestore (sem orderBy)
      Query<Map<String, dynamic>> q = FirebaseFirestore.instance
          .collection('financial_movements')
          .where('year', isEqualTo: year);

      if (month != 0) {
        q = q.where('month', isEqualTo: month);
      }

      final snap = await q.get();

      // 2) Converte
      final list = snap.docs.map(FinancialMovement.fromDoc).toList();

      // 3) Ordena no client por createdAt desc
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // 4) Aplica filtros no client (para evitar índices extra)
      final filtered = list.where((m) {
        final okType = (type == 'all') ? true : (m.typeStr == type);
        final okCat = (category == 'all') ? true : (m.category == category);
        return okType && okCat;
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
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection('financial_movements')
          .doc(id)
          .delete();

      await fetchMovements(year: yearToRefresh, month: monthToRefresh);
    } catch (e) {
      emit(FinanceFailure(e.toString()));
    }
  }
}
