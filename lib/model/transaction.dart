class Transaction {
  final int? id;
  final TransactionType type;
  final double amount;
  final String description;
  final DateTime dateTime;

  Transaction({
    this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.dateTime,
  });
}

enum TransactionType {
  income,
  expense,
}