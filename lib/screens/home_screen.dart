import 'package:flutter/material.dart';
import 'package:jebek_app/services/api_service.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inicio'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await ApiService.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildMenuCard(
              context,
              title: 'Productos',
              icon: Icons.list,
              onTap: () => Navigator.pushNamed(context, '/product_list'),
            ),
            _buildMenuCard(
              context,
              title: 'Registrar Producto',
              icon: Icons.inventory,
              onTap: () => Navigator.pushNamed(context, '/create_product'),
            ),
            SizedBox(height: 16.0),
            // Tarjeta para registrar ventas
            _buildMenuCard(
              context,
              title: 'Registrar Venta',
              icon: Icons.shopping_cart,
              onTap: () => Navigator.pushNamed(context, '/sales'),
            ),
            SizedBox(height: 16.0),
            // Tarjeta para registrar compras
            _buildMenuCard(
              context,
              title: 'Registrar Compra',
              icon: Icons.shopping_bag,
              onTap: () => Navigator.pushNamed(context, '/purchases'),
            ),
          ],
        ),
      ),
    );
  }

  // Método para construir una tarjeta de menú
  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4.0,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 40.0, color: Theme.of(context).primaryColor),
              SizedBox(width: 16.0),
              Text(
                title,
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
