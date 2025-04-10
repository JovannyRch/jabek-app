import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jebek_app/models/product.dart';
import 'package:jebek_app/screens/user/paginated_response.dart';
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

  static Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final token = await Preferences.getToken();
    final response = await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al realizar la solicitud PUT');
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

  static Future<PaginatedResponse<T>> fetchPaginated<T>(
    String endpoint,
    int page,
    T Function(Map<String, dynamic>) fromJsonT, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final token = await Preferences.getToken();

    if (token == null) {
      throw Exception('No se encontró el token de autenticación');
    }

    final response = await http.get(
      Uri.parse(
        "$baseUrl$endpoint?page=$page&${queryParameters?.entries.map((e) => '${e.key}=${e.value}').join('&') ?? ''}",
      ),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return PaginatedResponse<T>.fromJson(
        json.decode(response.body),
        fromJsonT,
      );
    } else {
      throw Exception("Error al cargar los datos: ${response.statusCode}");
    }
  }

  static Future<Map<String, dynamic>> getReport() async {
    final token = await Preferences.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/report'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al crear el producto');
    }
  }

  //create general POST request
  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final token = await Preferences.getToken();
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al realizar la solicitud POST');
    }
  }

  static Future<int> delete(String endpoint) async {
    final token = await Preferences.getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    return response.statusCode;
  }

  static Future<http.Response> get(String endpoint) async {
    final token = await Preferences.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    return response;
  }
}
