import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jebek_app/screens/dashboard_screen.dart';
import 'package:jebek_app/screens/login_screen.dart';
import 'package:jebek_app/screens/more_screen.dart';
import 'package:jebek_app/screens/products/create_product_screen.dart';
import 'package:jebek_app/screens/products/product_list_screen.dart';
import 'package:jebek_app/screens/purchases_screen.dart';
import 'package:jebek_app/screens/sales_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _buildScreens()),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
            backgroundColor: Theme.of(context).primaryColor,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Productos',
            backgroundColor: Theme.of(context).primaryColor,
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.money_dollar),
            label: 'Ventas',
            backgroundColor: Theme.of(context).primaryColor,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Compras',
            backgroundColor: Theme.of(context).primaryColor,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz),
            label: 'Más',
            backgroundColor: Theme.of(context).primaryColor,
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        onTap: _onItemTapped,
      ),
    );
  }

  List<Widget> _buildScreens() {
    return [
      DashboardScreen(),
      ProductListScreen(),
      SalesScreen(),
      PurchasesScreen(),
      MoreScreen(),
    ];
  }
}
