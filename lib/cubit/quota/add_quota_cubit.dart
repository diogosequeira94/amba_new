import 'package:amba_new/models/member.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'add_quota_state.dart';

class AddQuotaCubit extends Cubit<AddQuotaState> {
  AddQuotaCubit() : super(AddQuotaInitial());

  Future<void> submitQuota({
    required Member member,
    required List<int> months,
    required double amountPerMonth,
    required int year,
  }) async {
    emit(AddQuotaSubmitting());

    try {
      final periods = months.map((m) {
        final month = (m + 1).toString().padLeft(2, '0');
        return '$year-$month';
      }).toList();

      final total = amountPerMonth * periods.length;

      await FirebaseFirestore.instance.collection('transactions').add({
        'type': 'membership_fee',
        'memberId': member.id,
        'memberNumber': member.memberNumber,
        'memberName': member.name,
        'year': year,
        'periods': periods,
        'amountPerMonth': amountPerMonth,
        'total': total,
        'createdAt': FieldValue.serverTimestamp(),
      });

      emit(AddQuotaSuccess());
    } catch (e) {
      emit(AddQuotaFailure(e.toString()));
    }
  }
}
