import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moneytracker/controller/transactions_provider.dart';
import 'package:moneytracker/l10n/app_localizations.dart';
import 'package:moneytracker/model/transaction.dart';
import 'package:provider/provider.dart';

class AddTransactionDialog extends StatefulWidget {
  const AddTransactionDialog({super.key});

  @override
  State<AddTransactionDialog> createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends State<AddTransactionDialog> {
  int typeIndex = 0;
  TransactionType type = TransactionType.income;
  double amount = 0.0;
  String description = '';

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      height: 680,
      width: double.infinity,
      child: Column(
        children: [
          Container(
            height: 6,
            width: 48,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                Text(
                  AppLocalizations.of(context)!.newTransaction,
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.teal,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 40),
              ],
            ),
          ),
          CupertinoSlidingSegmentedControl<int>(
            groupValue: typeIndex,
            onValueChanged: (value) {
              setState(() {
                typeIndex = value!;
                type = typeIndex == 0
                    ? TransactionType.income
                    : TransactionType.expense;
              });
            },
            children: {
              0: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Text(AppLocalizations.of(context)!.income),
              ),
              1: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Text(AppLocalizations.of(context)!.expense),
              ),
            },
          ),
          const SizedBox(height: 20),
          Text(
            AppLocalizations.of(context)!.amount,
            style: textTheme.bodySmall!.copyWith(color: Colors.teal),
          ),
          TextField(
            inputFormatters: [
              CurrencyTextInputFormatter.currency(symbol: '\$'),
            ],
            textAlign: TextAlign.center,
            decoration: const InputDecoration.collapsed(
              hintText: '\$0.00',
              hintStyle: TextStyle(color: Colors.grey),
            ),
            keyboardType: TextInputType.number,
            autofocus: true,
            onChanged: (value) {
              final valueWithoutDollarSign = value.replaceAll('\$', '');
              final valueWithoutCommas = valueWithoutDollarSign.replaceAll(
                ',',
                '',
              );
              if (valueWithoutCommas.isNotEmpty) {
                amount = double.parse(valueWithoutCommas);
              }
            },
          ),
          const SizedBox(height: 20),
          Text(
            AppLocalizations.of(context)!.description,
            style: textTheme.bodySmall!.copyWith(color: Colors.teal),
          ),
          TextField(
            textAlign: TextAlign.center,
            decoration: InputDecoration.collapsed(
              hintText: AppLocalizations.of(context)!.enterDescription,
              hintStyle: const TextStyle(color: Colors.grey),
            ),
            keyboardType: TextInputType.text,
            onChanged: (value) {
              description = value;
            },
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 150,
            child: ElevatedButton(
              onPressed: () {
                final transaction = Transaction(
                  type: type,
                  amount: type == TransactionType.expense ? -amount : amount,
                  description: description.isEmpty
                      ? AppLocalizations.of(context)!.noDescription
                      : description,
                  dateTime: DateTime.now(),
                );
                // Add transaction
                Provider.of<TransactionsProvider>(
                  context,
                  listen: false,
                ).addTransaction(transaction);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              child: Text(
                AppLocalizations.of(context)!.add,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
