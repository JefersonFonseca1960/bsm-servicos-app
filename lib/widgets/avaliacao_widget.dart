import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AvaliacaoWidget extends StatefulWidget {
  final int empresaId;
  final VoidCallback? onAvaliacaoEnviada;

  const AvaliacaoWidget({
    super.key,
    required this.empresaId,
    this.onAvaliacaoEnviada,
  });

  @override
  State<AvaliacaoWidget> createState() => _AvaliacaoWidgetState();
}

class _AvaliacaoWidgetState extends State<AvaliacaoWidget> {
  final comentarioController = TextEditingController();

  int nota = 5;

  bool loading = false;

  final baseUrl = "https://bsm-servicos-backend-1.onrender.com";

  // =========================
  // ENVIAR
  // =========================

  Future<void> enviarAvaliacao() async {
    if (comentarioController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Digite um comentário")));

      return;
    }

    try {
      setState(() {
        loading = true;
      });

      final response = await http.post(
        Uri.parse("$baseUrl/avaliacoes/avaliacoes/"),

        headers: {"Content-Type": "application/json"},

        body: jsonEncode({
          "empresa_id": widget.empresaId,

          // TODO:
          // pegar usuário logado real
          "usuario_id": 1,

          "nota": nota,

          "comentario": comentarioController.text.trim(),
        }),
      );

      debugPrint("⭐ STATUS => ${response.statusCode}");

      debugPrint("⭐ BODY => ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        comentarioController.clear();

        setState(() {
          nota = 5;
        });

        if (widget.onAvaliacaoEnviada != null) {
          widget.onAvaliacaoEnviada!();
        }

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text("Avaliação enviada com sucesso"),
          ),
        );
      } else {
        throw Exception("Erro ao enviar avaliação");
      }
    } catch (e) {
      debugPrint("❌ ERRO => $e");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  // =========================
  // ESTRELA
  // =========================

  Widget buildEstrela(int valor) {
    final selecionada = valor <= nota;

    return GestureDetector(
      onTap: () {
        setState(() {
          nota = valor;
        });
      },

      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),

        child: AnimatedScale(
          duration: const Duration(milliseconds: 150),

          scale: selecionada ? 1.15 : 1,

          child: Icon(
            selecionada ? Icons.star : Icons.star_border,

            color: Colors.amber,

            size: 38,
          ),
        ),
      ),
    );
  }

  // =========================
  // TEXTO NOTA
  // =========================

  String get textoNota {
    switch (nota) {
      case 1:
        return "Muito ruim";

      case 2:
        return "Ruim";

      case 3:
        return "Bom";

      case 4:
        return "Muito bom";

      case 5:
        return "Excelente";

      default:
        return "";
    }
  }

  // =========================
  // UI
  // =========================

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,

      margin: const EdgeInsets.only(top: 18),

      padding: const EdgeInsets.all(22),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(24),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          // =========================
          // TÍTULO
          // =========================
          const Text(
            "Avaliar empresa",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 6),

          Text(
            "Compartilhe sua experiência",
            style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
          ),

          const SizedBox(height: 24),

          // =========================
          // ESTRELAS
          // =========================
          Center(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [
                    buildEstrela(1),
                    buildEstrela(2),
                    buildEstrela(3),
                    buildEstrela(4),
                    buildEstrela(5),
                  ],
                ),

                const SizedBox(height: 10),

                Text(
                  textoNota,

                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // =========================
          // COMENTÁRIO
          // =========================
          TextField(
            controller: comentarioController,

            maxLines: 4,

            decoration: InputDecoration(
              hintText: "Conte como foi sua experiência...",

              filled: true,

              fillColor: Colors.grey.shade100,

              contentPadding: const EdgeInsets.all(18),

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),

                borderSide: BorderSide.none,
              ),

              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),

                borderSide: BorderSide(color: Colors.blue.shade400),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // =========================
          // BOTÃO
          // =========================
          SizedBox(
            width: double.infinity,

            child: ElevatedButton.icon(
              onPressed: loading ? null : enviarAvaliacao,

              icon: loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send),

              label: Text(loading ? "Enviando..." : "Enviar avaliação"),

              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,

                foregroundColor: Colors.white,

                padding: const EdgeInsets.symmetric(vertical: 16),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),

                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
