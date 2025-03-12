import 'package:flutter/material.dart';
import 'package:jebek_app/services/api_service.dart';

class CreateProductScreen extends StatefulWidget {
  @override
  _CreateProductScreenState createState() => _CreateProductScreenState();
}

class _CreateProductScreenState extends State<CreateProductScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController stockController = TextEditingController();

  bool isLoading = false;
  String errorMessage = '';

  void _createProduct(BuildContext context) async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final name = nameController.text;
      final price = double.tryParse(priceController.text) ?? 0.0;
      final stock = int.tryParse(stockController.text) ?? 0;

      if (name.isEmpty || price <= 0) {
        throw Exception('Nombre y precio son requeridos');
      }

      final response = await ApiService.createProduct(name, price, stock);

      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Producto creado: ${response['name']}')),
      );

      // Limpiar los campos después de crear el producto
      nameController.clear();
      priceController.clear();
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Crear Producto')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Nombre del Producto',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: priceController,
                decoration: InputDecoration(
                  labelText: 'Precio',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: stockController,
                decoration: InputDecoration(
                  labelText: 'Total de unidades',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 24.0),
              if (isLoading)
                CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: () => _createProduct(context),
                  child: Text('Crear Producto'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50), // Botón ancho
                  ),
                ),
              if (errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    errorMessage,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
