import 'package:amba_new/view/widgets/transactions/tx_ui.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'quotas_state.dart';

class QuotasCubit extends Cubit<QuotasState> {
  QuotasCubit() : super(QuotasInitial());

  Future<void> fetchQuotas({required int year, int month = 0}) async {
    emit(QuotasLoading());

    try {
      Query<Map<String, dynamic>> q = FirebaseFirestore.instance
          .collection('transactions')
          .where('type', isEqualTo: 'membership_fee')
          .where('year', isEqualTo: year);

      if (month != 0) {
        final periodKey = '$year-${month.toString().padLeft(2, '0')}';
        q = q.where('periods', arrayContains: periodKey);
      }

      final snap = await q.get();

      final list = snap.docs.map((d) {
        final data = d.data();

        final name = (data['memberName'] ?? '').toString().trim();
        final periods = (data['periods'] as List<dynamic>? ?? [])
            .map((e) => e.toString().trim())
            .toList();

        final total = (data['total'] as num? ?? 0).toDouble();

        final ts = data['createdAt'];
        final createdAt = (ts is Timestamp)
            ? ts.toDate()
            : DateTime(year, 1, 1);

        final normalizedPeriods = (data['periods'] as List<dynamic>? ?? [])
            .map((e) => e.toString().trim())
            .toList();

        return TxUi(
          id: d.id,
          title: name,
          subtitle: buildSubtitle(normalizedPeriods, year),
          date: createdAt,
          total: total,
          quotaCount: normalizedPeriods
              .where((p) => p.startsWith('$year-'))
              .toSet()
              .length,
          periodKeys: normalizedPeriods, // ✅
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

  String buildSubtitle(List<String> periods, int year) {
    // Normaliza e filtra só os períodos do ano pedido (ex: "2026-02")
    final yearPrefix = '$year-';

    final filtered = periods
        .map((e) => e.trim())
        .where((e) => e.startsWith(yearPrefix))
        .toSet(); // remove duplicados

    // Gera a lista esperada para o ano completo
    final expected = List.generate(
      12,
      (i) => '$year-${(i + 1).toString().padLeft(2, '0')}',
    );

    final hasFullYear = expected.every(filtered.contains);

    if (hasFullYear) return 'Todo o ano $year';

    // Se não for completo, podemos mostrar só os meses desse ano, ordenados
    final sorted = filtered.toList()..sort();

    // fallback: se não houver nenhum período desse ano, mostra o original (ou vazio)
    if (sorted.isEmpty) return periods.join(', ');

    return sorted.join(', ');
  }
}
