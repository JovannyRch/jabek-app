import 'package:flutter/material.dart';
import 'package:jebek_app/components/cost_calculator_dialog.dart';
import 'package:jebek_app/components/price_calculator_dialog.dart';
import 'package:jebek_app/services/api_service.dart';

class CreateProductScreen extends StatefulWidget {
  @override
  _CreateProductScreenState createState() => _CreateProductScreenState();
}

class _CreateProductScreenState extends State<CreateProductScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController costController = TextEditingController();
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
      final cost = double.tryParse(costController.text) ?? 0.0;
      final stock = int.tryParse(stockController.text) ?? 0;

      if (name.isEmpty || price <= 0) {
        throw Exception('Nombre y precio son requeridos');
      }

      final response = await ApiService.post('/products', {
        'name': name,
        'price': price,
        'cost': cost,
        'stock': stock,
      });

      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Producto creado: ${response['name']}')),
      );

      // Limpiar los campos después de crear el producto
      nameController.clear();
      priceController.clear();
      costController.clear();
      stockController.clear();
      Navigator.pop(context, true);
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

  Future<void> _openCostCalculator(BuildContext context) async {
    final calculatedCost = await showDialog<double>(
      context: context,
      builder: (context) => CostCalculatorDialog(),
    );

    if (calculatedCost != null) {
      setState(() {
        costController.text = calculatedCost.toStringAsFixed(
          2,
        ); // Actualiza el campo de costo
      });
    }
  }

  Future<void> _openSalePriceCalculator(BuildContext context) async {
    final cost = double.tryParse(costController.text) ?? 0.0;

    if (cost <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ingresa un costo válido primero')),
      );
      return;
    }

    final salePrice = await showDialog<double>(
      context: context,
      builder: (context) => SalePriceCalculatorDialog(initialCost: cost),
    );

    if (salePrice != null) {
      setState(() {
        priceController.text = salePrice.toStringAsFixed(
          2,
        ); // Asigna el precio con IVA al campo
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crear Producto', style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
      ),
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

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: costController,
                      decoration: InputDecoration(
                        labelText: 'Costo unitario',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.calculate),
                    onPressed: () => _openCostCalculator(context),
                    tooltip: 'Calcular costo',
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: priceController,
                      decoration: InputDecoration(
                        labelText: 'Precio',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.calculate),
                    onPressed: () => _openSalePriceCalculator(context),
                    tooltip: 'Calcular costo',
                  ),
                ],
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
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  child: Text(
                    'Crear Producto',
                    style: TextStyle(color: Colors.white),
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
