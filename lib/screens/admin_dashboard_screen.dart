import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int totalUsuarios = 0;
  int totalEmpresas = 0;
  int totalServicos = 0;

  bool loading = true;

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  Future<void> carregarDados() async {
    try {
      final usuarios = await ApiService.getUsuarios();
      final empresas = await ApiService.getEmpresas();
      final servicos = await ApiService.getServicos();

      setState(() {
        totalUsuarios = usuarios.length;
        totalEmpresas = empresas.length;
        totalServicos = servicos.length;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Painel Admin"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 👋 HEADER
            const Text(
              "Dashboard",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            const Text(
              "Visão geral do sistema",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 20),

            /// 📊 CARDS DE MÉTRICAS
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildCard(
                  title: "Usuários",
                  value: totalUsuarios.toString(),
                  icon: Icons.people,
                  color: Colors.blue,
                ),
                _buildCard(
                  title: "Empresas",
                  value: totalEmpresas.toString(),
                  icon: Icons.business,
                  color: Colors.green,
                ),
                _buildCard(
                  title: "Serviços",
                  value: totalServicos.toString(),
                  icon: Icons.miscellaneous_services,
                  color: Colors.orange,
                ),
              ],
            ),

            const SizedBox(height: 30),

            /// ⚡ AÇÕES RÁPIDAS
            const Text(
              "Ações rápidas",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _buildActionButton(
                  icon: Icons.people,
                  label: "Usuários",
                  onTap: () {
                    Navigator.pushNamed(context, "/users");
                  },
                ),
                _buildActionButton(
                  icon: Icons.business,
                  label: "Empresas",
                  onTap: () {
                    Navigator.pushNamed(context, "/home");
                  },
                ),
                _buildActionButton(
                  icon: Icons.add,
                  label: "Nova Empresa",
                  onTap: () {
                    Navigator.pushNamed(context, "/empresa-form");
                  },
                ),
              ],
            ),

            const SizedBox(height: 30),

            /// 📈 GRÁFICO (PLACEHOLDER PRONTO)
            const Text(
              "Atividade recente",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.grey[200],
              ),
              child: const Center(
                child: Text("Gráfico em breve 📊"),
              ),
            ),

            const SizedBox(height: 30),

            /// 🚪 LOGOUT
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    "/login",
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.logout),
                label: const Text("Sair"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔥 CARD MÉTRICA
  Widget _buildCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: color.withOpacity(0.1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(title),
        ],
      ),
    );
  }

  /// ⚡ BOTÃO AÇÃO
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.blue.withOpacity(0.1),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.blue),
            const SizedBox(height: 8),
            Text(label),
          ],
        ),
      ),
    );
  }
}
