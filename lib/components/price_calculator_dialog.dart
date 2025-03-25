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
      title: Text('Calculadora de Precio de Venta'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Costo de compra: \$${widget.initialCost.toStringAsFixed(2)}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            TextField(
              controller: profitPercentageController,
              decoration: InputDecoration(
                labelText: 'Porcentaje de ganancia (%)',
                suffixText: '%',
              ),
              keyboardType: TextInputType.number,
              onChanged: (_) => _calculateSalePrice(),
            ),
            SizedBox(height: 20),
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
          child: Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed:
              () => Navigator.pop(
                context,
                salePriceWithIVA,
              ), // Retorna el precio con IVA
          child: Text('Usar este precio'),
        ),
      ],
    );
  }

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
