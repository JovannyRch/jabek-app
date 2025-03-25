class SaleRequest {
  final int productId;
  final int quantity;
  final String date;

  SaleRequest({
    required this.productId,
    required this.quantity,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {'product_id': productId, 'quantity': quantity, 'date': date};
  }
}
