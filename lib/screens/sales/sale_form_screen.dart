import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jebek_app/models/product.dart';
import 'package:jebek_app/models/request/sale_request.dart';
import 'package:jebek_app/services/api_service.dart';

class SaleFormScreen extends StatefulWidget {
  @override
  _SaleFormScreenState createState() => _SaleFormScreenState();
}

class _SaleFormScreenState extends State<SaleFormScreen> {
  final _formKey = GlobalKey<FormState>();

  List<Product> products = [];
  Product? selectedProduct;
  int quantity = 1;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts({String searchQuery = ""}) async {
    try {
      final response = await ApiService.fetchPaginated<Product>(
        "/products",
        1,
        Product.fromJson,
        queryParameters: searchQuery.isNotEmpty ? {"search": searchQuery} : {},
      );
      setState(() {
        products = response.data;
        if (products.isNotEmpty) {
          selectedProduct = products.first;
        }
      });
    } catch (e) {
      print("Error al obtener productos: $e");
    }
  }

  Future<void> submitSale() async {
    if (!_formKey.currentState!.validate() || selectedProduct == null) return;

    _formKey.currentState!.save();

    SaleRequest sale = SaleRequest(
      productId: selectedProduct!.id,
      quantity: quantity,
      date: DateFormat('yyyy-MM-dd').format(selectedDate),
    );

    try {
      final response = await ApiService.post("/sales", sale.toJson());
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Venta registrada con éxito")));
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error al registrar la venta")));
    }
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != selectedDate) {
      setState(() => selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text("Registrar Venta", style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => showProductSelector(context),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: "Selecciona un producto",
                    border: OutlineInputBorder(),
                  ),
                  child: Text(selectedProduct?.name ?? "Seleccionar producto"),
                ),
              ),

              TextFormField(
                decoration: InputDecoration(labelText: "Cantidad"),
                keyboardType: TextInputType.number,
                initialValue: "1",
                validator: (value) {
                  if (value == null ||
                      int.tryParse(value) == null ||
                      int.parse(value) <= 0) {
                    return "Ingrese una cantidad válida";
                  }
                  return null;
                },
                onSaved: (value) => quantity = int.parse(value!),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    "Fecha: ${DateFormat('yyyy-MM-dd').format(selectedDate)}",
                  ),
                  Spacer(),
                  ElevatedButton(
                    onPressed: () => selectDate(context),
                    child: Text("Seleccionar fecha"),
                  ),
                ],
              ),
              SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: submitSale,
                  child: Text(
                    "Registrar Venta",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> showProductSelector(BuildContext context) async {
    TextEditingController searchController = TextEditingController();
    List<Product> filteredProducts = products;

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            void onSearchChanged(String query) {
              fetchProducts(searchQuery: query);
            }

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 16),
                    TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: "Buscar producto...",
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (value) {
                        setModalState(() {});
                        onSearchChanged(value);
                      },
                    ),
                    SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(products[index].name),
                            subtitle: Text("\$${products[index].price}"),
                            onTap: () {
                              setState(() => selectedProduct = products[index]);
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
