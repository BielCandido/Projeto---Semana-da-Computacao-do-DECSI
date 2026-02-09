import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Simple admin authentication helper.
/// Stores SHA-256(password) in SharedPreferences under key `_admin_pw_hash`.
class AdminAuth {
  static const _kAdminPwKey = 'admin_password_hash';
  static const _kMustChangeKey = 'admin_must_change';
  
  static final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  /// Hash a password with SHA-256
  static String _hash(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static Future<bool> hasPassword() async {
    final stored = await _secureStorage.read(key: _kAdminPwKey);
    return stored != null;
  }

  static Future<void> setPassword(String password) async {
    final hashed = _hash(password);
    await _secureStorage.write(key: _kAdminPwKey, value: hashed);
    // Clearing must-change flag when password is explicitly set
    await _secureStorage.delete(key: _kMustChangeKey);
  }

  static Future<bool> checkPassword(String password) async {
    final stored = await _secureStorage.read(key: _kAdminPwKey);
    if (stored == null) return false;
    return stored == _hash(password);
  }

  /// Reset admin password to default 'admin' and mark that it must be changed.
  static Future<void> resetToDefault() async {
    final hashed = _hash('admin');
    await _secureStorage.write(key: _kAdminPwKey, value: hashed);
    await _secureStorage.write(key: _kMustChangeKey, value: '1');
  }

  /// Show an auth flow: if no password exists, prompt to create one; otherwise prompt to enter.
  /// Returns true when authentication succeeds.
  static Future<bool> requestAuth(BuildContext context) async {
    final exists = await hasPassword();
    if (!exists) {
      // No admin password set yet — initialize default 'admin' password and mark for change
      final messenger = ScaffoldMessenger.of(context);
      await setPassword('admin');
      await _secureStorage.write(key: _kMustChangeKey, value: '1');
      messenger.showSnackBar(const SnackBar(content: Text('Senha admin padrão criada: admin. Você será solicitado a alterá-la.')));
      // fall through to prompt for entry so we can then force change
    }

    final ok = await _showEnterPasswordDialog(context);
    if (!(ok ?? false)) return false;

    // If password exists and must be changed, force change now
    final must = (await _secureStorage.read(key: _kMustChangeKey)) == '1';
    if (must) {
      final changed = await _showChangePasswordDialog(context);
      return changed ?? false;
    }

    return true;
  }

  // Note: creating password dialog removed; admin password is initialized to default

  static Future<bool?> _showEnterPasswordDialog(BuildContext context) async {
    final ctrl = TextEditingController();
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Autenticação Admin'),
        content: TextField(controller: ctrl, obscureText: true, decoration: const InputDecoration(labelText: 'Senha')),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              final pw = ctrl.text.trim();
              final messenger = ScaffoldMessenger.of(ctx);
              final nav = Navigator.of(ctx);
              final ok = await checkPassword(pw);
              if (!ok) {
                messenger.showSnackBar(const SnackBar(content: Text('Senha incorreta')));
                return;
              }
              nav.pop(true);
            },
            child: const Text('Entrar'),
          ),
        ],
      ),
    );
  }

  static Future<bool?> _showChangePasswordDialog(BuildContext context) async {
    final ctrl = TextEditingController();
    final confirm = TextEditingController();
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Alterar senha admin (obrigatório)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: ctrl, obscureText: true, decoration: const InputDecoration(labelText: 'Nova senha')),
            TextField(controller: confirm, obscureText: true, decoration: const InputDecoration(labelText: 'Confirmar senha')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              final a = ctrl.text.trim();
              final b = confirm.text.trim();
              if (a.isEmpty) return;
              if (a != b) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Senhas não coincidem')));
                return;
              }
              await setPassword(a);
              // ensure must-change flag removed
              await _secureStorage.delete(key: _kMustChangeKey);
              Navigator.of(ctx).pop(true);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }
}
