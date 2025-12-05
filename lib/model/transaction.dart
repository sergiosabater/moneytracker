class Transaction {
  final TransactionType type;
  final double amount;
  final String description;
  final DateTime dateTime;
  
  Transaction({
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
