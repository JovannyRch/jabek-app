import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jebek_app/components/time_interval_selector.dart';
import 'package:jebek_app/services/api_service.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:jebek_app/services/share_preferences.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

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

  SalesPeriod _selectedPeriod = SalesPeriod.currentMonth;
  final DateFormat _dateFormatter = DateFormat('yyyy-MM-dd');

  /*   Future<void> _selectStartDate(BuildContext context) async {
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
  } */

  Future<void> _exportReport() async {
    String endpoint = '';
    String formatParam = _selectedFormat == FileFormat.excel ? 'excel' : 'pdf';

    switch (_selectedReportType) {
      case ReportType.productCatalog:
        endpoint = "${ApiService.baseUrl}/report/products?format=$formatParam";
        break;
      case ReportType.salesList:
        if (_startDate != null && _endDate != null) {
          endpoint =
              "${ApiService.baseUrl}/report/sales?format=$formatParam&start_date=${_dateFormatter.format(_startDate!)}&end_date=${_dateFormatter.format(_endDate!)}";
        } else {
          endpoint = "${ApiService.baseUrl}/report/sales?format=$formatParam";
        }
        break;
      case ReportType.purchasesList:
        if (_startDate != null && _endDate != null) {
          endpoint =
              "${ApiService.baseUrl}/report/expenses?format=$formatParam&start_date=${_dateFormatter.format(_startDate!)}&end_date=${_dateFormatter.format(_endDate!)}";
        } else {
          endpoint =
              "${ApiService.baseUrl}/report/expenses?format=$formatParam";
        }
        break;
    }
    await _downloadFile(
      endpoint,
      extension: formatParam == 'excel' ? 'xlsx' : 'pdf',
    );
  }

  Future<void> _downloadFile(String url, {required String extension}) async {
    // 1. Obtener directorio privado de la app
    Directory dir = await getApplicationDocumentsDirectory();
    // (Si prefieres el externo específico de tu app en Android,
    // usa getExternalStorageDirectory() en su lugar, también sin permiso.)

    // 2. Construir la ruta con timestamp
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final filePath = '${dir.path}/reporte_$timestamp.$extension';

    // 3. Descargar con Dio
    try {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Descargando reporte...")));
      final token = await Preferences.getToken();

      await Dio().download(
        url,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
        filePath,
        onReceiveProgress: (rec, total) {},
      );

      await showFileOptionsDialog(context, filePath);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error al descargar: $e")));
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

            if (_selectedReportType == ReportType.salesList ||
                _selectedReportType == ReportType.purchasesList)
              TimeIntervalSelector(
                period: _selectedPeriod,
                onPeriodChanged: (salePeriod, startDate, endDate) {
                  if (salePeriod == SalesPeriod.allTime) {
                    startDate = null;
                    endDate = null;
                  }

                  switch (salePeriod) {
                    case SalesPeriod.allTime:
                      startDate = null;
                      endDate = null;
                      break;
                    case SalesPeriod.currentMonth:
                      startDate = DateTime(
                        DateTime.now().year,
                        DateTime.now().month,
                        1,
                      );
                      endDate = DateTime(
                        DateTime.now().year,
                        DateTime.now().month + 1,
                        0,
                      );
                      break;
                    case SalesPeriod.thisYear:
                      startDate = DateTime(DateTime.now().year, 1, 1);
                      endDate = DateTime(DateTime.now().year + 1, 1, 0);
                      break;
                    case SalesPeriod.lastWeek:
                      startDate = DateTime.now().subtract(
                        const Duration(days: 7),
                      );
                      endDate = DateTime.now();
                      break;
                    case SalesPeriod.lastYear:
                      startDate = DateTime(DateTime.now().year - 1, 1, 1);
                      endDate = DateTime(DateTime.now().year, 1, 0);
                      break;
                    case SalesPeriod.previousMonth:
                      startDate = DateTime(
                        DateTime.now().year,
                        DateTime.now().month - 1,
                        1,
                      );
                      endDate = DateTime(
                        DateTime.now().year,
                        DateTime.now().month,
                        0,
                      );
                      break;
                    case SalesPeriod.thisWeek:
                      startDate = DateTime.now().subtract(
                        Duration(days: DateTime.now().weekday - 1),
                      );
                      endDate = DateTime.now().add(
                        Duration(days: 7 - DateTime.now().weekday),
                      );
                      break;

                    default:
                  }

                  setState(() {
                    _selectedPeriod = salePeriod;
                    _startDate = startDate;
                    _endDate = endDate;
                  });
                },
              ),
            /*  SizedBox(height: 20.0),
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
              ), */
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

  Future<void> showFileOptionsDialog(BuildContext context, String filePath) {
    final fileName = filePath.split('/').last;
    return showDialog<void>(
      context: context,
      builder:
          (_) => SimpleDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: Row(
              children: [
                const Icon(Icons.insert_drive_file, color: Colors.blueAccent),
                const SizedBox(width: 8),
                const Text('Opciones de archivo'),
              ],
            ),
            children: [
              ListTile(
                leading: const Icon(Icons.open_in_new, color: Colors.green),
                title: const Text('Abrir archivo'),
                subtitle: Text(fileName, style: const TextStyle(fontSize: 12)),
                onTap: () {
                  Navigator.of(context).pop();
                  OpenFile.open(filePath);
                },
              ),
              ListTile(
                leading: const Icon(Icons.share, color: Colors.blue),
                title: const Text('Compartir archivo'),
                subtitle: Text(fileName, style: const TextStyle(fontSize: 12)),
                onTap: () {
                  Navigator.of(context).pop();
                  Share.shareXFiles([
                    XFile(filePath),
                  ], text: 'Te comparto este archivo.');
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.cancel, color: Colors.redAccent),
                title: const Text('Cancelar'),
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
    );
  }
}
