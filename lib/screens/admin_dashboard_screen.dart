import 'package:flutter/material.dart';

import 'package:fl_chart/fl_chart.dart';

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      carregarDados();
    });
  }

  // =========================
  // CARREGAR DADOS
  // =========================

  Future<void> carregarDados() async {
    if (!mounted) return;

    try {
      setState(() {
        loading = true;
      });

      final listaServicos = await ApiService.getServicos();

      if (!mounted) return;

      final listaEmpresas = await ApiService.getEmpresas();

      // =========================
      // DEBUG EMPRESAS
      // =========================

      for (var e in listaEmpresas) {
        debugPrint("EMPRESA => ${e.id} | ${e.nome}");
      }

      final empresa4 = listaEmpresas.where((e) => e.id == 4).toList();

      debugPrint("EMPRESA 4 => ${empresa4.length}");

      if (!mounted) return;

      setState(() {
        totalServicos = listaServicos.length;
        totalEmpresas = listaEmpresas.length;
        totalUsuarios = 0;
        loading = false;
      });
    } catch (e) {
      debugPrint("❌ ERRO carregarDados => $e");

      if (!mounted) return;

      setState(() {
        loading = false;
      });
    }
  }

  // =========================
  // UI
  // =========================

  @override
  Widget build(BuildContext context) {
    final largura = MediaQuery.of(context).size.width;

    // RESPONSIVIDADE
    int colunas = 1;

    if (largura > 1200) {
      colunas = 4;
    } else if (largura > 800) {
      colunas = 2;
    }

    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xffF4F7FB),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blue,
        title: const Text(
          "Painel Admin",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),

      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),

          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                // =========================
                // HEADER
                // =========================
                const Text(
                  "Dashboard",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 6),

                Text(
                  "Visão geral do sistema",
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 15),
                ),

                const SizedBox(height: 26),

                // =========================
                // KPIs
                // =========================
                GridView.count(
                  crossAxisCount: colunas,

                  shrinkWrap: true,

                  physics: const NeverScrollableScrollPhysics(),

                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,

                  childAspectRatio: largura > 800 ? 1.8 : 1.4,

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

                    _buildCard(
                      title: "Ativos",
                      value: totalEmpresas.toString(),
                      icon: Icons.check_circle,
                      color: Colors.purple,
                    ),
                  ],
                ),

                const SizedBox(height: 35),

                // =========================
                // AÇÕES RÁPIDAS
                // =========================
                const Text(
                  "Ações rápidas",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 18),

                Wrap(
                  spacing: 14,
                  runSpacing: 14,

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
                      icon: Icons.add_business,
                      label: "Nova Empresa",
                      onTap: () {
                        Navigator.pushNamed(context, "/empresa-form");
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 35),

                // =========================
                // GRÁFICO
                // =========================
                const Text(
                  "Atividade recente",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 16),

                Container(
                  height: 320,
                  width: double.infinity,

                  padding: const EdgeInsets.all(20),

                  decoration: BoxDecoration(
                    color: Colors.white,

                    borderRadius: BorderRadius.circular(24),

                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),

                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,

                      maxY: 20,

                      borderData: FlBorderData(show: false),

                      gridData: FlGridData(show: true),

                      titlesData: FlTitlesData(
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),

                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),

                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: true),
                        ),

                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,

                            getTitlesWidget: (value, meta) {
                              switch (value.toInt()) {
                                case 0:
                                  return const Text("Usuários");

                                case 1:
                                  return const Text("Empresas");

                                case 2:
                                  return const Text("Serviços");
                              }

                              return const Text("");
                            },
                          ),
                        ),
                      ),

                      barGroups: [
                        BarChartGroupData(
                          x: 0,

                          barRods: [
                            BarChartRodData(
                              toY: totalUsuarios.toDouble(),
                              width: 40,
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.blue,
                            ),
                          ],
                        ),

                        BarChartGroupData(
                          x: 1,

                          barRods: [
                            BarChartRodData(
                              toY: totalEmpresas.toDouble(),
                              width: 40,
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.green,
                            ),
                          ],
                        ),

                        BarChartGroupData(
                          x: 2,

                          barRods: [
                            BarChartRodData(
                              toY: totalServicos.toDouble(),
                              width: 40,
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.orange,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // =========================
                // LOGOUT
                // =========================
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

                      padding: const EdgeInsets.symmetric(vertical: 18),

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =========================
  // CARD KPI
  // =========================

  Widget _buildCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(24),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Row(
        children: [
          // ÍCONE
          Container(
            padding: const EdgeInsets.all(16),

            decoration: BoxDecoration(
              color: color.withOpacity(0.12),

              borderRadius: BorderRadius.circular(18),
            ),

            child: Icon(icon, color: color, size: 32),
          ),

          const SizedBox(width: 18),

          // TEXTO
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              mainAxisAlignment: MainAxisAlignment.center,

              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  value,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // BOTÃO AÇÃO
  // =========================

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,

      borderRadius: BorderRadius.circular(18),

      child: Container(
        width: 150,

        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius: BorderRadius.circular(18),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),

        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),

              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.12),

                borderRadius: BorderRadius.circular(14),
              ),

              child: Icon(icon, color: Colors.blue, size: 28),
            ),

            const SizedBox(height: 12),

            Text(
              label,
              textAlign: TextAlign.center,

              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
