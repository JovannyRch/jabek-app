import 'package:flutter/material.dart';
import 'package:jebek_app/components/app_logo.dart';
import '../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordConfirmationController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  void _togglePasswordView() {
    setState(() => _obscurePassword = !_obscurePassword);
  }

  void _toggleConfirmView() {
    setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final resp = await ApiService.register(
        emailController.text.trim(),
        passwordController.text,
        passwordConfirmationController.text,
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('¡Usuario registrado con éxito!')));
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primary.withOpacity(0.8), primary.withOpacity(0.4)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo
                        AppLogo(),
                        const SizedBox(height: 16),

                        // Título
                        Text(
                          'Crea tu cuenta',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Regístrate para continuar',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        const SizedBox(height: 24),

                        // Email
                        TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator:
                              (v) =>
                                  v != null && v.contains('@')
                                      ? null
                                      : 'Ingresa un email válido',
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.email),
                            labelText: 'Correo electrónico',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Contraseña
                        TextFormField(
                          controller: passwordController,
                          obscureText: _obscurePassword,
                          validator:
                              (v) =>
                                  v != null && v.length >= 6
                                      ? null
                                      : 'Mínimo 6 caracteres',
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: _togglePasswordView,
                            ),
                            labelText: 'Contraseña',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Confirmar contraseña
                        TextFormField(
                          controller: passwordConfirmationController,
                          obscureText: _obscureConfirmPassword,
                          validator:
                              (v) =>
                                  v == passwordController.text
                                      ? null
                                      : 'Las contraseñas no coinciden',
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: _toggleConfirmView,
                            ),
                            labelText: 'Confirmar Contraseña',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Botón Registrar
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _register,
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                            ),
                            child:
                                _isLoading
                                    ? const CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation(
                                        Colors.white,
                                      ),
                                    )
                                    : const Text(
                                      'Registrarse',
                                      style: TextStyle(fontSize: 16),
                                    ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Divider con texto
                        Row(
                          children: [
                            Expanded(child: Divider()),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Text('O'),
                            ),
                            Expanded(child: Divider()),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Enlace a login
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('¿Ya tienes cuenta? '),
                            TextButton(
                              onPressed:
                                  () => Navigator.pushReplacementNamed(
                                    context,
                                    '/login',
                                  ),
                              child: const Text(
                                'Inicia sesión',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
