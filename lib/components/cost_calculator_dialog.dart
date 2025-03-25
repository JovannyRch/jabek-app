import 'package:flutter/material.dart';
import 'package:jebek_app/components/text.dart';
import 'package:jebek_app/utils/utils.dart';

class CostCalculatorDialog extends StatefulWidget {
  @override
  _CostCalculatorDialogState createState() => _CostCalculatorDialogState();
}

class _CostCalculatorDialogState extends State<CostCalculatorDialog> {
  final TextEditingController lotPriceController = TextEditingController();
  final TextEditingController customsController = TextEditingController();
  final TextEditingController shippingController = TextEditingController();
  final TextEditingController storageController = TextEditingController();
  final TextEditingController adminController = TextEditingController();

  final TextEditingController generalExpensesController =
      TextEditingController();

  final TextEditingController fixedCostsController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();

  final TextEditingController percentageController = TextEditingController();

  double calculatedCost = 0.0;
  double generalExpensesTotal = 0.0;
  double totalCostsProduct = 0.0;

  void _calculateCost() {
    final lotPrice = double.tryParse(lotPriceController.text) ?? 0;
    final customs = double.tryParse(customsController.text) ?? 0;
    final shipping = double.tryParse(shippingController.text) ?? 0;
    final storage = double.tryParse(storageController.text) ?? 0;
    final admin = double.tryParse(adminController.text) ?? 0;
    final generalExpenses =
        double.tryParse(generalExpensesController.text) ?? 0;
    final fixedCosts = double.tryParse(fixedCostsController.text) ?? 0;
    final quantity = int.tryParse(quantityController.text) ?? 1;

    final percentage = double.tryParse(percentageController.text) ?? 0;

    final generalExpensesSum =
        (customs + shipping + storage + admin + generalExpenses + fixedCosts);

    setState(() {
      generalExpensesTotal = generalExpensesSum;
      totalCostsProduct = generalExpensesSum * (percentage / 100);
      calculatedCost = (totalCostsProduct + lotPrice) / quantity;
    });
  }

  @override
  void initState() {
    _calculateCost();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Calculadora de Costos'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: lotPriceController,
              decoration: InputDecoration(
                labelText: 'Precio total del lote (\$)',
              ),
              keyboardType: TextInputType.number,
              onChanged: (_) => _calculateCost(),
            ),
            TextField(
              controller: customsController,
              decoration: InputDecoration(
                labelText: 'Impuestos aduaneros (\$)',
              ),
              keyboardType: TextInputType.number,
              onChanged: (_) => _calculateCost(),
            ),
            TextField(
              controller: shippingController,
              decoration: InputDecoration(labelText: 'Costo de envío (\$)'),
              keyboardType: TextInputType.number,
              onChanged: (_) => _calculateCost(),
            ),
            TextField(
              controller: storageController,
              decoration: InputDecoration(
                labelText: 'Costos de almacenamiento (\$)',
              ),
              keyboardType: TextInputType.number,
              onChanged: (_) => _calculateCost(),
            ),
            TextField(
              controller: adminController,
              decoration: InputDecoration(
                labelText: 'Costos administrativos (\$)',
              ),
              keyboardType: TextInputType.number,
              onChanged: (_) => _calculateCost(),
            ),
            TextField(
              controller: generalExpensesController,
              decoration: InputDecoration(labelText: 'Gastos (\$)'),
              keyboardType: TextInputType.number,
              onChanged: (_) => _calculateCost(),
            ),
            TextField(
              controller: fixedCostsController,
              decoration: InputDecoration(labelText: 'Gastos fijos (\$)'),
              keyboardType: TextInputType.number,
              onChanged: (_) => _calculateCost(),
            ),

            SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                labelText: 'Total de los costos de compra (general)',
                enabled: false,
              ),
              readOnly: true,
              controller: TextEditingController(
                text: formatCurrency(generalExpensesTotal),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: percentageController,
              decoration: InputDecoration(
                labelText: 'Porcentaje de los costos a cada producto (%)',
              ),
              keyboardType: TextInputType.number,
              onChanged: (_) => _calculateCost(),
            ),
            TextField(
              decoration: InputDecoration(
                labelText: 'Total de costos para el producto (\$)',
                enabled: false,
              ),
              readOnly: true,
              controller: TextEditingController(
                text: formatCurrency(totalCostsProduct),
              ),
            ),
            TextField(
              decoration: InputDecoration(
                labelText: 'Suma de precio más el costo (\$)',
                enabled: false,
              ),
              readOnly: true,
              controller: TextEditingController(
                text: formatCurrency(
                  totalCostsProduct +
                      (double.tryParse(lotPriceController.text) ?? 0),
                ),
              ),
            ),
            TextField(
              controller: quantityController,
              decoration: InputDecoration(labelText: 'Cantidad de productos'),
              keyboardType: TextInputType.number,
              onChanged: (_) => _calculateCost(),
            ),
            SizedBox(height: 20),
            Text(
              'Costo unitario: ${formatCurrency(calculatedCost)}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, calculatedCost),
          child: Text('Usar este costo'),
        ),
      ],
    );
  }
}
