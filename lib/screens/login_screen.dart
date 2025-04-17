import 'package:flutter/material.dart';
import 'package:jebek_app/components/app_logo.dart';
import 'package:jebek_app/services/api_service.dart';
import 'package:jebek_app/services/share_preferences.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _obscurePassword = true;

  void _togglePasswordView() {
    setState(() => _obscurePassword = !_obscurePassword);
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      try {
        final response = await ApiService.login(
          emailController.text,
          passwordController.text,
        );

        if (response['access_token'] == null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error al iniciar sesión')));
          throw Exception('Error al iniciar sesión');
        }

        await Preferences.saveLogin(
          response['access_token'],
          emailController.text,
        );

        Navigator.pushReplacementNamed(context, '/home');
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
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
                          'Bienvenido',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Inicia sesión para continuar',
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
                                      : 'Correo inválido',
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
                        const SizedBox(height: 8),

                        // Olvidaste contraseña
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              // Navegar a "Recuperar contraseña"
                            },
                            child: const Text('¿Olvidaste tu contraseña?'),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Botón Iniciar Sesión
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _login,
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                            ),
                            child: const Text(
                              'Iniciar Sesión',
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
                        /*  const SizedBox(height: 16),

                        // Botones sociales (opcional)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _SocialButton(
                              icon: Icons.g_mobiledata,
                              label: 'Google',
                              color: Colors.redAccent,
                              onTap: () {
                                // Login con Google
                              },
                            ),
                            const SizedBox(width: 16),
                            _SocialButton(
                              icon: Icons.facebook,
                              label: 'Facebook',
                              color: Colors.blue,
                              onTap: () {
                                // Login con Facebook
                              },
                            ),
                          ],
                        ), */
                        const SizedBox(height: 24),

                        // Registro
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("¿No tienes cuenta? "),
                            TextButton(
                              onPressed:
                                  () =>
                                      Navigator.pushNamed(context, '/register'),
                              child: const Text(
                                'Regístrate',
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

/// Botón cuadrado para login social
class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _SocialButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Ink(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(color: color)),
            ],
          ),
        ),
      ),
    );
  }
}
