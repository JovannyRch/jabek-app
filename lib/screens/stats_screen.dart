import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:jebek_app/components/time_interval_selector.dart';
import 'package:jebek_app/services/api_service.dart';
import 'package:jebek_app/utils/utils.dart';

class SalesStatisticsScreen extends StatefulWidget {
  @override
  _SalesStatisticsScreenState createState() => _SalesStatisticsScreenState();
}

class _SalesStatisticsScreenState extends State<SalesStatisticsScreen> {
  bool isLoading = true;
  Map<String, dynamic>? statsData;

  SalesPeriod _selectedPeriod = SalesPeriod.currentMonth;
  DateTime? _customStartDate;
  DateTime? _customEndDate;

  @override
  void initState() {
    super.initState();
    fetchStats();
  }

  Future<void> fetchStats() async {
    setState(() {
      isLoading = true;
    });
    try {
      final ulrParams = {
        "period": _selectedPeriod.name,
        if (_customStartDate != null)
          "start_date": _customStartDate!.toIso8601String(),
        if (_customEndDate != null)
          "end_date": _customEndDate!.toIso8601String(),
      };

      final response = await ApiService.get(
        "/statics/sales",
        queryParameters: ulrParams,
      );
      if (response.statusCode == 200) {
        setState(() {
          statsData = json.decode(response.body);
          isLoading = false;
        });
      } else {
        print("Error fetching stats: ${response.statusCode}");
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching stats: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  /// Crea una tarjeta resumen con un título y valor.
  Widget buildSummaryCard(String title, String value) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 4,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.4,
        height: 110,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Genera las tarjetas resumen usando los datos de estadística.
  Widget buildSummaryCards() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        buildSummaryCard(
          "Total Ventas",
          formatCurrency(statsData!["total_sales"].toString()),
        ),
        buildSummaryCard(
          "Ganancia Total",
          formatCurrency(statsData!["total_profit"].toString()),
        ),
        buildSummaryCard(
          "Número de Ventas",
          statsData!["sales_count"].toString(),
        ),
        buildSummaryCard(
          "Venta Promedio",
          formatCurrency(statsData!["average_sale"].toString()),
        ),
      ],
    );
  }

  /// Construye el gráfico de líneas para la evolución de las ventas.
  Widget buildSalesChart() {
    List<dynamic> chartData = statsData!["chart_data"];
    // Asegurarse de que los datos estén ordenados por fecha ascendente
    chartData.sort((a, b) => a["date"].compareTo(b["date"]));
    List<FlSpot> spots = [];
    for (int i = 0; i < chartData.length; i++) {
      spots.add(
        FlSpot(i.toDouble(), (chartData[i]["total_sales"] as num).toDouble()),
      );
    }
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Container(
        height: 250,
        padding: const EdgeInsets.all(16),
        child: LineChart(
          LineChartData(
            gridData: FlGridData(show: true),
            borderData: FlBorderData(
              show: true,
              border: Border.all(color: Colors.grey.shade300, width: 1),
            ),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 32,
                  getTitlesWidget: (value, meta) {
                    int index = value.toInt();
                    if (index < 0 || index >= chartData.length)
                      return Container();
                    DateTime date = DateTime.parse(chartData[index]["date"]);
                    return Text(
                      "${date.month}/${date.day}",
                      style: const TextStyle(fontSize: 10),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: true, reservedSize: 40),
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                barWidth: 3,
                color: Theme.of(context).primaryColor,
                dotData: FlDotData(show: true),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Lista de productos más vendidos
  Widget buildTopSellingProducts() {
    List<dynamic> topProducts = statsData!["top_selling_products"];
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Productos más vendidos",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: topProducts.length,
              itemBuilder: (context, index) {
                var prod = topProducts[index];
                String name = prod["product"]["name"];
                int quantity = prod["total_quantity"];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(name),
                  trailing: Text(quantity.toString()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Estadísticas de Ventas",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              TimeIntervalSelector(
                period: _selectedPeriod,
                onPeriodChanged: (salePeriod, startDate, endDate) {
                  setState(() {
                    _selectedPeriod = salePeriod;
                    _customStartDate = startDate;
                    _customEndDate = endDate;
                  });
                  fetchStats();
                },
              ),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                    onRefresh: fetchStats,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        buildSummaryCards(),
                        const SizedBox(height: 20),
                        buildSalesChart(),
                        buildTopSellingProducts(),
                      ],
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
