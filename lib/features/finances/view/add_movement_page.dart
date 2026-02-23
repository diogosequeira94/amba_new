import 'package:amba_new/features/finances/cubit/add_movement_cubit.dart';
import 'package:amba_new/features/finances/cubit/add_movement_state.dart';
import 'package:amba_new/features/finances/model/finance_categories.dart';
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

  // ✅ Data do acontecimento
  DateTime occurredAt = DateTime.now();

  List<String> get _currentCategories => type == FinanceType.income
      ? FinanceCategories.income
      : FinanceCategories.expense;

  @override
  void initState() {
    super.initState();
    category = _currentCategories.first;

    // Default: hoje (mas podes adaptar ao ano/mês do ecrã)
    occurredAt = DateTime.now();
  }

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
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
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
                        // ----------------------------
                        // Tipo
                        // ----------------------------
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
                          onChanged: (v) {
                            if (v == null) return;

                            setState(() {
                              type = v;

                              if (!_currentCategories.contains(category)) {
                                category = _currentCategories.first;
                              }
                            });
                          },
                        ),

                        const SizedBox(height: 12),

                        // ----------------------------
                        // Categoria
                        // ----------------------------
                        DropdownButtonFormField<String>(
                          value: _currentCategories.contains(category)
                              ? category
                              : _currentCategories.first,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.category_outlined),
                            labelText: 'Categoria',
                          ),
                          items: _currentCategories
                              .map(
                                (c) =>
                                    DropdownMenuItem(value: c, child: Text(c)),
                              )
                              .toList(),
                          onChanged: (v) => setState(
                            () => category = v ?? _currentCategories.first,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // ----------------------------
                        // Data do acontecimento ✅
                        // ----------------------------
                        InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: occurredAt,
                              firstDate: DateTime(2020, 1, 1),
                              lastDate: DateTime.now().add(
                                const Duration(days: 365),
                              ),
                            );

                            if (picked == null) return;

                            setState(() {
                              occurredAt = DateTime(
                                picked.year,
                                picked.month,
                                picked.day,
                              );
                            });
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.event_outlined),
                              labelText: 'Data do acontecimento',
                            ),
                            child: Text(_formatDatePt(occurredAt)),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // ----------------------------
                        // Título
                        // ----------------------------
                        TextFormField(
                          controller: titleCtrl,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.title),
                            labelText: 'Título',
                          ),
                        ),

                        const SizedBox(height: 12),

                        // ----------------------------
                        // Montante
                        // ----------------------------
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

                        // ----------------------------
                        // Observações
                        // ----------------------------
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

                BlocBuilder<AddMovementCubit, AddMovementState>(
                  builder: (context, state) {
                    final busy = state is AddMovementSubmitting;

                    return SizedBox(
                      height: 54,
                      child: ElevatedButton.icon(
                        icon: busy
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.save_outlined),
                        label: Text(busy ? 'A guardar...' : 'Guardar'),
                        onPressed: busy ? null : () => _submit(context),
                      ),
                    );
                  },
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
      category: category.trim(),
      occurredAt: occurredAt, // ✅ aqui
      year: widget.year, // (podes ignorar estes no cubit, mas deixo por compat)
      month: widget.month,
    );
  }

  static String _formatDatePt(DateTime d) {
    const months = [
      'Jan',
      'Fev',
      'Mar',
      'Abr',
      'Mai',
      'Jun',
      'Jul',
      'Ago',
      'Set',
      'Out',
      'Nov',
      'Dez',
    ];
    return '${d.day.toString().padLeft(2, '0')} ${months[d.month - 1]} ${d.year}';
  }
}
