import 'package:flutter/material.dart';
import 'package:moneytracker/controller/transactions_provider.dart';
import 'package:moneytracker/l10n/app_localizations.dart';
import 'package:moneytracker/model/transaction.dart';
import 'package:moneytracker/view/components/transaction_delete_dialog.dart';
import 'package:moneytracker/view/components/transaction_options_dialog.dart';
import 'package:provider/provider.dart';

class TransactionsList extends StatefulWidget {
  const TransactionsList({super.key});

  @override
  State<TransactionsList> createState() => _TransactionsListState();
}

class _TransactionsListState extends State<TransactionsList> {
  bool _hasAnimatedInitially = false;

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
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
              SnackBar(
                content: Text(AppLocalizations.of(context)!.transactionDeleted),
                duration: const Duration(seconds: 2),
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

    // Marcar como animado después de la primera carga
    if (!isLoading && !_hasAnimatedInitially && transactions.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _hasAnimatedInitially = true;
          });
        }
      });
    }

    return Expanded(
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.teal))
            : transactions.isEmpty
                ? _EmptyState()
                : _TransactionsList(
                    transactions: transactions,
                    formatDate: _formatDate,
                    formatTime: _formatTime,
                    onTransactionLongPress: _showTransactionOptions,
                    hasAnimatedInitially: _hasAnimatedInitially,
                  ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.noTransactionsYet,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to add your first transaction',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}

class _TransactionsList extends StatelessWidget {
  final List<Transaction> transactions;
  final String Function(DateTime) formatDate;
  final String Function(DateTime) formatTime;
  final Function(BuildContext, Transaction) onTransactionLongPress;
  final bool hasAnimatedInitially;

  const _TransactionsList({
    required this.transactions,
    required this.formatDate,
    required this.formatTime,
    required this.onTransactionLongPress,
    required this.hasAnimatedInitially,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        // Animar en cascada solo la primera vez
        final shouldAnimateCascade = !hasAnimatedInitially;
        // Animar individualmente solo el primer item si ya se animó inicialmente
        final shouldAnimateNew = hasAnimatedInitially && index == 0;

        return _TransactionCard(
          key: ValueKey(transactions[index].id),
          transaction: transactions[index],
          formatDate: formatDate,
          formatTime: formatTime,
          onLongPress: () =>
              onTransactionLongPress(context, transactions[index]),
          animateEntry: shouldAnimateCascade || shouldAnimateNew,
          cascadeIndex: shouldAnimateCascade ? index : 0,
        );
      },
    );
  }
}

class _TransactionCard extends StatefulWidget {
  final Transaction transaction;
  final String Function(DateTime) formatDate;
  final String Function(DateTime) formatTime;
  final VoidCallback onLongPress;
  final bool animateEntry;
  final int cascadeIndex;

  const _TransactionCard({
    super.key,
    required this.transaction,
    required this.formatDate,
    required this.formatTime,
    required this.onLongPress,
    required this.animateEntry,
    required this.cascadeIndex,
  });

  @override
  State<_TransactionCard> createState() => _TransactionCardState();
}

class _TransactionCardState extends State<_TransactionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Delay en cascada solo para animación inicial
    final delay = widget.cascadeIndex * 100;

    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: widget.animateEntry ? 0.0 : 1.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: widget.animateEntry ? const Offset(0, 0.3) : Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    // Aplicar delay solo si es animación en cascada
    if (widget.animateEntry && widget.cascadeIndex > 0) {
      Future.delayed(Duration(milliseconds: delay), () {
        if (mounted) {
          _controller.forward();
        }
      });
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = widget.transaction.type == TransactionType.income;
    final color = isIncome ? Colors.teal : Colors.red;
    final icon = isIncome ? Icons.trending_up : Icons.trending_down;
    final typeLabel = isIncome
        ? AppLocalizations.of(context)!.income
        : AppLocalizations.of(context)!.expense;

    final value = widget.transaction.type == TransactionType.expense
        ? '-\$${widget.transaction.amount.abs().toStringAsFixed(2)}'
        : '+\$${widget.transaction.amount.toStringAsFixed(2)}';

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onLongPress: widget.onLongPress,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(color: Colors.grey.shade100, width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Icon container con animación sutil
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            color.withOpacity(0.15),
                            color.withOpacity(0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: color.withOpacity(0.2),
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Icon(icon, color: color, size: 24),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Transaction info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.transaction.description,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          
                          // Tipo de transacción
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: color.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              typeLabel,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: color,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          
                          // Fecha y hora - TEXTO MÁS GRANDE
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_month,
                                size: 14,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                widget.formatDate(widget.transaction.dateTime),
                                style: TextStyle(
                                  fontSize: 13, // Aumentado de 11 a 13
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Icon(
                                Icons.access_time,
                                size: 14,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                widget.formatTime(widget.transaction.dateTime),
                                style: TextStyle(
                                  fontSize: 13, // Aumentado de 11 a 13
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Amount con estilo mejorado
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            color.withOpacity(0.1),
                            color.withOpacity(0.05),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: color.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        value,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: color,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}