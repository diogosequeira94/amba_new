import 'package:amba_new/features/settings/services/pin_service.dart';
import 'package:amba_new/features/settings/change_pin_page.dart';
import 'package:amba_new/features/settings/change_quota_amount_page.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Definições')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
        children: [
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: const Text('Alterar PIN'),
                  subtitle: const Text('Define um novo PIN de acesso à app'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    final ok = await Navigator.of(context).push<bool>(
                      MaterialPageRoute(builder: (_) => const ChangePinPage()),
                    );

                    if (ok == true && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('PIN atualizado ✅')),
                      );
                    }
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.payment_outlined),
                  title: const Text('Alterar valor da Quota'),
                  subtitle: const Text('Define um valor por defeito da quota'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    final ok = await Navigator.of(context).push<bool>(
                      MaterialPageRoute(
                        builder: (_) => const ChangeQuotaAmountPage(),
                      ),
                    );

                    if (ok == true && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Valor da quota atualizado ✅'),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
