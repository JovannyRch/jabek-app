import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jebek_app/models/product.dart';
import 'package:jebek_app/models/request/sale_request.dart';
import 'package:jebek_app/services/api_service.dart';
import 'package:jebek_app/utils/utils.dart';

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
          //find the first product with stock > 0
          selectedProduct = products.firstWhere(
            (product) => product.stock > 0,
            orElse:
                () => Product(id: 0, name: "N/A", price: 0, stock: 0, cost: 0),
          );
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
        title: const Text(
          "Registrar Venta",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Selector de producto con InputDecorator personalizado
                    GestureDetector(
                      onTap: () => showProductSelector(context),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: "Selecciona un producto",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Icon(Icons.shopping_bag),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              selectedProduct?.name ?? "Seleccionar producto",
                              style: TextStyle(
                                fontSize: 16,
                                color:
                                    selectedProduct != null
                                        ? Colors.black
                                        : Colors.grey,
                              ),
                            ),
                            if (selectedProduct != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  "Existencias disponible: ${selectedProduct?.stock ?? 0}",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Campo de cantidad con validación y estilo
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: "Cantidad",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.confirmation_number),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      initialValue: "1",

                      validator: (value) {
                        if (value == null ||
                            int.tryParse(value) == null ||
                            int.parse(value) <= 0) {
                          return "Ingrese una cantidad válida";
                        }

                        if (selectedProduct != null &&
                            int.parse(value) > selectedProduct!.stock) {
                          return "Cantidad excede existencias";
                        }

                        return null;
                      },
                      onSaved: (value) => quantity = int.parse(value!),
                    ),
                    const SizedBox(height: 16),
                    // Selector de fecha con un diseño similar a un TextField
                    GestureDetector(
                      onTap: () => selectDate(context),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: "Fecha",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.calendar_today),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat('yyyy-MM-dd').format(selectedDate),
                              style: const TextStyle(fontSize: 16),
                            ),
                            const Icon(Icons.edit, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Botón para registrar la venta
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: submitSale,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          "Registrar Venta",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> showProductSelector(BuildContext context) async {
    TextEditingController searchController = TextEditingController();

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            void onSearchChanged(String query) {
              // Actualiza la lista de productos según el query
              fetchProducts(searchQuery: query);
            }

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Indicador de arrastre
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    // Título del selector
                    const Text(
                      "Seleccionar Producto",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Campo de búsqueda
                    TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: "Buscar producto...",
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (value) {
                        setModalState(() {});
                        onSearchChanged(value);
                      },
                    ),
                    const SizedBox(height: 16),
                    // Lista de productos dentro de un contenedor con altura fija
                    Container(
                      height: MediaQuery.of(context).size.height * 0.5,
                      child: ListView.builder(
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(12),
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(context).primaryColor,
                                child: Text(
                                  product.name.substring(0, 1).toUpperCase(),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Text(product.name),
                              subtitle: Text(
                                "Precio: ${formatCurrency(product.price)} - Existencias: ${product.stock}",
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                if (product.stock <= 0) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Producto sin existencias"),
                                    ),
                                  );
                                  return;
                                }

                                setState(() => selectedProduct = product);
                                Navigator.pop(context);
                              },
                            ),
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
