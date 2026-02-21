import 'package:amba_new/features/finances/model/financial_movement.dart';

abstract class FinanceState {}

class FinanceInitial extends FinanceState {}

class FinanceLoading extends FinanceState {}

class FinanceFailure extends FinanceState {
  final String message;
  FinanceFailure(this.message);
}

class FinanceSuccess extends FinanceState {
  final List<FinancialMovement> items;
  FinanceSuccess(this.items);
}