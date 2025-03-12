import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RegisterScreen extends StatelessWidget {
  /*   final TextEditingController nameController = TextEditingController(); */
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordConfirmationController =
      TextEditingController();

  void _register(BuildContext context) async {
    try {
      if (emailController.text.isEmpty ||
          passwordController.text.isEmpty ||
          passwordConfirmationController.text.isEmpty) {
        throw Exception('Todos los campos son requeridos');
      }

      if (passwordController.text != passwordConfirmationController.text) {
        throw Exception('Las contraseñas no coinciden');
      }

      final response = await ApiService.register(
        emailController.text,
        passwordController.text,
        passwordConfirmationController.text,
      );

      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Usuario registrado: ${response['user']['name']}'),
        ),
      );

      // Navegar a la pantalla de inicio de sesión
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      // Mostrar mensaje de error
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registro')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 16.0),
              /*   TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                ),
              ), */
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: passwordConfirmationController,
                decoration: InputDecoration(
                  labelText: 'Confirmar Contraseña',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: () => _register(context),
                child: Text('Registrarse'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50), // Botón ancho
                ),
              ),
              SizedBox(height: 16.0),
              TextButton(
                onPressed:
                    () => Navigator.pushReplacementNamed(context, '/login'),
                child: Text('¿Ya tienes una cuenta? Inicia sesión'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
