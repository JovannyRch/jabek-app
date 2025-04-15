import 'package:flutter/material.dart';

class SalePriceCalculatorDialog extends StatefulWidget {
  final double initialCost; // Costo de compra (pasado desde el campo de costo)

  SalePriceCalculatorDialog({required this.initialCost});

  @override
  _SalePriceCalculatorDialogState createState() =>
      _SalePriceCalculatorDialogState();
}

class _SalePriceCalculatorDialogState extends State<SalePriceCalculatorDialog> {
  final TextEditingController profitPercentageController =
      TextEditingController();
  final double ivaPercentage = 0.16; // 16% de IVA (ajusta según tu país)
  double profitValue = 0.0;
  double salePriceWithoutIVA = 0.0;
  double ivaValue = 0.0;
  double salePriceWithIVA = 0.0;

  void _calculateSalePrice() {
    final cost = widget.initialCost;
    final profitPercentage =
        double.tryParse(profitPercentageController.text) ?? 0;

    setState(() {
      profitValue = cost * (profitPercentage / 100);
      salePriceWithoutIVA = cost + profitValue;
      ivaValue = salePriceWithoutIVA * ivaPercentage;
      salePriceWithIVA = salePriceWithoutIVA + ivaValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      title: const Text(
        'Calculadora de Precio de Venta',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Muestra el costo de compra (valor inicial) en negrita.
            Text(
              'Costo de compra: \$${widget.initialCost.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // TextField para ingresar el porcentaje de ganancia.
            TextField(
              controller: profitPercentageController,
              decoration: InputDecoration(
                labelText: 'Porcentaje de ganancia (%)',
                suffixText: '%',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
              ),
              keyboardType: TextInputType.number,
              onChanged: (_) => _calculateSalePrice(),
            ),
            const SizedBox(height: 20),
            // Resultados de la operación en filas
            _buildResultRow('Ganancia:', profitValue),
            _buildResultRow('Precio sin IVA:', salePriceWithoutIVA),
            _buildResultRow(
              'IVA (${(ivaPercentage * 100).toInt()}%):',
              ivaValue,
            ),
            _buildResultRow('Precio con IVA:', salePriceWithIVA, isTotal: true),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, salePriceWithIVA),
          child: const Text('Usar este precio'),
        ),
      ],
    );
  }

  /// Helper para construir cada fila de resultado
  Widget _buildResultRow(String label, double value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '\$${value.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Theme.of(context).primaryColor : null,
            ),
          ),
        ],
      ),
    );
  }
}
