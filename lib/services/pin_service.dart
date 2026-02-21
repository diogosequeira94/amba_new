import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PinService {
  static const _storage = FlutterSecureStorage();

  static const _kEnabled = 'pin_enabled';
  static const _kHash = 'pin_hash';
  static const _kInitialized = 'pin_initialized'; // ✅ novo

  String _hash(String pin) {
    return sha256.convert(utf8.encode(pin)).toString();
  }

  Future<bool> isEnabled() async {
    final v = await _storage.read(key: _kEnabled);
    return v == '1';
  }

  Future<void> setEnabled(bool enabled) async {
    await _storage.write(key: _kEnabled, value: enabled ? '1' : '0');
  }

  Future<void> setPin(String pin) async {
    await _storage.write(key: _kHash, value: _hash(pin));
    await setEnabled(true);
  }

  Future<void> disablePin() async {
    await _storage.delete(key: _kHash);
    await setEnabled(false);
  }

  Future<bool> verify(String pin) async {
    final stored = await _storage.read(key: _kHash);
    if (stored == null || stored.isEmpty) return false;
    return _hash(pin) == stored;
  }

  // ✅ chama isto no arranque: garante que há um PIN por defeito na 1ª instalação
  Future<void> ensureDefaultPin({String defaultPin = '1958'}) async {
    final init = await _storage.read(key: _kInitialized);
    if (init == '1') return;

    final existingHash = await _storage.read(key: _kHash);

    // Se não existir PIN guardado, define o default
    if (existingHash == null || existingHash.isEmpty) {
      await setPin(defaultPin);
    } else {
      // Se já existe hash (por algum motivo), só garante que fica enabled
      await setEnabled(true);
    }

    await _storage.write(key: _kInitialized, value: '1');
  }
}
