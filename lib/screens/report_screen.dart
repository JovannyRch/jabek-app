import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jebek_app/screens/pdf_viewer.dart';
import 'package:jebek_app/services/api_service.dart';

enum ReportType { productCatalog, salesList, purchasesList }

enum FileFormat { excel, pdf }

class ReportScreen extends StatefulWidget {
  const ReportScreen({Key? key}) : super(key: key);

  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  ReportType _selectedReportType = ReportType.productCatalog;
  FileFormat _selectedFormat = FileFormat.excel;

  // Para ventas y compras, el rango de fechas
  DateTime? _startDate;
  DateTime? _endDate;

  final DateFormat _dateFormatter = DateFormat('yyyy-MM-dd');

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime initialDate = _startDate ?? DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime initialDate = _endDate ?? DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  // Función para exportar el reporte
  Future<void> _exportReport() async {
    // Aquí puedes construir el endpoint en función de la opción seleccionada.
    // Por ejemplo:
    //  - Producto: "/reports/products?format=excel" ó "/reports/products?format=pdf"
    //  - Ventas: "/reports/sales?format=excel&start_date=YYYY-MM-DD&end_date=YYYY-MM-DD"
    //  - Compras: "/reports/purchases?format=excel&start_date=YYYY-MM-DD&end_date=YYYY-MM-DD"
    String endpoint = '';
    String formatParam = _selectedFormat == FileFormat.excel ? 'excel' : 'pdf';

    switch (_selectedReportType) {
      case ReportType.productCatalog:
        endpoint = "${ApiService.baseUrl}/report/products?format=$formatParam";
        break;
      case ReportType.salesList:
        if (_startDate == null || _endDate == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Seleccione el rango de fechas")),
          );
          return;
        }
        endpoint =
            "${ApiService.baseUrl}/report/sales?format=$formatParam&start_date=${_dateFormatter.format(_startDate!)}&end_date=${_dateFormatter.format(_endDate!)}";
        break;
      case ReportType.purchasesList:
        if (_startDate == null || _endDate == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Seleccione el rango de fechas")),
          );
          return;
        }
        endpoint =
            "${ApiService.baseUrl}/report/purchases?format=$formatParam&start_date=${_dateFormatter.format(_startDate!)}&end_date=${_dateFormatter.format(_endDate!)}";
        break;
    }
    print("Endpoint: $endpoint");
    if (formatParam == 'excel') {
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => PdfViewerScreen(url: endpoint, title: "Reporte PDF"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reportes", style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Seleccionar tipo de reporte
            const Text(
              "Tipo de Reporte",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            DropdownButton<ReportType>(
              value: _selectedReportType,
              isExpanded: true,
              items: [
                DropdownMenuItem(
                  value: ReportType.productCatalog,
                  child: const Text("Catálogo de Productos"),
                ),
                DropdownMenuItem(
                  value: ReportType.salesList,
                  child: const Text("Listado de Ventas"),
                ),
                DropdownMenuItem(
                  value: ReportType.purchasesList,
                  child: const Text("Listado de Compras"),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedReportType = value;
                  });
                }
              },
            ),
            const SizedBox(height: 20),

            if (_selectedReportType == ReportType.salesList ||
                _selectedReportType == ReportType.purchasesList)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Rango de Fechas",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectStartDate(context),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: "Fecha Inicio",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 16,
                              ),
                            ),
                            child: Text(
                              _startDate == null
                                  ? "Seleccionar fecha"
                                  : _dateFormatter.format(_startDate!),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectEndDate(context),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: "Fecha Fin",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 16,
                              ),
                            ),
                            child: Text(
                              _endDate == null
                                  ? "Seleccionar fecha"
                                  : _dateFormatter.format(_endDate!),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            const SizedBox(height: 20),
            // Seleccionar formato de archivo
            const Text(
              "Formato",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<FileFormat>(
                    value: FileFormat.excel,
                    groupValue: _selectedFormat,
                    title: const Text("Excel"),
                    onChanged: (value) {
                      setState(() {
                        _selectedFormat = value!;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<FileFormat>(
                    value: FileFormat.pdf,
                    groupValue: _selectedFormat,
                    title: const Text("PDF"),
                    onChanged: (value) {
                      setState(() {
                        _selectedFormat = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            // Botón para exportar
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _exportReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Generar Reporte",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
