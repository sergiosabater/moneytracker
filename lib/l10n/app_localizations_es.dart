// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'MONEY TRACKER';

  @override
  String get balance => 'Saldo:';

  @override
  String get incomes => 'Ingresos';

  @override
  String get expenses => 'Gastos';

  @override
  String get newTransaction => 'Nueva Transacción';

  @override
  String get income => 'Ingreso';

  @override
  String get expense => 'Gasto';

  @override
  String get amount => 'CANTIDAD';

  @override
  String get description => 'DESCRIPCIÓN';

  @override
  String get enterDescription => 'Ingrese descripción';

  @override
  String get noDescription => 'Sin descripción';

  @override
  String get add => 'Agregar';

  @override
  String get noTransactionsYet => 'Aún no hay transacciones';

  @override
  String get transactionOptions => 'Opciones de Transacción';

  @override
  String get edit => 'Editar';

  @override
  String get delete => 'Eliminar';

  @override
  String get confirmDelete => 'Eliminar Transacción';

  @override
  String get confirmDeleteMessage =>
      '¿Estás seguro de que quieres eliminar esta transacción?';

  @override
  String get cancel => 'Cancelar';

  @override
  String get noDescriptionTitle => 'Sin Descripción';

  @override
  String get noDescriptionMessage =>
      '¿Seguro que quiere agregar una transacción sin descripción?';

  @override
  String get transactionDeleted => 'Transacción eliminada';

  @override
  String get transactionAdded => 'Transacción agregada';
}
