import 'package:flutter/material.dart';
import 'package:jebek_app/services/share_preferences.dart';
import 'package:jebek_app/utils/const.dart';

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
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: 150,
            child: DrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    APP_NAME,
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                  Text(
                    _email,
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text("Inicio"),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/home');
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.list_alt),
            title: Text("Productos"),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/product_list');
            },
          ),
          ListTile(
            leading: Icon(Icons.point_of_sale),
            title: Text("Ventas"),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/sales');
            },
          ),
          ListTile(
            leading: Icon(Icons.inventory),
            title: Text("Compras"),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/purchases');
            },
          ),
          ListTile(
            leading: Icon(Icons.analytics),
            title: Text("Reportes"),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/reports');
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text("Cerrar Sesión"),
            onTap: () {
              _logout(context);
            },
          ),
        ],
      ),
    );
  }
}
