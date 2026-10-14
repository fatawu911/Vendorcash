import 'package:flutter/material.dart';
import '../services/database_helper.dart';

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  List<Map<String, dynamic>> transactions = [];
  String searchQuery = "";
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    final data = await DatabaseHelper.instance.getTransactions();
    setState(() {
      transactions = data;
    });
  }

  Future<void> pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2026),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Records"),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: pickDate,
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      selectedDate == null
                          ? "Filter by Date"
                          : "${selectedDate!.day}/"
                          "${selectedDate!.month}/"
                          "${selectedDate!.year}",
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      selectedDate = null;
                    });
                  },
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              decoration: const InputDecoration(
                hintText: "Search by phone number",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),

          Expanded(
            child: transactions.isEmpty
                ? const Center(child: Text("No records yet"))
                : ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final tx = transactions[index];

                bool matchesSearch =
                tx['phone'].toString().contains(searchQuery);

                bool matchesDate = true;

                if (selectedDate != null) {
                  String txDate =
                  tx['date'].toString().substring(0, 10);

                  String filterDate =
                  selectedDate!.toString().substring(0, 10);

                  matchesDate = txDate == filterDate;
                }

                if (!matchesSearch || !matchesDate) {
                  return const SizedBox();
                }

                return Dismissible(
                  key: Key(tx['id'].toString()),
                  direction: DismissDirection.endToStart,

                  onDismissed: (direction) async {
                    await DatabaseHelper.instance
                        .deleteTransaction(tx['id']);
                    loadTransactions();

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Transaction deleted")),
                    );
                  },

                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding:
                    const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete,
                        color: Colors.white),
                  ),

                  child: Card(
                    margin: const EdgeInsets.all(10),
                    child: ListTile(
                      title: Text("GHS ${tx['amount']}"),
                      subtitle: Text(
                          "${tx['phone']} • ${tx['network']} • ${tx['type']}"),
                      trailing: Text(
                        tx['date']
                            .toString()
                            .substring(0, 10),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

