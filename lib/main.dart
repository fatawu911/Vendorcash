
import 'package:flutter/material.dart';

import 'screens/dashboard_screen.dart';
import 'screens/add_transaction_screen.dart';
import 'screens/records_screen.dart';
import 'screens/app_lock_gate.dart';

void main() {
  runApp(const VendorCashApp());
}

class VendorCashApp extends StatelessWidget {
  const VendorCashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'VendorCash',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const AppLockGate(
        dashboard: DashboardScreen(),
      ),
      routes: {
        '/add': (context) => const AddTransactionScreen(),
        '/records': (context) => const RecordsScreen(),
      },
    );
  }
}
