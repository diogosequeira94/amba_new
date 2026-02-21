import 'package:amba_new/features/finances/cubit/add_movement_cubit.dart';
import 'package:amba_new/features/finances/cubit/add_movement_state.dart';
import 'package:amba_new/features/finances/model/financial_movement.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddMovementPage extends StatefulWidget {
  final int year;
  final int month;

  const AddMovementPage({super.key, required this.year, required this.month});

  @override
  State<AddMovementPage> createState() => _AddMovementPageState();
}

class _AddMovementPageState extends State<AddMovementPage> {
  final titleCtrl = TextEditingController();
  final amountCtrl = TextEditingController();
  final notesCtrl = TextEditingController();

  FinanceType type = FinanceType.expense;
  String category = 'Outros';

  @override
  void dispose() {
    titleCtrl.dispose();
    amountCtrl.dispose();
    notesCtrl.dispose();
    super.dispose();
  }

  double _parseAmount() =>
      double.tryParse(amountCtrl.text.trim().replaceAll(',', '.')) ?? 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider(
      create: (_) => AddMovementCubit(),
      child: BlocListener<AddMovementCubit, AddMovementState>(
        listener: (context, state) {
          if (state is AddMovementSubmitting) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('A guardar movimento...')),
            );
          }
          if (state is AddMovementSuccess) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            Navigator.of(context).pop(true);
          }
          if (state is AddMovementFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: Scaffold(
          appBar: AppBar(title: const Text('Novo movimento')),
          body: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: ListView(
              children: [
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        DropdownButtonFormField<FinanceType>(
                          value: type,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.swap_vert),
                            labelText: 'Tipo',
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: FinanceType.income,
                              child: Text('Receita'),
                            ),
                            DropdownMenuItem(
                              value: FinanceType.expense,
                              child: Text('Despesa'),
                            ),
                          ],
                          onChanged: (v) => setState(() => type = v!),
                        ),
                        const SizedBox(height: 12),

                        TextFormField(
                          controller: titleCtrl,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.title),
                            labelText: 'Título',
                          ),
                        ),
                        const SizedBox(height: 12),

                        TextFormField(
                          controller: amountCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.euro),
                            labelText: 'Montante (€)',
                          ),
                        ),
                        const SizedBox(height: 12),

                        TextFormField(
                          controller: notesCtrl,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.notes_outlined),
                            labelText: 'Observações',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                SizedBox(
                  height: 54,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Guardar'),
                    onPressed: () => _submit(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit(BuildContext context) {
    final title = titleCtrl.text.trim();
    final amount = _parseAmount();
    final notes = notesCtrl.text.trim();

    if (title.isEmpty || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preenche título e montante válido.')),
      );
      return;
    }

    context.read<AddMovementCubit>().submit(
      title: title,
      amount: amount,
      notes: notes,
      type: type,
      year: widget.year,
      month: widget.month,
      category: category,
    );
  }
}
