import 'package:equatable/equatable.dart';
import 'package:amba_new/view/widgets/transactions/tx_ui.dart';

abstract class QuotasState extends Equatable {
  const QuotasState();

  @override
  List<Object?> get props => [];
}

class QuotasInitial extends QuotasState {}

class QuotasLoading extends QuotasState {}

class QuotasSuccess extends QuotasState {
  final List<TxUi> items;
  const QuotasSuccess(this.items);

  @override
  List<Object?> get props => [items];
}

class QuotasFailure extends QuotasState {
  final String message;
  const QuotasFailure(this.message);

  @override
  List<Object?> get props => [message];
}
