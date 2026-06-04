import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AvaliacaoFormScreen extends StatefulWidget {
  final int empresaId;
  final int usuarioId;

  const AvaliacaoFormScreen({
    super.key,
    required this.empresaId,
    required this.usuarioId,
  });

  @override
  State<AvaliacaoFormScreen> createState() => _AvaliacaoFormScreenState();

  int notaSelecionada = 5;
  final comentarioController = TextEditingController();
}

class _AvaliacaoFormScreenState extends State<AvaliacaoFormScreen> {
  final String baseUrl = "https://bsm-servicos-backend-1.onrender.com";

  int nota = 5;
  final TextEditingController comentarioController = TextEditingController();

  bool enviando = false;

  // =========================
  // ENVIAR AVALIAÇÃO
  // =========================
  Future<void> enviarAvaliacao() async {
    if (notaSelecionada < 3 && comentarioController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Avaliações abaixo de 3 estrelas exigem comentário obrigatório.",
          ),
        ),
      );
      return;
    }

    if (nota < 3) {
      final confirmar = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Atenção"),
          content: const Text(
            "Avaliações baixas devem ser responsáveis e baseadas na experiência real.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Continuar"),
            ),
          ],
        ),
      );

      if (confirmar != true) return;
    }

    // 👉 depois disso envia para API
  }

  // =========================
  // UI ESTRELAS
  // =========================
  Widget estrelas() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return IconButton(
          onPressed: () {
            setState(() => nota = index + 1);
          },
          icon: Icon(
            index < nota ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 32,
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nova Avaliação"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Dê sua nota:",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            estrelas(),

            const SizedBox(height: 20),

            TextField(
              controller: comentarioController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: "Comentário",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: enviando ? null : enviarAvaliacao,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.all(14),
              ),
              child: enviando
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      "Enviar Avaliação",
                      style: TextStyle(fontSize: 16),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
