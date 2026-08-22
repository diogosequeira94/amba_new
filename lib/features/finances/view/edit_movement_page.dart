import 'package:amba_new/features/finances/cubit/edit_movement_cubit.dart';
import 'package:amba_new/features/finances/cubit/edit_movement_state.dart';
import 'package:amba_new/features/finances/model/finance_categories.dart';
import 'package:amba_new/features/finances/model/financial_movement.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditMovementPage extends StatefulWidget {
  final FinancialMovement movement;

  const EditMovementPage({super.key, required this.movement});

  @override
  State<EditMovementPage> createState() => _EditMovementPageState();
}

class _EditMovementPageState extends State<EditMovementPage> {
  late final TextEditingController titleCtrl;
  late final TextEditingController amountCtrl;
  late final TextEditingController notesCtrl;

  late FinanceType type;
  late String category;
  late DateTime occurredAt;

  /// Categorias do tipo atual. Se a categoria guardada não existir na lista
  /// (docs antigos, ou categoria do outro tipo), é acrescentada à frente para
  /// o dropdown não rebentar.
  List<String> get _currentCategories {
    final base = type == FinanceType.income
        ? FinanceCategories.income
        : FinanceCategories.expense;

    if (category.isNotEmpty && !base.contains(category)) {
      return [category, ...base];
    }
    return base;
  }

  @override
  void initState() {
    super.initState();

    final m = widget.movement;

    titleCtrl = TextEditingController(text: m.title);
    amountCtrl = TextEditingController(
      text: m.amount.toStringAsFixed(2).replaceAll('.', ','),
    );
    notesCtrl = TextEditingController(text: m.notes);

    type = m.type;
    category = m.category.trim();
    occurredAt = DateTime(
      m.occurredAt.year,
      m.occurredAt.month,
      m.occurredAt.day,
    );
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
      create: (_) => EditMovementCubit(),
      child: BlocListener<EditMovementCubit, EditMovementState>(
        listener: (context, state) {
          if (state is EditMovementSubmitting) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('A guardar alterações...')),
            );
          }

          if (state is EditMovementSuccess) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            Navigator.of(context).pop(true);
          }

          if (state is EditMovementFailure) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: Scaffold(
          appBar: AppBar(title: const Text('Editar movimento')),
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

                              final base = type == FinanceType.income
                                  ? FinanceCategories.income
                                  : FinanceCategories.expense;

                              // Ao trocar de tipo, a categoria antiga deixa de
                              // fazer sentido -> volta à primeira do novo tipo.
                              if (!base.contains(category)) {
                                category = base.first;
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
                        // Data do acontecimento
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

                BlocBuilder<EditMovementCubit, EditMovementState>(
                  builder: (context, state) {
                    final busy = state is EditMovementSubmitting;

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
                        label: Text(
                          busy ? 'A guardar...' : 'Guardar alterações',
                        ),
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

    context.read<EditMovementCubit>().submit(
      original: widget.movement,
      title: title,
      amount: amount,
      notes: notes,
      type: type,
      category: category.trim(),
      occurredAt: occurredAt,
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
