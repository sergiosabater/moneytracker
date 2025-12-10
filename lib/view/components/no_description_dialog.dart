import 'package:flutter/material.dart';
import 'package:moneytracker/l10n/app_localizations.dart';
import 'package:moneytracker/view/components/custom_dialog.dart';

class NoDescriptionDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const NoDescriptionDialog({super.key, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      icon: Icons.warning_rounded,
      iconColor: Colors.orange,
      title: AppLocalizations.of(context)!.noDescriptionTitle,
      message: AppLocalizations.of(context)!.noDescriptionMessage,
      actions: [
        DialogAction(
          label: AppLocalizations.of(context)!.cancel,
          color: Colors.red,
          onTap: () {
            Navigator.pop(context);
          },
        ),
        DialogAction(
          label: AppLocalizations.of(context)!.add,
          color: Colors.blue,
          onTap: () {
            Navigator.pop(context);
            onConfirm();
          },
        ),
      ],
    );
  }
}
