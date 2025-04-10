import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:jebek_app/models/product.dart';
import 'package:jebek_app/screens/products/create_product_screen.dart';
import 'package:jebek_app/services/api_service.dart';
import 'package:jebek_app/utils/utils.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;

  const ProductDetailScreen({Key? key, required this.productId})
    : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Product product = Product(id: 0, name: "", price: 0.0, cost: 0.0, stock: 0);

  bool isLoading = false;

  @override
  void initState() {
    _fetchData();
    super.initState();
  }

  Future<void> _fetchData() async {
    try {
      setState(() {
        isLoading = true;
      });
      final response = await ApiService.get("/products/${widget.productId}");
      setState(() {
        product = Product.fromJson(jsonDecode(response.body));
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Error al cargar producto")));
    }
  }

  void handleOnDelete(BuildContext context) async {
    int statusCode = await ApiService.delete("/products/${widget.productId}");

    if (statusCode == 200) {
      Navigator.of(context).pop();
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Producto eliminado")));
    } else {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al eliminar producto")),
      );
    }
  }

  void _deleteProduct(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Confirmar Eliminación"),
            content: const Text("¿Estás seguro de eliminar este producto?"),
            actions: [
              TextButton(
                child: const Text("Cancelar"),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: const Text("Eliminar"),
                onPressed: () {
                  handleOnDelete(context);
                },
              ),
            ],
          ),
    );
  }

  // Función simulada para editar el producto
  void _editProduct(BuildContext context) async {
    final response = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateProductScreen(product: product),
      ),
    );

    if (response == true) {
      _fetchData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalle"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editProduct(context),
            tooltip: 'Editar Producto',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deleteProduct(context),
            tooltip: 'Eliminar Producto',
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Imagen del producto (placeholder)
                      Center(
                        child: Container(
                          width: 200,
                          height: 200,

                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            shape: BoxShape.circle,

                            /*  image: const DecorationImage(
                      // Reemplaza por la ruta de la imagen del producto, si la tienes
                      image: AssetImage("assets/product_placeholder.png"),
                      fit: BoxFit.cover,
                    ), */
                          ),
                          child: Icon(
                            Icons.shopping_bag,
                            color: ThemeData().primaryColor,
                            size: 80,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Nombre del producto
                      Center(
                        child: Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Card con información del precio y stock
                      SizedBox(
                        width: double.infinity,
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),

                          elevation: 5,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Precio
                                const Text(
                                  "Precio",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  formatCurrency(product.price),
                                  style: const TextStyle(
                                    fontSize: 22,
                                    color: Colors.green,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Costo
                                const Text(
                                  "Costo",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  formatCurrency(product.cost),
                                  style: const TextStyle(
                                    fontSize: 22,
                                    color: Colors.orange,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Stock
                                const Text(
                                  "Stock",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "${product.stock}",
                                  style: TextStyle(
                                    fontSize: 20,
                                    color:
                                        product.stock > 0
                                            ? Colors.black
                                            : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Sección de ventas relacionadas (como ejemplo, se muestra cantidad total vendida)
                      SizedBox(
                        width: double.infinity,
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 5,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Ventas Relacionadas",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Aquí podrías cargar dinámicamente los datos relacionados a las ventas
                                const Text(
                                  "Total vendido: 150 unidades",
                                  style: TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 8),
                                TextButton(
                                  child: const Text("Ver detalles de ventas"),
                                  onPressed: () {
                                    // Navegar a una pantalla de detalle de ventas o historial
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Navegar a historial de ventas",
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
