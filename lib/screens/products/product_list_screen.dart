import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jebek_app/models/product.dart';
import 'package:jebek_app/services/api_service.dart';

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
  final String baseUrl = "${ApiService.baseUrl}/products";

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

  Future<void> fetchProducts() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    final response = await http.get(Uri.parse("$baseUrl?page=$currentPage"));
    print("response: ${response.body}");
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> productList = data["data"];

      setState(() {
        products.addAll(
          productList.map((item) => Product.fromJson(item)).toList(),
        );
        currentPage++;
        hasMore = data["next_page_url"] != null;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Productos", style: TextStyle(color: Colors.white)),
        backgroundColor: ThemeData().primaryColor,
      ),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: products.length + (isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == products.length) {
            return Center(child: CircularProgressIndicator());
          }

          final product = products[index];
          return ListTile(
            title: Text(product.name),
            subtitle: Text(
              "Precio: \$${product.price} - Stock: ${product.stock}",
            ),
          );
        },
      ),
    );
  }
}
