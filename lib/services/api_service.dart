import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jebek_app/models/product.dart';
import 'package:jebek_app/services/share_preferences.dart';

class ApiService {
  static const String baseUrl = 'https://jebek-fc1af0e483ef.herokuapp.com/api';

  // Método para registrar un usuario
  static Future<Map<String, dynamic>> register(
    String email,
    String password,
    String passwordConfirmation,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al registrar el usuario');
    }
  }

  // Método para iniciar sesión
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al iniciar sesión');
    }
  }

  // Método para obtener la lista de productos
  static Future<List<Product>> getProducts() async {
    final token = await Preferences.getToken();

    if (token == null) {
      throw Exception('No se encontró el token de autenticación');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/products'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)
          .map<Product>((product) => Product.fromJson(product))
          .toList()
          .cast<Product>();
    } else {
      throw Exception('Error al obtener los productos');
    }
  }

  // Método para crear un producto
  static Future<Map<String, dynamic>> createProduct(
    String name,
    double price,
    int stock,
  ) async {
    final token = await Preferences.getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/products'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'name': name, 'price': price, 'stock': stock}),
    );

    print(response.body);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al crear el producto');
    }
  }
}
