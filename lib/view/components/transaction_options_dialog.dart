import 'package:flutter/material.dart';
import 'package:moneytracker/l10n/app_localizations.dart';
import 'package:moneytracker/view/components/custom_dialog.dart';

class TransactionOptionsDialog extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TransactionOptionsDialog({
    super.key,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      icon: Icons.settings,
      iconColor: Colors.teal,
      title: AppLocalizations.of(context)!.transactionOptions,
      actions: [
        DialogAction(
          label: AppLocalizations.of(context)!.edit,
          color: Colors.blue,
          icon: Icons.edit,
          onTap: () {
            Navigator.pop(context);
            onEdit();
          },
        ),
        DialogAction(
          label: AppLocalizations.of(context)!.delete,
          color: Colors.red,
          icon: Icons.delete,
          onTap: () {
            Navigator.pop(context);
            onDelete();
          },
        ),
      ],
    );
  }
}