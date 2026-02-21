import 'package:amba_new/services/quota_settings_service.dart';
import 'package:flutter/material.dart';

class ChangeQuotaAmountPage extends StatefulWidget {
  const ChangeQuotaAmountPage({super.key});

  @override
  State<ChangeQuotaAmountPage> createState() => _ChangeQuotaAmountPageState();
}

class _ChangeQuotaAmountPageState extends State<ChangeQuotaAmountPage> {
  final _svc = QuotaSettingsService();
  final _ctrl = TextEditingController();
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final v = await _svc.getDefaultAmount();
    if (!mounted) return;
    _ctrl.text = v.toStringAsFixed(2);
    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  double? _parse() {
    final txt = _ctrl.text.trim().replaceAll(',', '.');
    final v = double.tryParse(txt);
    if (v == null) return null;
    if (v <= 0) return null;
    return v;
  }

  Future<void> _save() async {
    final v = _parse();
    if (v == null) {
      setState(() => _error = 'Insere um valor válido (ex: 1.00)');
      return;
    }

    setState(() => _error = null);

    await _svc.setDefaultAmount(v);

    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Valor por defeito')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                children: [
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        controller: _ctrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.euro),
                          labelText: 'Valor por mês (€)',
                          errorText: _error,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.save_outlined),
                        label: const Text('Guardar'),
                        onPressed: _save,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
