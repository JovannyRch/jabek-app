import 'package:flutter/material.dart';
import 'package:jebek_app/services/share_preferences.dart';
import 'package:jebek_app/utils/const.dart';
import 'package:jebek_app/utils/utils.dart';

class JebekDrawer extends StatefulWidget {
  @override
  State<JebekDrawer> createState() => _JebekDrawerState();
}

class _JebekDrawerState extends State<JebekDrawer> {
  //email
  String _email = '';

  @override
  void initState() {
    //get data
    getData();
    super.initState();
  }

  void getData() async {
    String email = await Preferences.getEmail() ?? '';

    setState(() {
      _email = email;
    });
  }

  void _logout(BuildContext context) async {
    await Preferences.logout();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return AppDrawer(
      email: _email,
      isPro: IS_PRO_VERSION,
      onUpgrade: () async {
        await showProVersionDialog(context);
      },
      onLogout: () {
        _logout(context);
      },
    );
  }
}

class AppDrawer extends StatelessWidget {
  final String email;
  final bool isPro;
  final VoidCallback onUpgrade;
  final VoidCallback onLogout;

  const AppDrawer({
    Key? key,
    required this.email,
    this.isPro = false,
    required this.onUpgrade,
    required this.onLogout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

    Widget buildTile(IconData icon, String title, String routeName) {
      return ListTile(
        leading: Icon(icon, color: primary),
        title: Text(title),
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, routeName);
        },
        hoverColor: primary.withOpacity(0.1),
      );
    }

    return Drawer(
      child: Column(
        children: [
          // -- HEADER --
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primary, primary.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            accountName: Text(
              APP_NAME,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(email),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                email.isNotEmpty ? email[0].toUpperCase() : '',
                style: TextStyle(fontSize: 24, color: primary),
              ),
            ),
            otherAccountsPictures:
                isPro
                    ? [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'PRO',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ]
                    : null,
          ),

          // -- ITEMS --
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                buildTile(Icons.home, 'Inicio', '/home'),
                buildTile(Icons.list_alt, 'Productos', '/product_list'),
                buildTile(Icons.point_of_sale, 'Ventas', '/sales'),
                buildTile(Icons.inventory, 'Compras', '/purchases'),
                buildTile(Icons.analytics, 'Reportes', '/reports'),
              ],
            ),
          ),

          const Divider(height: 1),

          // -- SECTION: UPGRADE or LOGOUT --
          if (!isPro)
            ListTile(
              leading: Icon(Icons.diamond, color: Colors.amber),
              title: const Text('Actualizar a Pro'),
              onTap: () {
                Navigator.pop(context);
                onUpgrade();
              },
              tileColor: Colors.amber.withOpacity(0.1),
            ),

          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.redAccent),
            title: const Text('Cerrar Sesión'),
            onTap: () {
              Navigator.pop(context);
              onLogout();
            },
            hoverColor: Colors.redAccent,
          ),
        ],
      ),
    );
  }
}
