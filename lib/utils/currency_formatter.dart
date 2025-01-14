import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final _numberFormat = NumberFormat('#,###', 'fr');

  static String formatAmount(dynamic amount) {
    if (amount == null) return '0 CFA';
    
    // Convert to integer if it's a string
    int? numericAmount;
    if (amount is String) {
      numericAmount = int.tryParse(amount);
    } else if (amount is num) {
      numericAmount = amount.toInt();
    }
    
    if (numericAmount == null) return '0 CFA';
    
    // Format with thousands separator
    return '${_numberFormat.format(numericAmount)} CFA';
  }

  static String formatSalaryRange(String? minSalary, String? maxSalary) {
    final min = minSalary != null ? formatAmount(minSalary) : '0 CFA';
    final max = maxSalary != null ? formatAmount(maxSalary) : '0 CFA';
    return '$min - $max';
  }
}
