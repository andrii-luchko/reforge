class XpFormatter {
  static String compact(int number) {
    if (number < 1000) {
      return number.toString();
    } else if (number < 1000000) {
      final result = number / 1000;

      return '${_removeTrailingZeros(result)}K';
    } else if (number < 1000000000) {
      final result = number / 1000000;

      return '${_removeTrailingZeros(result)}M';
    } else {
      final result = number / 1000000000;

      return '${_removeTrailingZeros(result)}B';
    }
  }

  static String precise(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]} ',
    );
  }

  static String _removeTrailingZeros(double n) {
    return n.toStringAsFixed(n.truncateToDouble() == n ? 0 : 1);
  }
}
