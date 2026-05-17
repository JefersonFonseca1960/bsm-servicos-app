import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Painel Administrativo"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ApiService.logout();

              if (!context.mounted) return;

              Navigator.pushReplacementNamed(context, "/login");
            },
          )
        ],
      ),
      body: const Center(
        child: Text(
          "Bem-vindo, ADMIN 👑",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
