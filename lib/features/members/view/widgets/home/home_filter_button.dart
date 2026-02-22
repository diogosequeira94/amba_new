import 'package:amba_new/features/members/view/widgets/home/chip_button.dart';
import 'package:flutter/material.dart';

enum HomeFilter { onlyActives, notActives, alphabetical, numerical }

class HomeFilterButton extends StatelessWidget {
  final void Function(HomeFilter value) onSelected;
  const HomeFilterButton({super.key, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<HomeFilter>(
      onSelected: onSelected,
      itemBuilder: (context) => const [
        PopupMenuItem(value: HomeFilter.onlyActives, child: Text('Activos')),
        PopupMenuItem(value: HomeFilter.notActives, child: Text('Inactivos')),
        PopupMenuItem(value: HomeFilter.alphabetical, child: Text('Por nome')),
        PopupMenuItem(value: HomeFilter.numerical, child: Text('Por número')),
      ],
      child: const ChipButton(icon: Icons.filter_list, label: 'Filtrar'),
    );
  }
}
