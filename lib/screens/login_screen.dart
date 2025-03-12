import 'package:flutter/material.dart';
import 'package:jebek_app/components/app_logo.dart';
import 'package:jebek_app/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController(
    /* text: 'user2@example.com', */
  );
  final TextEditingController passwordController = TextEditingController(
    /*   text: 'password', */
  );

  // Método para iniciar sesión
  void _login(BuildContext context) async {
    try {
      final response = await ApiService.login(
        emailController.text,
        passwordController.text,
      );

      // Guardar el token en SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', response['access_token']);

      // Navegar a la pantalla de lista de productos
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      // Mostrar un mensaje de error si falla el inicio de sesión
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*       appBar: AppBar(title: Text('Iniciar Sesión')), */
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Campo de email
                SizedBox(height: 16.0),
                AppLogo(),
                Text(
                  'Iniciar Sesión',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: ThemeData().primaryColor,
                  ),
                ),
                SizedBox(height: 8.0),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 16.0),

                // Campo de contraseña
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true, // Oculta el texto de la contraseña
                ),
                SizedBox(height: 24.0),

                // Botón de inicio de sesión
                ElevatedButton(
                  onPressed: () => _login(context),
                  child: Text('Iniciar Sesión'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50), // Botón ancho
                  ),
                ),
                SizedBox(height: 16.0),

                // Enlace a la pantalla de registro
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/register'),
                  child: Text('¿No tienes una cuenta? Regístrate'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
