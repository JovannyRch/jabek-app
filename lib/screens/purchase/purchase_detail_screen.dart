import 'package:flutter/material.dart';
import 'package:jebek_app/models/expense.dart';
import 'package:jebek_app/services/api_service.dart';
import 'package:jebek_app/utils/utils.dart';

class ExpenseDetailScreen extends StatelessWidget {
  final Expense expense;

  const ExpenseDetailScreen({Key? key, required this.expense})
    : super(key: key);

  void _editExpense(BuildContext context) {
    // Lógica para editar la compra, por ejemplo, navegar a un formulario de edición.
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Editar compra")));
  }

  void _deleteExpense(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Eliminar gasto"),
            content: const Text("¿Estás seguro de eliminar este gasto?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Cancelar"),
              ),
              TextButton(
                onPressed: () {
                  ApiService.delete("/expenses/${expense.id}").then((
                    statusCode,
                  ) {
                    if (statusCode == 200) {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop(true);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Compra eliminada")),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Error al eliminar la compra"),
                        ),
                      );
                    }
                  });
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
          expense.concept,
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          /*    IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Editar Compra',
            onPressed: () => _editExpense(context),
          ), */
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Eliminar Compra',
            onPressed: () => _deleteExpense(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tarjeta con información principal de la compra
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
                    // Título centrado con el concepto
                    Center(
                      child: Text(
                        expense.concept,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Monto: ${formatCurrency(expense.amount)}",
                      style: const TextStyle(fontSize: 18, color: Colors.green),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Fecha: ${expense.date}",
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
