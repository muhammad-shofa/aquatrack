import 'package:intl/intl.dart';

class Formatters {
  static final NumberFormat _currency = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static String currency(num value) => _currency.format(value);
}
