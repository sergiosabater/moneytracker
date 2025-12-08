import 'package:flutter/material.dart';
import 'package:moneytracker/controller/transactions_provider.dart';
import 'package:moneytracker/l10n/app_localizations.dart';
import 'package:moneytracker/model/transaction.dart';
import 'package:provider/provider.dart';

class TransactionsList extends StatelessWidget {
  const TransactionsList({super.key});

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionsProvider>(context);
    final transactions = provider.transactions;
    final isLoading = provider.isLoading;

    return Expanded(
      child: Container(
        decoration: const BoxDecoration(color: Colors.white),
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.teal))
            : transactions.isEmpty
            ? Center(
                child: Text(
                  AppLocalizations.of(context)!.noTransactionsYet,
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),
              )
            : ListView.builder(
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
                    subtitle: Text(
                      '$type • ${_formatDate(transaction.dateTime)}',
                    ),
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
