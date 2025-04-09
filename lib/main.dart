import 'package:flutter/material.dart';
import 'package:jebek_app/screens/dashboard_screen.dart';
import 'package:jebek_app/screens/home_screen.dart';
import 'package:jebek_app/screens/login_screen.dart';
import 'package:jebek_app/screens/more_screen.dart';
import 'package:jebek_app/screens/products/create_product_screen.dart';
import 'package:jebek_app/screens/products/product_list_screen.dart';
import 'package:jebek_app/screens/purchase/purchase_form_screen.dart';
import 'package:jebek_app/screens/purchase/purchase_screen.dart';
import 'package:jebek_app/screens/register_screen.dart';
import 'package:jebek_app/screens/sales/sale_form_screen.dart';
import 'package:jebek_app/screens/sales/sales_screen.dart';
import 'package:jebek_app/screens/user/profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jebek App',

      debugShowCheckedModeBanner: false,
      home: FutureBuilder(
        future: SharedPreferences.getInstance(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(body: Center(child: CircularProgressIndicator()));
          } else if (snapshot.hasError) {
            return Scaffold(
              body: Center(child: Text('Error al cargar la aplicación')),
            );
          } else {
            final prefs = snapshot.data as SharedPreferences;
            final token = prefs.getString('access_token');

            return token == null ? LoginScreen() : HomeScreen();
          }
        },
      ),
      routes: {
        '/home': (context) => HomeScreen(),
        '/login': (context) => LoginScreen(),
        '/product_list': (context) => ProductListScreen(),
        '/register': (context) => RegisterScreen(),
        '/create_product': (context) => CreateProductScreen(),
        '/sales': (context) => SalesScreen(),
        '/create-sale': (context) => SaleFormScreen(),
        '/purchases': (context) => PurchaseScreen(),
        '/create_purchase': (context) => PurchaseFormScreen(),
        '/profile': (context) => MoreScreen(),
        '/dashboard': (context) => DashboardScreen(),
      },
    );
  }
}
