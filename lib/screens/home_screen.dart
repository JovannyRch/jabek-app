import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jebek_app/components/chart_label.dart';
import 'package:jebek_app/components/drawer.dart';
import 'package:jebek_app/components/pro_icon.dart';
import 'package:jebek_app/models/expense.dart';
import 'package:jebek_app/models/sale.dart';
import 'package:jebek_app/screens/purchase/purchase_detail_screen.dart';
import 'package:jebek_app/screens/sales/sale_detail_screen.dart';
import 'package:jebek_app/services/api_service.dart';
import 'package:jebek_app/utils/const.dart';
import 'package:jebek_app/utils/utils.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = false;
  double _saleTotal = 0.0;
  double _profitTotal = 0.0;
  double _expenseTotal = 0.0;
  Map<String, dynamic>? _statsData;

  List<dynamic> lastTransactions = [];

  @override
  void initState() {
    super.initState();
    _fetchReport();
  }

  Future<void> _fetchReport() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService.getReport();
      if (response != null) {
        setState(() {
          lastTransactions = response['last_transactions'];
          _saleTotal = double.parse(response['sales'].toString());
          _profitTotal = double.parse(response['profit'].toString());
          _expenseTotal = double.parse(response['expenses'].toString());
          _statsData = {
            'sales_chart': response['sales_chart'],
            'sales_chart_shadow': response['sales_chart_shadow'],
            'profit_chart': response['profit_chart'],
            'profit_chart_shadow': response['profit_chart_shadow'],
          };
        });
      } else {
        print('No se encontraron datos para mostrar.');
      }
    } catch (e) {
      print('Error al cargar el informe: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<FlSpot> getSpots(String dataKey, String key) {
    if (_statsData == null || !_statsData!.containsKey(dataKey)) {
      return [];
    }
    List<dynamic> chartData = _statsData![dataKey];
    List<FlSpot> spots = [];
    for (int i = 0; i < chartData.length; i++) {
      spots.add(FlSpot(i.toDouble(), (chartData[i][key] as num).toDouble()));
    }
    return spots;
  }

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      title: Text('Inicio'),
      actions: [
        if (!IS_PRO_VERSION)
          ProIconButton(
            onPressed: () {
              showProVersionDialog(context);
            },
          ),
      ],
    );

    if (_isLoading) {
      return Scaffold(
        appBar: appBar,
        body: Center(child: CircularProgressIndicator()),
        drawer: JebekDrawer(),
      );
    }

    return Scaffold(
      appBar: appBar,
      drawer: JebekDrawer(),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await _fetchReport();
          },
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child:
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildWeeklySummarySection(),
                        SizedBox(height: 20),
                        buildWeeklyComparisonChart(),
                        SizedBox(height: 20),
                        buildActionsSection(),
                        SizedBox(height: 20),
                        buildLastTransactionsSection(),
                      ],
                    ),
          ),
        ),
      ),
    );
  }

  Widget buildWeeklyComparisonChart() {
    List<dynamic> chartData = _statsData!['sales_chart'];
    List<FlSpot> salesSpots = getSpots('sales_chart', 'total_sales');
    List<FlSpot> profitSpots = getSpots('profit_chart', 'total_profit');
    //shadows
    List<FlSpot> salesShadowSpots = getSpots(
      'sales_chart_shadow',
      'total_sales',
    );
    List<FlSpot> profitShadowSpots = getSpots(
      'profit_chart_shadow',
      'total_profit',
    );
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Título y subtítulo
            Row(
              children: [
                Icon(Icons.bar_chart, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Evolución Semanal',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Comparado con semana pasada',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ),
            const SizedBox(height: 12),

            // Gráfica
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  // interacción tooltip
                  lineTouchData: LineTouchData(
                    handleBuiltInTouches: true,
                    touchTooltipData: LineTouchTooltipData(
                      /*  tooltipBgColor: Colors.black87, */
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final isProfit = spot.barIndex.isOdd;
                          final label = isProfit ? 'Ganancia' : 'Venta';
                          return LineTooltipItem(
                            '$label\n${spot.y.toStringAsFixed(2)}',
                            const TextStyle(color: Colors.white, fontSize: 12),
                          );
                        }).toList();
                      },
                    ),
                  ),

                  // grid horizontal punteado
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine:
                        (value) => FlLine(
                          color: Colors.grey.shade300,
                          strokeWidth: 1,
                          dashArray: [5, 5],
                        ),
                  ),

                  // sin bordes externos
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= chartData.length)
                            return const SizedBox();
                          final label = chartData[idx]['label']; // ej. 'Lunes'
                          return Text(
                            label.substring(0, 3), // abr.: Lun, Mar...
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        interval: null,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '\$${value.toInt()}',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                  ),

                  // las líneas: sombra primero, luego reales
                  lineBarsData: [
                    // Sombras (ventas y ganancias)
                    LineChartBarData(
                      spots: salesShadowSpots,
                      isCurved: true,
                      barWidth: 2,
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                      dotData: FlDotData(show: false),
                    ),
                    LineChartBarData(
                      spots: profitShadowSpots,
                      isCurved: true,
                      barWidth: 2,
                      color: Colors.green.withOpacity(0.3),
                      dotData: FlDotData(show: false),
                    ),

                    // Series reales con degradado bajo la curva
                    LineChartBarData(
                      spots: salesSpots,
                      isCurved: true,
                      barWidth: 3,
                      color: Theme.of(context).primaryColor,
                      dotData: FlDotData(show: true),
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
                    LineChartBarData(
                      spots: profitSpots,
                      isCurved: true,
                      barWidth: 3,
                      color: Colors.green,
                      dotData: FlDotData(show: true),
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

            const SizedBox(height: 16),

            // Leyenda
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChartLabel(
                  label: 'Ventas',
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 24),
                ChartLabel(label: 'Ganancias', color: Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Llama a este método donde quieras la sección de acciones.
  Widget buildActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Acciones', style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: [
            _buildActionButton('Registrar Producto', Icons.add_box, () async {
              final response = await Navigator.pushNamed(
                context,
                '/create_product',
              );
              if (response == true) {
                await _fetchReport();
              }
            }),
            _buildActionButton('Nueva Venta', Icons.point_of_sale, () async {
              final response = await Navigator.pushNamed(
                context,
                '/create-sale',
              );
              if (response == true) {
                await _fetchReport();
              }
            }),
            _buildActionButton(
              'Registrar Compra',
              Icons.shopping_bag,
              () async {
                final response = await Navigator.pushNamed(
                  context,
                  '/create_purchase',
                );
                if (response == true) {
                  await _fetchReport();
                }
              },
            ),
            _buildActionButton(
              'Estadísticas',
              Icons.analytics,
              () => Navigator.pushNamed(context, '/stats'),
            ),
          ],
        ),
      ],
    );
  }

  /// Botón de acción estilizado
  Widget _buildActionButton(String label, IconData icon, VoidCallback onTap) {
    final primary = Theme.of(context).primaryColor;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          onTap();
        },
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [primary.withOpacity(0.15), primary.withOpacity(0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icono en círculo
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primary.withOpacity(0.2),
                ),
                child: Icon(icon, size: 28, color: primary),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Dentro de tu State o StatelessWidget:
  Widget buildLastTransactionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Últimos Movimientos',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 10),
        lastTransactions.isEmpty
            ? SizedBox(
              height: MediaQuery.of(context).size.height * 0.2,
              child: Center(
                child: Text(
                  'No hay movimientos recientes',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            )
            : ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: lastTransactions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (ctx, index) {
                final tx = lastTransactions[index];
                final isSale = tx['type'] == 'sale';
                final icon = isSale ? Icons.point_of_sale : Icons.shopping_bag;
                final iconColor = isSale ? Colors.green : Colors.red.shade700;
                final amount = double.parse((tx['amount'].toString()));
                final date = DateTime.parse(tx['entity']['date'].toString());

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      radius: 24,
                      backgroundColor: iconColor.withOpacity(0.1),
                      child: Icon(icon, color: iconColor, size: 28),
                    ),
                    title: Text(
                      tx['description'],
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      DateFormat('dd/MM/yyyy – HH:mm').format(date),
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    trailing: Chip(
                      label: Text(
                        formatCurrency(amount),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      backgroundColor: iconColor,
                    ),
                    onTap: () {
                      if (isSale) {
                        final sale = Sale.fromJson(tx['entity']);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SaleDetailScreen(sale: sale),
                          ),
                        );
                      } else {
                        final exp = Expense.fromJson(tx['entity']);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ExpenseDetailScreen(expense: exp),
                          ),
                        );
                      }
                    },
                  ),
                );
              },
            ),
      ],
    );
  }

  /// Dentro de tu State o StatelessWidget:
  Widget buildWeeklySummarySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resumen semanal',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              buildWeeklySummaryCard(
                'Ventas',
                formatCurrency(_saleTotal),
                Icons.shopping_cart,
                Colors.green,
              ),
              buildWeeklySummaryCard(
                'Ganancias',
                formatCurrency(_profitTotal),
                Icons.attach_money,
                Colors.blue,
              ),
              buildWeeklySummaryCard(
                'Compras',
                formatCurrency(_expenseTotal),
                Icons.inventory,
                Colors.orange,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Card estilizado para cada métrica
  Widget buildWeeklySummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.3), color.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: color.withOpacity(0.2),
            child: Icon(icon, size: 24, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color.darken(0.2),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color.darken(0.4),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Extensión para oscurecer ligeramente el color
}

extension ColorUtils on Color {
  Color darken([double amount = .1]) {
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}
