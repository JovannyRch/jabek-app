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
        ).showSnackBar(SnackBar(content: Text("Gasto registrado con éxito")));
        Navigator.pop(context, true);
      } catch (e) {
        print("Error al registrar el gasto: $e");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error al registrar el gasto")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text("Registrar Gasto", style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _conceptController,
                decoration: InputDecoration(labelText: "Concepto"),
                validator: (value) => value!.isEmpty ? "Campo requerido" : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(labelText: "Monto"),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? "Campo requerido" : null,
              ),
              SizedBox(height: 16),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: "Fecha",
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _selectedDate != null
                        ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
                        : "Selecciona una fecha",
                  ),
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton(onPressed: _submitForm, child: Text("Registrar")),
            ],
          ),
        ),
      ),
    );
  }
}
