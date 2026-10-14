
import 'package:flutter/material.dart';

import 'pin_screen.dart';

class AppLockGate extends StatefulWidget {
  final Widget dashboard;

  const AppLockGate({
    super.key,
    required this.dashboard,
  });

  @override
  State<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends State<AppLockGate>
    with WidgetsBindingObserver {
  bool _unlocked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.paused) {
      _lock();
    }
  }

  void _lock() {
    if (!_unlocked || !mounted) return;

    setState(() {
      _unlocked = false;
    });

    // Remove routes such as /records and /add so they
    // cannot remain visible above the PIN screen.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      Navigator.of(context).popUntil(
            (route) => route.isFirst,
      );
    });
  }

  void _unlock() {
    if (!mounted) return;

    setState(() {
      _unlocked = true;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _unlocked
        ? widget.dashboard
        : PinScreen(onUnlocked: _unlock);
  }
}
