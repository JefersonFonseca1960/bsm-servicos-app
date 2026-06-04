import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AvaliacoesScreen extends StatefulWidget {
  final int empresaId;
  final bool isAdmin;

  const AvaliacoesScreen({
    super.key,
    required this.empresaId,
    required this.isAdmin,
  });

  @override
  State<AvaliacoesScreen> createState() => _AvaliacoesScreenState();
}

class _AvaliacoesScreenState extends State<AvaliacoesScreen> {
  final String baseUrl = "https://bsm-servicos-backend-1.onrender.com";

  List<Map<String, dynamic>> avaliacoes = [];

  bool carregando = false;

  bool jaAvaliou = false;

  int? usuarioId;

  int notaSelecionada = 5;

  @override
  void initState() {
    super.initState();
    carregarAvaliacoes();
  }

  // =========================
  // CARREGAR AVALIAÇÕES
  // =========================
  Future<void> carregarAvaliacoes() async {
    try {
      setState(() => carregando = true);

      final response = await http.get(Uri.parse("$baseUrl/avaliacoes/"));

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        final List<Map<String, dynamic>> lista = data
            .where((e) => e["empresa_id"] == widget.empresaId)
            .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
            .toList();

        setState(() {
          avaliacoes = lista;
        });
      }
    } catch (e) {
      debugPrint("ERRO: $e");
    } finally {
      setState(() => carregando = false);
    }
  }

  // =========================
  // MÉDIA
  // =========================
  double get media {
    if (avaliacoes.isEmpty) return 0;

    final total = avaliacoes.fold<double>(
      0,
      (sum, item) => sum + double.tryParse(item["nota"].toString())!,
    );

    return total / avaliacoes.length;
  }

  // =========================
  // ESTRELAS
  // =========================
  Widget estrelas(double nota) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < nota ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 18,
        );
      }),
    );
  }

  // =========================
  // UI
  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Avaliações"),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: carregarAvaliacoes,
          ),
        ],
      ),

      body: Column(
        children: [
          // =========================
          // HEADER MÉDIA
          // =========================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Média de avaliações",
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        estrelas(media),
                        const SizedBox(width: 8),
                        Text(
                          media.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Text(
                  "${avaliacoes.length} avaliações",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // =========================
          // LISTA
          // =========================
          Expanded(
            child: carregando
                ? const Center(child: CircularProgressIndicator())
                : avaliacoes.isEmpty
                ? const Center(child: Text("Nenhuma avaliação encontrada"))
                : ListView.builder(
                    itemCount: avaliacoes.length,
                    itemBuilder: (context, index) {
                      final item = avaliacoes[index];

                      final nota =
                          double.tryParse(item["nota"].toString()) ?? 0;

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    item["usuario_nome"] ?? "Usuário",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  estrelas(nota),
                                ],
                              ),

                              const SizedBox(height: 8),

                              Text(item["comentario"] ?? "Sem comentário"),

                              const SizedBox(height: 6),

                              Text(
                                item["data"] ?? "",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
