class Product {
  int id;
  String name;
  double price;
  double cost;
  int stock;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.cost,
    required this.stock,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      price: double.parse(json['price'].toString()),
      cost: double.parse(json['cost'].toString()),
      stock: json['stock'],
    );
  }
}
