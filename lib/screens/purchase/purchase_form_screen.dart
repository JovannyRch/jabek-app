import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jebek_app/services/api_service.dart';

class PurchaseFormScreen extends StatefulWidget {
  @override
  _PurchaseFormScreenState createState() => _PurchaseFormScreenState();
}

class _PurchaseFormScreenState extends State<PurchaseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _conceptController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  DateTime? _selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final expenseData = {
        "concept": _conceptController.text,
        "amount": _amountController.text,
        "date":
            _selectedDate != null
                ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
                : null,
      };

      try {
        // Aquí llamas a tu servicio API para enviar el gasto
        await ApiService.post("/expenses", expenseData);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Compra registrada con éxito")));
        Navigator.pop(context, true);
      } catch (e) {
        print("Error al registrar la compra: $e");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error al registrar la compra")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(
          "Registrar Compra",
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
                    // Campo para concepto con un ícono descriptivo
                    TextFormField(
                      controller: _conceptController,
                      decoration: InputDecoration(
                        labelText: "Concepto",
                        hintText: "Ingrese el concepto del gasto",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.description),
                      ),
                      validator:
                          (value) => value!.isEmpty ? "Campo requerido" : null,
                    ),
                    const SizedBox(height: 16),
                    // Campo para monto con ícono de dinero
                    TextFormField(
                      controller: _amountController,
                      decoration: InputDecoration(
                        labelText: "Monto",
                        hintText: "Ingrese el monto",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.attach_money),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator:
                          (value) => value!.isEmpty ? "Campo requerido" : null,
                    ),
                    const SizedBox(height: 16),
                    // Selector de fecha con ícono de calendario
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: "Fecha",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          _selectedDate != null
                              ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
                              : "Selecciona una fecha",
                          style: TextStyle(
                            fontSize: 16,
                            color:
                                _selectedDate != null
                                    ? Colors.black
                                    : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Botón de registro que ocupa todo el ancho
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          "Registrar",
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
}
