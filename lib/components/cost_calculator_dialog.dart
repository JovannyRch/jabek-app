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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      title: const Text(
        'Calculadora de Costos',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Sección: Componentes de costo
            _buildTextField(
              lotPriceController,
              'Precio total del lote (\$)',
              icon: Icons.attach_money,
            ),
            const SizedBox(height: 10),
            _buildTextField(
              customsController,
              'Impuestos aduaneros (\$)',
              icon: Icons.money_off,
            ),
            const SizedBox(height: 10),
            _buildTextField(
              shippingController,
              'Costo de envío (\$)',
              icon: Icons.local_shipping,
            ),
            const SizedBox(height: 10),
            _buildTextField(
              storageController,
              'Costos de almacenamiento (\$)',
              icon: Icons.warehouse,
            ),
            const SizedBox(height: 10),
            _buildTextField(
              adminController,
              'Costos administrativos (\$)',
              icon: Icons.business_center,
            ),
            const SizedBox(height: 10),
            _buildTextField(
              generalExpensesController,
              'Gastos (\$)',
              icon: Icons.receipt_long,
            ),
            const SizedBox(height: 10),
            _buildTextField(
              fixedCostsController,
              'Gastos fijos (\$)',
              icon: Icons.money,
            ),

            const SizedBox(height: 20),
            // Sección: Totales calculados
            _buildReadOnlyField(
              formatCurrency(generalExpensesTotal),
              'Total de costos de compra (general)',
            ),
            const SizedBox(height: 10),
            _buildTextField(
              percentageController,
              'Porcentaje de los costos a cada producto (%)',
              icon: Icons.percent,
            ),
            const SizedBox(height: 10),
            _buildReadOnlyField(
              formatCurrency(totalCostsProduct),
              'Total de costos para el producto (\$)',
            ),
            const SizedBox(height: 10),
            _buildReadOnlyField(
              formatCurrency(
                totalCostsProduct +
                    (double.tryParse(lotPriceController.text) ?? 0),
              ),
              'Suma de precio más el costo (\$)',
            ),
            const SizedBox(height: 10),
            _buildTextField(
              quantityController,
              'Cantidad de productos',
              icon: Icons.confirmation_number,
            ),

            const SizedBox(height: 20),
            // Resumen final: Costo unitario calculado
            Center(
              child: Text(
                'Costo unitario: ${formatCurrency(calculatedCost)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, calculatedCost),
          child: const Text('Usar este costo'),
        ),
      ],
    );
  }

  /// Función helper para construir un TextField editable con un diseño uniforme.
  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    IconData? icon,
    TextInputType keyboardType = TextInputType.number,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 16,
        ),
      ),
      keyboardType: keyboardType,
      onChanged: (_) => _calculateCost(),
    );
  }

  /// Función helper para construir un TextField de solo lectura (para mostrar totales)
  Widget _buildReadOnlyField(String value, String label) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.grey.shade200,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 16,
        ),
      ),
      controller: TextEditingController(text: value),
      readOnly: true,
      enabled: false,
    );
  }
}
