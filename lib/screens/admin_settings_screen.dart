import 'package:flutter/material.dart';
import 'package:semana_computacao/services/admin_auth.dart';

class AdminSettingsScreen extends StatelessWidget {
  const AdminSettingsScreen({Key? key}) : super(key: key);

  Future<void> _changePassword(BuildContext context) async {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Alterar senha admin'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: currentCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Senha atual')),
            TextField(controller: newCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Nova senha')),
            TextField(controller: confirmCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Confirmar nova senha')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              final current = currentCtrl.text.trim();
              final a = newCtrl.text.trim();
              final b = confirmCtrl.text.trim();
              if (a.isEmpty) return;
              if (a != b) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Senhas não coincidem')));
                return;
              }
              final ok = await AdminAuth.checkPassword(current);
              if (!ok) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Senha atual incorreta')));
                return;
              }
              await AdminAuth.setPassword(a);
              Navigator.of(ctx).pop(true);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );

    if (ok ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Senha alterada com sucesso')));
    }
  }

  Future<void> _resetToDefault(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Resetar senha admin'),
        content: const Text('Deseja resetar a senha admin para o valor padrão (admin)? O usuário terá que alterá-la no próximo login.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Resetar')),
        ],
      ),
    );

    if (confirm ?? false) {
      await AdminAuth.resetToDefault();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Senha resetada para "admin". Será solicitada alteração no próximo login.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin - Configurações')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () => _changePassword(context),
              child: const Text('Alterar senha'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => _resetToDefault(context),
              child: const Text('Resetar para padrão'),
            ),
          ],
        ),
      ),
    );
  }
}
