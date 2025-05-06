import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jebek_app/components/chart_label.dart';
import 'package:jebek_app/components/time_interval_selector.dart';
import 'package:jebek_app/services/api_service.dart';
import 'package:jebek_app/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:jebek_app/models/settings_model.dart';

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
  late Settings settings;
  final _cardIcons = {
    "Total Ventas": Icons.shopping_cart,
    "Ganancia Total": Icons.attach_money,
    "Cantidad de Ventas": Icons.receipt_long,
    "Venta Promedio": Icons.trending_up,
  };

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

  Widget buildSummaryCard(String title, String value) {
    final icon = _cardIcons[title] ?? Icons.bar_chart;
    return Container(
      width: MediaQuery.of(context).size.width * 0.4,
      height: 140,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Stack(
        children: [
          // Ícono en un círculo semitransparente
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white24,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 24, color: Colors.white),
            ),
          ),
          // Texto en la esquina
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSummaryCards() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        buildSummaryCard(
          "Total Ventas",
          formatCurrency(statsData!["total_sales"]),
        ),
        buildSummaryCard(
          "Ganancia Total",
          formatCurrency(statsData!["total_profit"]),
        ),
        buildSummaryCard(
          "Cantidad de Ventas",
          statsData!["sales_count"].toString(),
        ),
        buildSummaryCard(
          "Venta Promedio",
          formatCurrency(statsData!["average_sale"]),
        ),
      ],
    );
  }

  Widget buildSalesChart() {
    List<dynamic> chartData = statsData!["chart_data"];

    chartData.sort((a, b) => a["date"].compareTo(b["date"]));
    List<FlSpot> spotsSales = [];
    for (int i = 0; i < chartData.length; i++) {
      spotsSales.add(
        FlSpot(i.toDouble(), (chartData[i]["total_sales"] as num).toDouble()),
      );
    }

    List<dynamic> profitChart = statsData!["profit_chart"];
    List<FlSpot> spotsProfit = [];
    profitChart.sort((a, b) => a["date"].compareTo(b["date"]));

    for (int i = 0; i < profitChart.length; i++) {
      spotsProfit.add(
        FlSpot(i.toDouble(), (profitChart[i]["total_sales"] as num).toDouble()),
      );
    }

    // Reutilizable para formatear valores con $
    String _formatValue(double v) => '\$${v.toStringAsFixed(0)}';

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 6,

      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              height: 260,
              child: LineChart(
                LineChartData(
                  // Interacción y tooltip
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      /*   tooltipBgColor: Colors.black87, */
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final isProfit = spot.barIndex == 1;
                          final label = isProfit ? 'Ganancia' : 'Venta';
                          return LineTooltipItem(
                            '$label\n${_formatValue(spot.y)}',
                            const TextStyle(color: Colors.white),
                          );
                        }).toList();
                      },
                    ),
                  ),

                  // Grid horizontal punteado
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine:
                        (_) => FlLine(
                          color: Colors.grey.shade300,
                          strokeWidth: 1,
                          dashArray: [5, 5],
                        ),
                  ),

                  // Quitar bordes
                  borderData: FlBorderData(show: false),

                  // Ejes
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= chartData.length)
                            return const SizedBox();
                          final date = DateTime.parse(chartData[idx]["date"]);
                          return Text(
                            DateFormat('dd/MM').format(date),
                            style: const TextStyle(fontSize: 8),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: false,
                        reservedSize: 50,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            _formatValue(value),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            _formatValue(value),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                  ),

                  // Líneas
                  lineBarsData: [
                    // Ventas
                    LineChartBarData(
                      spots: spotsSales,
                      isCurved: true,
                      barWidth: 3,
                      color: Theme.of(context).primaryColor,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).primaryColor.withOpacity(0.3),
                            Theme.of(context).primaryColor.withOpacity(0.0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                    // Ganancias
                    LineChartBarData(
                      spots: spotsProfit,
                      isCurved: true,
                      barWidth: 3,
                      color: Colors.green,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter:
                            (spot, percent, barData, index) =>
                                FlDotCirclePainter(
                                  radius: 4,
                                  color: Colors.white,
                                  strokeWidth: 2,
                                  strokeColor: Colors.green,
                                ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            Colors.green.withOpacity(0.3),
                            Colors.green.withOpacity(0.0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Leyenda
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChartLabel(
                  label: "Ventas",
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 16),
                ChartLabel(label: "Ganancias", color: Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTopSellingProducts() {
    final List<dynamic> topProducts = statsData!["top_selling_products"];
    if (topProducts.isEmpty) {
      return const SizedBox.shrink();
    }
    // Determinar la cantidad máxima para el progreso
    final int maxQuantity = topProducts
        .map<int>((p) => p["total_quantity"] as int)
        .reduce((a, b) => a > b ? a : b);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,

      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado con ícono
            Row(
              children: const [
                Icon(Icons.star, color: Colors.amber),
                SizedBox(width: 8),
                Text(
                  "Productos más vendidos",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Lista con progreso
            ...topProducts.asMap().entries.map((entry) {
              final idx = entry.key;
              final prod = entry.value;
              final String name = prod["product"]["name"];
              final int quantity = prod["total_quantity"];
              final double fraction = quantity / maxQuantity;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    // Badge de posición
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${idx + 1}',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Icono o inicial del producto
                    CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Text(
                        name.substring(0, 1).toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Nombre + cantidad + barra progreso
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Vendidos: $quantity',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: fraction,
                              minHeight: 6,
                              backgroundColor: Colors.grey[300],
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    settings = Provider.of<Settings>(context);
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
                  if (salePeriod == SalesPeriod.custom) {
                    if (startDate == null || endDate == null) {
                      return;
                    }
                  }

                  setState(() {
                    _selectedPeriod = salePeriod;
                    _customStartDate = startDate;
                    _customEndDate = endDate;
                  });
                  fetchStats();
                },
              ),
              SizedBox(height: 20.0),
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
                        const SizedBox(height: 20),
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
