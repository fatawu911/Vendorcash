class TransactionModel {
  String phone;
  double amount;
  String type;
  String network;
  DateTime date;

  TransactionModel({
    required this.phone,
    required this.amount,
    required this.type,
    required this.network,
    required this.date,
  });
}