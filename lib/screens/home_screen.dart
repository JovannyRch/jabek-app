import 'package:flutter/material.dart';
import 'package:jebek_app/services/api_service.dart';
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
          _saleTotal = double.parse(response['sales']);
          _profitTotal = double.parse(response['profit']);
          _expenseTotal = double.parse(response['expenses']);
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

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      title: Text('Inicio'),
      actions: [
        IconButton(
          icon: Icon(Icons.person),
          onPressed: () {
            Navigator.pushNamed(context, '/profile');
          },
        ),
      ],
    );

    if (_isLoading) {
      return Scaffold(
        appBar: appBar,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: appBar,
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
                        Text(
                          'Resumen mensual',
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                        SizedBox(height: 10),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildSummaryCard(
                                'Ventas',
                                formatCurrency(_saleTotal),
                                Icons.shopping_cart,
                                Colors.green,
                              ),
                              SizedBox(width: 10),
                              _buildSummaryCard(
                                'Ganancias',
                                formatCurrency(_profitTotal),
                                Icons.attach_money,
                                Colors.blue,
                              ),
                              SizedBox(width: 10),
                              _buildSummaryCard(
                                'Gastos',
                                formatCurrency(_expenseTotal),
                                Icons.inventory,
                                Colors.orange,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),

                        // Acciones Rápidas
                        Text(
                          'Acciones',
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                        SizedBox(height: 10),
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          childAspectRatio: 1.5,
                          children: [
                            _buildActionButton(
                              context,
                              'Registrar Producto',
                              Icons.add_box,
                              '/create_product',
                            ),
                            _buildActionButton(
                              context,
                              'Nueva Venta',
                              Icons.point_of_sale,
                              '/sales',
                            ),
                            _buildActionButton(
                              context,
                              'Registrar Compra',
                              Icons.shopping_bag,
                              '/purchases',
                            ),
                            _buildActionButton(
                              context,
                              'Reportes',
                              Icons.analytics,
                              '/reports',
                            ),
                          ],
                        ),
                        SizedBox(height: 20),

                        // Últimos Movimientos
                        Text(
                          'Últimos Movimientos',
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                        SizedBox(height: 10),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: lastTransactions.length,
                          itemBuilder:
                              (ctx, index) => Card(
                                child: ListTile(
                                  leading: Icon(
                                    lastTransactions[index]['type'] == 'sale'
                                        ? Icons.point_of_sale
                                        : Icons.shopping_bag,
                                    color:
                                        lastTransactions[index]['type'] ==
                                                'sale'
                                            ? Colors.green
                                            : Colors.red[700],
                                  ),
                                  title: Text(
                                    lastTransactions[index]['description'],
                                  ),
                                  subtitle: Text(
                                    lastTransactions[index]['date'],
                                  ),
                                  trailing: Text(
                                    formatCurrency(
                                      lastTransactions[index]['amount'],
                                    ),
                                  ),
                                ),
                              ),
                        ),
                      ],
                    ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(12.0),
        child: Column(
          children: [
            Icon(icon, size: 30, color: color),
            SizedBox(height: 8),
            Text(title, style: TextStyle(fontSize: 12)),
            Text(
              value,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String text,
    IconData icon,
    String route,
  ) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      child: Card(
        elevation: 2,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Theme.of(context).primaryColor),
            SizedBox(height: 8),
            Text(text, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
