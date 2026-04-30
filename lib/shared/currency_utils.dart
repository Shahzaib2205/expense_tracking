import 'package:intl/intl.dart';

class CurrencyUtils {
  static String formatCurrency(num amount) {
    final fmt = NumberFormat.currency(locale: 'en_PK', symbol: '₨', decimalDigits: 2);
    return fmt.format(amount);
  }
}
