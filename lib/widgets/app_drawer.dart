import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String tipoUsuario = "";
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    carregarUsuario();
  }

  Future<void> carregarUsuario() async {
    final tipo = await ApiService.getUserType();

    setState(() {
      tipoUsuario = (tipo ?? "").trim();
      carregando = false;
    });

    print("🧠 DRAWER USER TYPE: [$tipoUsuario]");
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: carregando
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.zero,
              children: [
                const DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                  ),
                  child: Text(
                    "BSM Serviços",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),

                /// 🏠 HOME
                ListTile(
                  leading: const Icon(Icons.home),
                  title: const Text("Início"),
                  onTap: () {
                    Navigator.pushReplacementNamed(context, "/home");
                  },
                ),

                /// 🔐 PAINEL ADMIN (SÓ ADMIN)
                if (tipoUsuario.toString().contains("admin"))
                  ListTile(
                    leading: const Icon(Icons.dashboard),
                    title: const Text("Painel Admin"),
                    onTap: () {
                      Navigator.pop(context); // fecha drawer
                      Navigator.pushNamed(context, "/admin");
                    },
                  ),

                const Divider(),

                /// 🚪 LOGOUT
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text("Sair"),
                  onTap: () async {
                    await ApiService.logout();

                    print("🚪 LOGOUT REALIZADO");

                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      "/login",
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
    );
  }
}
