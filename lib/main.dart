import 'package:flutter/material.dart';
import 'package:jebek_app/screens/home_screen.dart';
import 'package:jebek_app/screens/login_screen.dart';
import 'package:jebek_app/screens/products/create_product_screen.dart';
import 'package:jebek_app/screens/products/product_list_screen.dart';
import 'package:jebek_app/screens/register_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jebek App',
      initialRoute: '/login',
      debugShowCheckedModeBanner: false,
      routes: {
        '/home': (context) => HomeScreen(),
        '/login': (context) => LoginScreen(),
        '/product_list': (context) => ProductListScreen(),
        '/register': (context) => RegisterScreen(),
        '/create_product': (context) => CreateProductScreen(),
      },
    );
  }
}
