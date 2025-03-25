import 'package:jebek_app/models/product.dart';

class Sale {
  final int id;
  final String folio;
  final int productId;
  final int userId;
  final String unitPrice;
  final int quantity;
  final String totalPrice;
  final String profit;
  final String date;
  final Product product;


  Sale({
    required this.id,
    required this.folio,
    required this.productId,
    required this.userId,
    required this.unitPrice,
    required this.quantity,
    required this.totalPrice,
    required this.profit,
    required this.date,
    required this.product,
  });

  factory Sale.fromJson(Map<String, dynamic> json) {
    return Sale(
      id: json['id'],
      folio: json['folio'],
      productId: json['product_id'],
      userId: json['user_id'],
      unitPrice: json['unit_price'],
      quantity: json['quantity'],
      totalPrice: json['total_price'],
      profit: json['profit'],
      date: json['date'],
      product: Product.fromJson(json['product']),
    );
  }
}
