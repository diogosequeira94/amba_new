part of 'bottom_bar_bloc.dart';

abstract class BottomBarEvent extends Equatable {
  const BottomBarEvent();
}

class BottomBarChanged extends BottomBarEvent {
  final SelectedTab selectedTab;
  const BottomBarChanged({required this.selectedTab});

  @override
  List<Object?> get props => [selectedTab];
}
