import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jebek_app/models/product.dart';
import 'package:jebek_app/screens/products/product_detail_screen.dart';
import 'package:jebek_app/services/api_service.dart';
import 'package:jebek_app/utils/utils.dart';

class ProductListScreen extends StatefulWidget {
  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final ScrollController _scrollController = ScrollController();
  List<Product> products = [];
  int currentPage = 1;
  bool isLoading = false;
  bool hasMore = true;
  final String baseUrl = "/products";
  String searchQuery = "";
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    fetchProducts();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          hasMore) {
        fetchProducts();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> fetchProducts() async {
    if (isLoading) return;

    setState(() => isLoading = true);

    try {
      final response = await ApiService.fetchPaginated<Product>(
        baseUrl,
        currentPage,
        Product.fromJson,
        queryParameters:
            searchQuery.isNotEmpty ? {"search": searchQuery} : null,
      );

      setState(() {
        products.addAll(response.data);
        currentPage++;
        hasMore = response.hasMore;
      });
    } catch (e) {
      print("Error al cargar productos: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Productos", style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Buscar producto...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                if (_debounce?.isActive ?? false) _debounce!.cancel();
                // Se crea un nuevo Timer que se ejecutará después de 300 milisegundos
                _debounce = Timer(const Duration(milliseconds: 300), () {
                  // Actualizamos el query y reiniciamos la lista
                  setState(() {
                    searchQuery = value;
                    products.clear();
                    currentPage = 1;
                    hasMore = true;
                  });
                  fetchProducts();
                });
              },
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _refreshData();
        },
        child: ListView.builder(
          controller: _scrollController,
          itemCount: products.length + (isLoading ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == products.length) {
              return _renderLoadingIndicator();
            }
            final product = products[index];
            return _renderProductCard(product);
          },
        ),
      ),
      floatingActionButton: _renderFloatingActionButton(),
    );
  }

  Widget _renderLoadingIndicator() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _renderProductCard(Product product) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),
        leading: Container(
          decoration: BoxDecoration(
            color: Colors.blueAccent,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(8),
          child: const Icon(Icons.shopping_bag, color: Colors.white, size: 30),
        ),
        title: Text(
          product.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Precio: ${formatCurrency(product.price)}",
                style: const TextStyle(color: Colors.green),
              ),
              const SizedBox(height: 4),
              Text(
                "Costo: ${formatCurrency(product.cost)}",
                style: const TextStyle(color: Colors.orange),
              ),
              const SizedBox(height: 4),
              Text(
                "Stock: ${product.stock}",
                style: TextStyle(
                  color: product.stock > 0 ? Colors.black : Colors.red,
                ),
              ),
            ],
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailScreen(productId: product.id),
            ),
          ).then((value) {
            if (value == true) {
              _refreshData();
            }
          });
        },
      ),
    );
  }

  void _refreshData() {
    setState(() {
      products.clear();
      currentPage = 1;
      hasMore = true;
    });
    fetchProducts();
  }

  Widget _renderFloatingActionButton() {
    return FloatingActionButton(
      heroTag: 'add_product',
      onPressed: () async {
        final response = await Navigator.pushNamed(context, '/create_product');
        if (response == true) {
          _refreshData();
        }
      },
      child: Icon(Icons.add),
    );
  }
}
