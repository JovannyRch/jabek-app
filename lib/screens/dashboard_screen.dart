import 'package:flutter/material.dart';
import 'package:jebek_app/components/text.dart';
import 'package:jebek_app/services/api_service.dart';
import 'package:jebek_app/utils/utils.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = false;
  Map<String, dynamic> _data = {};

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    setState(() => _isLoading = true);

    try {
      final response = await ApiService.getReport();
      setState(() => _data = response);
    } catch (error) {
      print("Error al cargar datos: $error");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inicio', style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      backgroundColor: Color(0xFFFAFBFD),
      body: SafeArea(
        child:
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                  onRefresh: _fetchDashboardData, // 🔄 Pull to Refresh
                  child: SingleChildScrollView(
                    physics:
                        AlwaysScrollableScrollPhysics(), // Requerido para RefreshIndicator
                    child: _buildDashboardContent(),
                  ),
                ),
      ),
    );
  }

  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Card(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'Resumen',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildCard(
                        'Ventas',
                        formatCurrency((_data['sales'].toString())),
                      ),
                      _buildCard(
                        'Compras',
                        formatCurrency(_data['expenses'].toString()),
                        color: Colors.blue,
                      ),
                      _buildCard(
                        'Ganancias',
                        formatCurrency(_data['profit'].toString()),
                        color: Colors.green,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(String title, String value, {Color? color}) {
    return Column(
      children: [
        SubtitleNormal(text: title, color: Color(0xFF9B9EA2)),
        SizedBox(height: 10),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color ?? Colors.black,
          ),
        ),
      ],
    );
  }
}
