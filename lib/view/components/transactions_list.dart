import 'package:flutter/material.dart';
import 'package:moneytracker/controller/transactions_provider.dart';
import 'package:moneytracker/model/transaction.dart';
import 'package:provider/provider.dart';

class TransactionsList extends StatelessWidget {
  const TransactionsList({super.key});

  @override
  Widget build(BuildContext context) {
    final transactions = Provider.of<TransactionsProvider>(
      context,
    ).transactions;

    return Expanded(
      child: Container(
        decoration: BoxDecoration(color: Colors.white),
        child: ListView.builder(
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final transaction = transactions[index];
            final type = transaction.type == TransactionType.income
                ? 'Income'
                : 'Expense';
            final value = transaction.type == TransactionType.expense
                ? '-\$ ${transaction.amount.abs().toStringAsFixed(2)}'
                : '\$ ${transaction.amount.toStringAsFixed(2)}';
            final color = transaction.type == TransactionType.expense
                ? Colors.red
                : Colors.teal;
            return ListTile(
              title: Text(transaction.description),
              subtitle: Text(type),
              trailing: Text(
                value,
                style: TextStyle(fontSize: 14, color: color),
              ),
            );
          },
        ),
      ),
    );
  }
}
