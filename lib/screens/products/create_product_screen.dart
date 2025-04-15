import 'package:flutter/material.dart';
import 'package:jebek_app/components/cost_calculator_dialog.dart';
import 'package:jebek_app/components/price_calculator_dialog.dart';
import 'package:jebek_app/models/product.dart';
import 'package:jebek_app/services/api_service.dart';

class CreateProductScreen extends StatefulWidget {
  Product? product;

  CreateProductScreen({Key? key, this.product}) : super(key: key);

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
  Product? product;
  bool isEditing = false;

  @override
  void initState() {
    if (widget.product != null) {
      product = widget.product;
      nameController.text = product!.name;
      priceController.text = product!.price.toString();
      costController.text = product!.cost.toString();
      stockController.text = product!.stock.toString();
      isEditing = true;
    }
    super.initState();
  }

  void _createOrUpdateProduct(BuildContext context) async {
    try {
      final name = nameController.text;
      final price = double.tryParse(priceController.text) ?? 0.0;
      final cost = double.tryParse(costController.text) ?? 0.0;
      final stock = int.tryParse(stockController.text) ?? 0;

      if (name.isEmpty || price <= 0) {
        throw Exception('Nombre y precio son requeridos');
      }

      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      final response =
          isEditing
              ? await ApiService.put('/products/${product!.id}', {
                'name': name,
                'price': price,
                'cost': cost,
                'stock': stock,
              })
              : await ApiService.post('/products', {
                'name': name,
                'price': price,
                'cost': cost,
                'stock': stock,
              });

      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Producto ${isEditing ? 'actualizado' : 'creado'}: ${response['name']}',
          ),
        ),
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
        title: Text(
          isEditing ? 'Editar Producto' : 'Crear Producto',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            // Puedes definir una GlobalKey<FormState>() si deseas validación
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Campo para el nombre del producto
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Nombre del Producto',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.label_outline),
                  ),
                ),
                SizedBox(height: 16.0),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: costController,
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Costo unitario',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.attach_money),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.0),
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
                      child: TextFormField(
                        controller: priceController,
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Precio',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.money_off),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.0),
                    IconButton(
                      icon: Icon(Icons.calculate),
                      onPressed: () => _openSalePriceCalculator(context),
                      tooltip: 'Calcular precio',
                    ),
                  ],
                ),
                SizedBox(height: 16.0),

                // Campo para total de unidades
                TextFormField(
                  controller: stockController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Total de unidades',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.storefront),
                  ),
                ),
                SizedBox(height: 24.0),

                // Indicador de carga o botón de acción
                if (isLoading)
                  Center(child: CircularProgressIndicator())
                else
                  ElevatedButton(
                    onPressed: () => _createOrUpdateProduct(context),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                    child: Text(
                      isEditing ? 'Actualizar Producto' : 'Crear Producto',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),

                // Mensaje de error en caso de que ocurra algo
                if (errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      errorMessage,
                      style: TextStyle(color: Colors.red, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
