part of 'bottom_bar_bloc.dart';

enum SelectedTab { home, transactions, finances, settings }

class BottomBarState extends Equatable {
  final SelectedTab selectedTab;
  const BottomBarState({this.selectedTab = SelectedTab.home});

  BottomBarState copyWith({SelectedTab? selectedTab}) {
    return BottomBarState(selectedTab: selectedTab ?? this.selectedTab);
  }

  @override
  List<Object?> get props => [selectedTab];
}
