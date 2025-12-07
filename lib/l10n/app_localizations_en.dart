// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'MONEY TRACKER';

  @override
  String get balance => 'Balance: ';

  @override
  String get incomes => 'Incomes';

  @override
  String get expenses => 'Expenses';

  @override
  String get newTransaction => 'New Transaction';

  @override
  String get income => 'Income';

  @override
  String get expense => 'Expense';

  @override
  String get amount => 'AMOUNT';

  @override
  String get description => 'DESCRIPTION';

  @override
  String get enterDescription => 'Enter description';

  @override
  String get noDescription => 'No description';

  @override
  String get add => 'Add';
}
