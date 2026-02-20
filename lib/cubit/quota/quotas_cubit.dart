import 'package:amba_new/view/widgets/transactions/tx_ui.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'quotas_state.dart';

class QuotasCubit extends Cubit<QuotasState> {
  QuotasCubit() : super(QuotasInitial());

  Future<void> fetchQuotas({required int year}) async {
    emit(QuotasLoading());

    try {
      final snap = await FirebaseFirestore.instance
          .collection('transactions')
          .where('type', isEqualTo: 'membership_fee')
          .where('year', isEqualTo: year)
          .get();

      final list = snap.docs.map((d) {
        final data = d.data();

        final name = (data['memberName'] ?? '').toString().trim();
        final periods = (data['periods'] as List<dynamic>? ?? [])
            .map((e) => e.toString())
            .toList();

        final total = (data['total'] as num? ?? 0).toDouble();

        final ts = data['createdAt'];
        final DateTime createdAt = (ts is Timestamp)
            ? ts.toDate()
            : DateTime(year, 1, 1);

        return TxUi(
          id: d.id, // ✅ aqui
          title: 'Quota — $name',
          subtitle: periods.join(', '),
          date: createdAt,
          total: total,
          quotaCount: periods.length,
        );
      }).toList();

      list.sort((a, b) => b.date.compareTo(a.date));

      emit(QuotasSuccess(list));
    } catch (e) {
      emit(QuotasFailure(e.toString()));
    }
  }

  Future<void> deleteQuota({
    required String txId,
    required int yearToRefresh,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection('transactions')
          .doc(txId)
          .delete();

      // ✅ refresca a lista
      await fetchQuotas(year: yearToRefresh);
    } catch (e) {
      emit(QuotasFailure(e.toString()));
    }
  }
}