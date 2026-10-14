
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

enum PinCheckResult { success, incorrect, locked }

class PinService {
  static const _storage = FlutterSecureStorage();

  static const _saltKey = 'vendorcash_pin_salt';
  static const _hashKey = 'vendorcash_pin_hash';
  static const _attemptsKey = 'vendorcash_failed_attempts';
  static const _lockedUntilKey = 'vendorcash_locked_until';

  static const maxAttempts = 5;
  static const lockDuration = Duration(seconds: 30);

  String _hashPin(String pin, String salt) {
    return sha256.convert(utf8.encode('$salt:$pin')).toString();
  }

  Future<bool> hasPin() async {
    final salt = await _storage.read(key: _saltKey);
    final hash = await _storage.read(key: _hashKey);
    return salt != null && hash != null;
  }

  Future<void> savePin(String pin) async {
    if (!RegExp(r'^\d{4}$').hasMatch(pin)) {
      throw ArgumentError('PIN must be exactly 4 digits.');
    }

    // Prevent overwriting an existing PIN without authentication.
    if (await hasPin()) {
      throw StateError('A PIN has already been created.');
    }

    final random = Random.secure();
    final salt = base64UrlEncode(
      List<int>.generate(32, (_) => random.nextInt(256)),
    );

    await _storage.write(
      key: _saltKey,
      value: salt,
    );
    await _storage.write(
      key: _hashKey,
      value: _hashPin(pin, salt),
    );

    await _resetAttempts();
  }

  Future<int> remainingLockSeconds() async {
    final stored = await _storage.read(key: _lockedUntilKey);
    final until = int.tryParse(stored ?? '');

    if (until == null) return 0;

    final remaining =
        until - DateTime.now().millisecondsSinceEpoch;

    if (remaining <= 0) return 0;

    return (remaining / 1000).ceil();
  }

  Future<int> remainingAttempts() async {
    final stored = await _storage.read(key: _attemptsKey);
    final attempts = int.tryParse(stored ?? '') ?? 0;
    return (maxAttempts - attempts).clamp(0, maxAttempts);
  }

  Future<PinCheckResult> verifyPin(String pin) async {
    if (await remainingLockSeconds() > 0) {
      return PinCheckResult.locked;
    }

    final salt = await _storage.read(key: _saltKey);
    final hash = await _storage.read(key: _hashKey);

    if (salt == null || hash == null) {
      return PinCheckResult.incorrect;
    }

    if (_hashPin(pin, salt) == hash) {
      await _resetAttempts();
      return PinCheckResult.success;
    }

    final stored = await _storage.read(key: _attemptsKey);
    final attempts = (int.tryParse(stored ?? '') ?? 0) + 1;

    if (attempts >= maxAttempts) {
      final until = DateTime.now()
          .add(lockDuration)
          .millisecondsSinceEpoch;

      await _storage.write(
        key: _lockedUntilKey,
        value: until.toString(),
      );
      await _storage.write(
        key: _attemptsKey,
        value: '0',
      );

      return PinCheckResult.locked;
    }

    await _storage.write(
      key: _attemptsKey,
      value: attempts.toString(),
    );

    return PinCheckResult.incorrect;
  }

  Future<void> _resetAttempts() async {
    await _storage.delete(key: _attemptsKey);
    await _storage.delete(key: _lockedUntilKey);
  }
}
