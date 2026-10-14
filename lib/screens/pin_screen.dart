
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/pin_service.dart';

class PinScreen extends StatefulWidget {
  final VoidCallback onUnlocked;

  const PinScreen({
    super.key,
    required this.onUnlocked,
  });

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  final _controller = TextEditingController();
  final _service = PinService();

  bool _loading = true;
  bool _busy = false;
  bool _hasPin = false;
  String? _firstPin;
  String? _message;
  int _lockSeconds = 0;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final hasPin = await _service.hasPin();
      final seconds = await _service.remainingLockSeconds();

      if (!mounted) return;
      setState(() {
        _hasPin = hasPin;
        _lockSeconds = seconds;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _message = 'Could not access secure PIN storage.';
        _loading = false;
      });
    }
  }

  Future<void> _submit() async {
    if (_busy || _loading) return;

    final pin = _controller.text;

    if (!RegExp(r'^\d{4}$').hasMatch(pin)) {
      setState(() => _message = 'Enter exactly 4 digits.');
      return;
    }

    setState(() {
      _busy = true;
      _message = null;
    });

    try {
      if (!_hasPin) {
        if (_firstPin == null) {
          setState(() {
            _firstPin = pin;
            _busy = false;
          });
          _controller.clear();
          return;
        }

        if (pin != _firstPin) {
          setState(() {
            _firstPin = null;
            _message = 'PINs do not match. Try again.';
            _busy = false;
          });
          _controller.clear();
          return;
        }

        await _service.savePin(pin);
        if (!mounted) return;
        widget.onUnlocked();
        return;
      }

      final result = await _service.verifyPin(pin);

      if (!mounted) return;

      if (result == PinCheckResult.success) {
        widget.onUnlocked();
        return;
      }

      final seconds = await _service.remainingLockSeconds();

      if (result == PinCheckResult.locked) {
        setState(() {
          _lockSeconds = seconds;
          _message =
          'Too many incorrect attempts. '
              'Try again after $seconds seconds.';
        });
      } else {
        final remaining = await _service.remainingAttempts();
        if (!mounted) return;
        setState(() {
          _message =
          'Incorrect PIN. $remaining attempts remaining.';
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _message = 'PIN operation failed. Please try again.';
      });
    } finally {
      _controller.clear();
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _refreshLock() async {
    try {
      final seconds = await _service.remainingLockSeconds();
      if (!mounted) return;
      setState(() {
        _lockSeconds = seconds;
        _message = seconds > 0
            ? 'Try again after $seconds seconds.'
            : null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _message = 'Could not check PIN lock status.';
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('VendorCash Security'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock, size: 72),
                const SizedBox(height: 20),
                Text(
                  _hasPin
                      ? 'Enter your PIN'
                      : _firstPin == null
                      ? 'Create a 4-digit PIN'
                      : 'Confirm your PIN',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _controller,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'PIN',
                    counterText: '',
                  ),
                  onSubmitted: (_) => _submit(),
                ),
                if (_message != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _message!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: _busy ? null : _submit,
                  child: Text(
                    _busy
                        ? 'Please wait...'
                        : _hasPin
                        ? 'Unlock'
                        : _firstPin == null
                        ? 'Continue'
                        : 'Save PIN',
                  ),
                ),
                if (_lockSeconds > 0) ...[
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _refreshLock,
                    child: const Text('Check lock status'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
