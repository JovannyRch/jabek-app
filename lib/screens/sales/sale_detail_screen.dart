import 'package:flutter/material.dart';
import 'package:jebek_app/models/sale.dart';
import 'package:jebek_app/services/api_service.dart';
import 'package:jebek_app/utils/utils.dart';

class SaleDetailScreen extends StatelessWidget {
  final Sale sale;

  const SaleDetailScreen({Key? key, required this.sale}) : super(key: key);

  void _editSale(BuildContext context) {
    // Lógica para editar la venta (por ejemplo, navegar a una pantalla de edición)
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Editar venta")));
  }

  void _deleteSale(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Eliminar Venta"),
            content: const Text("¿Estás seguro de eliminar esta venta?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Cancelar"),
              ),
              TextButton(
                onPressed: () async {
                  final statusCode = ApiService.delete("/sales/${sale.id}");

                  if (statusCode != 200) {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop(true);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Venta eliminada")),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Error al eliminar venta")),
                    );
                  }
                },
                child: const Text("Eliminar"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Venta ${sale.folio}",
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          /*   IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editSale(context),
            tooltip: "Editar venta",
          ), */
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deleteSale(context),
            tooltip: "Eliminar venta",
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tarjeta con información principal de la venta
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 16.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        "Venta ${sale.folio}",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Producto: ${sale.product?.name}",
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Cantidad: ${sale.quantity}",
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Total: ${formatCurrency(sale.totalPrice)}",
                      style: const TextStyle(fontSize: 18, color: Colors.green),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text(
                          "Ganancia: ",
                          style: TextStyle(fontSize: 18),
                        ),
                        Text(
                          formatCurrency(sale.profit),
                          style: TextStyle(
                            fontSize: 18,
                            color: sale.profit >= 0 ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Fecha: ${formatDate(sale.date)}",
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
