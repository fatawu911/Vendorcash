import 'package:flutter/material.dart';
import '../services/database_helper.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  double totalToday = 0;

  @override
  void initState() {
    super.initState();
    loadTotal();
  }

  Future<void> loadTotal() async {
    final data = await DatabaseHelper.instance.getTransactions();

    double totalAmount = 0;

    String today = DateTime.now().toString().substring(0, 10);

    for (var tx in data) {
      if (tx['date'].toString().startsWith(today)) {
        totalAmount += tx['amount'];
      }
    }

    setState(() {
      totalToday = totalAmount;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("VendorCash"),
        backgroundColor: Colors.green,
      ),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                "Welcome Vendor",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Text("Today's Total"),
                    const SizedBox(height: 10),
                    Text(
                      "GHS ${totalToday.toStringAsFixed(2)}",
                      style: const TextStyle(fontSize: 24),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: () async {
                  await Navigator.pushNamed(context, '/add');
                  loadTotal(); // refresh after adding
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text("Add Transaction"),
              ),

              const SizedBox(height: 10),

              ElevatedButton(
                onPressed: () async {
                  await Navigator.pushNamed(context, '/records');
                  loadTotal(); // refresh after viewing
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text("View Records"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
