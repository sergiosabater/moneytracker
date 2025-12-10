import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:moneytracker/controller/transactions_provider.dart';
import 'package:moneytracker/l10n/app_localizations.dart';
import 'package:moneytracker/model/transaction.dart';
import 'package:provider/provider.dart';
import 'package:moneytracker/view/components/no_description_dialog.dart';

class AddTransactionDialog extends StatefulWidget {
  const AddTransactionDialog({super.key});

  @override
  State<AddTransactionDialog> createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends State<AddTransactionDialog>
    with SingleTickerProviderStateMixin {
  TransactionType type = TransactionType.income;
  double amount = 0.0;
  String description = '';
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool get _isValid => amount > 0;

  void _handleSave() {
    if (!_isValid) return;

    // Si no hay descripción, mostrar diálogo de confirmación
    if (description.trim().isEmpty) {
      _showNoDescriptionDialog();
      return;
    }

    _saveTransaction();
  }

  void _showNoDescriptionDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return NoDescriptionDialog(
          onConfirm: () {
            _saveTransaction();
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

  void _saveTransaction() {
    final transaction = Transaction(
      type: type,
      amount: type == TransactionType.expense ? -amount : amount,
      description: description.trim().isEmpty
          ? AppLocalizations.of(context)!.noDescription
          : description,
      dateTime: DateTime.now(),
    );

    Provider.of<TransactionsProvider>(
      context,
      listen: false,
    ).addTransaction(transaction);

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.transactionAdded),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            height: 5,
            width: 40,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(3),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.pop(context),
                ),
                Text(
                  AppLocalizations.of(context)!.newTransaction,
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),

          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Type selector
                      _TypeSelector(
                        selectedType: type,
                        onTypeChanged: (newType) {
                          setState(() => type = newType);
                        },
                      ),

                      const SizedBox(height: 32),

                      // Amount field
                      _AmountField(
                        controller: _amountController,
                        type: type,
                        onChanged: (value) {
                          final valueWithoutDollarSign = value.replaceAll(
                            '\$',
                            '',
                          );
                          final valueWithoutCommas = valueWithoutDollarSign
                              .replaceAll(',', '');
                          setState(() {
                            amount = valueWithoutCommas.isNotEmpty
                                ? double.parse(valueWithoutCommas)
                                : 0.0;
                          });
                        },
                      ),

                      const SizedBox(height: 24),

                      // Description field
                      _DescriptionField(
                        controller: _descriptionController,
                        onChanged: (value) {
                          setState(() => description = value);
                        },
                      ),

                      const SizedBox(height: 32),
                      // Save button
                      _SaveButton(isEnabled: _isValid, onPressed: _handleSave),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Type Selector Component
class _TypeSelector extends StatelessWidget {
  final TransactionType selectedType;
  final ValueChanged<TransactionType> onTypeChanged;

  const _TypeSelector({
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _TypeOption(
            icon: Icons.arrow_downward,
            label: AppLocalizations.of(context)!.income,
            color: Colors.teal,
            isSelected: selectedType == TransactionType.income,
            onTap: () => onTypeChanged(TransactionType.income),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _TypeOption(
            icon: Icons.arrow_upward,
            label: AppLocalizations.of(context)!.expense,
            color: Colors.red,
            isSelected: selectedType == TransactionType.expense,
            onTap: () => onTypeChanged(TransactionType.expense),
          ),
        ),
      ],
    );
  }
}

class _TypeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.1)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade200,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : Colors.grey.shade400,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? color : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Amount Field Component
class _AmountField extends StatelessWidget {
  final TextEditingController controller;
  final TransactionType type;
  final ValueChanged<String> onChanged;

  const _AmountField({
    required this.controller,
    required this.type,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final color = type == TransactionType.income ? Colors.teal : Colors.red;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.amount,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            inputFormatters: [
              CurrencyTextInputFormatter.currency(symbol: '\$'),
            ],
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            decoration: InputDecoration.collapsed(
              hintText: '\$0.00',
              hintStyle: TextStyle(color: color.withValues(alpha: 0.3)),
            ),
            keyboardType: TextInputType.number,
            autofocus: true,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

// Description Field Component
class _DescriptionField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _DescriptionField({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.description,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            decoration: InputDecoration.collapsed(
              hintText: AppLocalizations.of(context)!.enterDescription,
              hintStyle: TextStyle(color: Colors.grey.shade400),
            ),
            keyboardType: TextInputType.text,
            onChanged: onChanged,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}

// Save Button Component
class _SaveButton extends StatelessWidget {
  final bool isEnabled;
  final VoidCallback onPressed;

  const _SaveButton({required this.isEnabled, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final color = isEnabled ? Colors.blue : Colors.grey;

    return InkWell(
      onTap: isEnabled ? onPressed : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context)!.add,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
