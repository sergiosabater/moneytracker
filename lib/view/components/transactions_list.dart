import 'package:flutter/material.dart';
import 'package:moneytracker/controller/transactions_provider.dart';
import 'package:moneytracker/l10n/app_localizations.dart';
import 'package:moneytracker/model/transaction.dart';
import 'package:moneytracker/view/components/transaction_options_dialog.dart';
import 'package:provider/provider.dart';
import 'package:moneytracker/view/components/transaction_delete_dialog.dart';

class TransactionsList extends StatelessWidget {
  const TransactionsList({super.key});

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showTransactionOptions(BuildContext context, Transaction transaction) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return TransactionOptionsDialog(
          onEdit: () {
            // TODO: Implementar edición
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Edit feature coming soon'),
                duration: Duration(seconds: 2),
              ),
            );
          },
          onDelete: () {
            _showDeleteConfirmation(context, transaction);
          },
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          child: child,
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, Transaction transaction) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return TransactionDeleteDialog(
          onConfirm: () {
            Provider.of<TransactionsProvider>(
              context,
              listen: false,
            ).deleteTransaction(transaction.id!);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Transaction deleted'),
                duration: Duration(seconds: 2),
                backgroundColor: Colors.red,
              ),
            );
          },
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          child: child,
        );
      },
    );
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
                  return InkWell(
                    onLongPress: () {
                      _showTransactionOptions(context, transaction);
                    },
                    child: ListTile(
                      title: Text(transaction.description),
                      subtitle: Text(
                        '$type • ${_formatDate(transaction.dateTime)}',
                      ),
                      trailing: Text(
                        value,
                        style: TextStyle(fontSize: 14, color: color),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
