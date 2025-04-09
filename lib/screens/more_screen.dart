import 'package:flutter/material.dart';
import 'package:jebek_app/components/text.dart';
import 'package:jebek_app/screens/dashboard_screen.dart';
import 'package:jebek_app/screens/home_screen.dart';
import 'package:jebek_app/screens/user/profile_screen.dart';
import 'package:jebek_app/services/share_preferences.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Column(children: [_header(context), _list(context)]));
  }

  void _logout(BuildContext context) async {
    await Preferences.logout();
    Navigator.pushReplacementNamed(context, '/login');
  }

  Widget _header(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: ThemeData().primaryColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            const CircleAvatar(radius: 30, child: Icon(Icons.person, size: 30)),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TitleBold(text: 'Username'),
                GestureDetector(
                  onTap:
                      () => {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfileScreen(),
                          ),
                        ),
                      },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      BodyTextNormal(text: 'Tu perfil'),
                      Icon(Icons.chevron_right, color: Colors.white, size: 16),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _list(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.home, color: Colors.black54),
            title: const SubtitleNormal(text: 'Inicio', color: Colors.black54),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>  HomeScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings, color: Colors.black54),
            title: const SubtitleNormal(
              text: 'Configuración',
              color: Colors.black54,
            ),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.help, color: Colors.black54),
            title: const SubtitleNormal(text: 'Ayuda', color: Colors.black54),
            onTap: () {},
          ),
          Divider(color: Colors.black12, height: 1),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.black54),
            title: const SubtitleNormal(
              text: 'Cerrar sesión',
              color: Colors.black54,
            ),
            onTap: () {
              _logout(context);
            },
          ),
          Divider(color: Colors.black12, height: 1),
        ],
      ),
    );
  }
}
