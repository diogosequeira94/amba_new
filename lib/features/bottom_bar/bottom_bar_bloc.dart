import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'bottom_bar_event.dart';
part 'bottom_bar_state.dart';

class BottomBarBloc extends Bloc<BottomBarEvent, BottomBarState> {
  BottomBarBloc() : super(const BottomBarState()) {
    on<BottomBarChanged>((event, emit) {
      emit(state.copyWith(selectedTab: event.selectedTab));
    });
  }
}
