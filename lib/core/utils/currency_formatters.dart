import 'package:intl/intl.dart';

class CurrencyFormatters {
  const CurrencyFormatters._();

  static final NumberFormat _randFormatter = NumberFormat.currency(
    locale: 'en_ZA',
    symbol: 'R ',
    decimalDigits: 0,
  );

  static String rand(num value) => _randFormatter.format(value);

  static double parseRand(String value) {
    final normalized = value.replaceAll(RegExp(r'[^0-9.-]'), '');
    return double.tryParse(normalized) ?? 0;
  }

  static String randInput(num value) => value.toStringAsFixed(0);
}
