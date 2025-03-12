import 'package:flutter/material.dart';
import 'package:jebek_app/screens/login_screen.dart';

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
        '/login': (context) => LoginScreen(),
        /*   '/register': (context) => RegisterScreen(),
        '/product_list': (context) => ProductListScreen(),
        '/create_product': (context) => CreateProductScreen(), */
      },
    );
  }
}
