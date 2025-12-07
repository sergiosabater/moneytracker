import 'package:flutter/material.dart';
import 'package:moneytracker/controller/transactions_provider.dart';
import 'package:moneytracker/l10n/app_localizations.dart';
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
                ? AppLocalizations.of(context)!.income
                : AppLocalizations.of(context)!.expense;
            final value = transaction.type == TransactionType.expense
                ? '-\$ ${transaction.amount.abs().toStringAsFixed(2)}'
                : '\$ ${transaction.amount.toStringAsFixed(2)}';
            final color = transaction.type == TransactionType.expense
                ? Colors.red
                : Colors.teal;
            return ListTile(
              title: Text(transaction.description),
              subtitle: Text('$type • ${_formatDate(transaction.dateTime)}'),
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

  String _formatDate(DateTime date) {
    return '${date.day}-${date.month}-${date.year}';
  }
}
