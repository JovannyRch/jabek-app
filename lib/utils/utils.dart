String formatCurrency(dynamic amount) {
  if (amount is String) {
    amount = double.tryParse(amount);
  }
  if (amount is int) {
    amount = amount.toDouble();
  }
  if (amount is double) {
    return "\$${amount.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => "${m[1]},")}";
  } else {
    return "\$0.00";
  }
}
