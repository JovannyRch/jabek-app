import 'package:flutter/material.dart';
import 'package:jebek_app/services/api_service.dart';

class ProductListScreen extends StatefulWidget {
  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<dynamic> products = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  // Método para cargar la lista de productos
  Future<void> _loadProducts() async {
    try {
      final productList = await ApiService.getProducts();
      setState(() {
        products = productList;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Lista de Productos')),
      body: SafeArea(
        child:
            isLoading
                ? Center(child: CircularProgressIndicator())
                : errorMessage.isNotEmpty
                ? Center(child: Text(errorMessage))
                : products.length == 0
                ? _zeroState()
                : ListView.builder(
                  itemCount: products.length,

                  itemBuilder: (context, index) {
                    final product = products[index];
                    return ListTile(
                      title: Text('#${product['id']} - ${product['name']}'),
                      subtitle: Text(
                        'Precio: \$${product['price']} - Stock: ${product['stock']}',
                      ),
                    );
                  },
                ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.pushNamed(context, '/create_product');
          _loadProducts();
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _zeroState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2,
            size: 64.0,
            color: Theme.of(context).primaryColor,
          ),
          SizedBox(height: 16.0),
          Text('Aún no hay productos registrados'),
        ],
      ),
    );
  }
}
