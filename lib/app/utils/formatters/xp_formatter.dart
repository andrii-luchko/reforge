class XpFormatter {
  static String compact(int number, {String extSuffix = 'XP'}) {
    final absNumber = number.abs();
    String formattedNumber;

    if (absNumber < 1000) {
      formattedNumber = number.toString();
    } else {
      final double result;
      final String scaleSuffix;

      if (absNumber < 1000000) {
        result = number / 1000;
        scaleSuffix = 'K';
      } else if (absNumber < 1000000000) {
        result = number / 1000000;
        scaleSuffix = 'M';
      } else {
        result = number / 1000000000;
        scaleSuffix = 'B';
      }
      formattedNumber = '${_formatDouble(result)} $scaleSuffix';
    }

    if (extSuffix.isEmpty) return formattedNumber;

    final hasLetterOrDigit = RegExp('^[a-zA-Zа-яА-Я0-9]').hasMatch(extSuffix);
    final separator = hasLetterOrDigit ? ' ' : '';

    return '$formattedNumber$separator$extSuffix';
  }

  static String _formatDouble(double n) {
    return n.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');
  }

  static String precise(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]} ',
    );
  }
}
