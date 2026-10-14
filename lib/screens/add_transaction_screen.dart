import 'package:flutter/material.dart';
import '../services/database_helper.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  String selectedNetwork = 'MTN';
  String selectedType = 'Withdrawal';

  void saveTransaction() async {
    print("SAVE FUNCTION CALLED"); // debug

    String phone = phoneController.text.trim();
    String amountText = amountController.text.trim();

    if (phone.isEmpty || amountText.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    double? amount = double.tryParse(amountText);

    if (amount == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Enter a valid amount")));
      return;
    }

    try {
      print("Saving to DB..."); // debug

      await DatabaseHelper.instance.insertTransaction({
        'phone': phoneController.text,
        'amount': double.parse(amountController.text),
        'network': selectedNetwork,
        'type': selectedType,
        'date': DateTime.now().toString(),
      });

      print("Saved successfully"); // debug

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Transaction Saved")));

      phoneController.clear();
      amountController.clear();
    } catch (e) {
      print("ERROR: $e");

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Error saving transaction")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Transaction"),
        backgroundColor: Colors.green,
      ),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: "Customer Number",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Amount (GHS)",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              DropdownButtonFormField(
                value: selectedNetwork,
                items: const [
                  DropdownMenuItem(value: 'MTN', child: Text('MTN')),
                  DropdownMenuItem(value: 'Telecel', child: Text('Telecel')),
                  DropdownMenuItem(
                    value: 'AirtelTigo',
                    child: Text('AirtelTigo'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedNetwork = value!;
                  });
                },
                decoration: const InputDecoration(
                  labelText: "Network",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              DropdownButtonFormField(
                value: selectedType,
                items: const [
                  DropdownMenuItem(
                    value: 'Withdrawal',
                    child: Text('Withdrawal'),
                  ),
                  DropdownMenuItem(value: 'Deposit', child: Text('Deposit')),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedType = value!;
                  });
                },
                decoration: const InputDecoration(
                  labelText: "Transaction Type",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 25),

              ElevatedButton(
                onPressed: saveTransaction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text("Save Transaction"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
