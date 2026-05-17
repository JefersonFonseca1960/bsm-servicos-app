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

  final baseUrl = "https://bsm-servicos-backend.onrender.com";

  Future<void> enviarAvaliacao() async {
    try {
      setState(() {
        loading = true;
      });

      final response = await http.post(
        Uri.parse(
          "$baseUrl/avaliacoes/avaliacoes/",
        ),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "empresa_id": widget.empresaId,
          "usuario_id": 1,
          "nota": nota,
          "comentario": comentarioController.text,
        }),
      );

      debugPrint(
        "⭐ AVALIACAO STATUS => ${response.statusCode}",
      );

      debugPrint(
        "⭐ AVALIACAO BODY => ${response.body}",
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        comentarioController.clear();

        if (widget.onAvaliacaoEnviada != null) {
          widget.onAvaliacaoEnviada!();
        }

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Avaliação enviada",
            ),
          ),
        );
      } else {
        throw Exception(
          "Erro ao enviar avaliação",
        );
      }
    } catch (e) {
      debugPrint(
        "❌ AVALIACAO => $e",
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  Widget buildEstrela(int valor) {
    return IconButton(
      onPressed: () {
        setState(() {
          nota = valor;
        });
      },
      icon: Icon(
        valor <= nota ? Icons.star : Icons.star_border,
        color: Colors.amber,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(
        top: 10,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Avaliar empresa",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                buildEstrela(1),
                buildEstrela(2),
                buildEstrela(3),
                buildEstrela(4),
                buildEstrela(5),
              ],
            ),
            TextField(
              controller: comentarioController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: "Digite seu comentário",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : enviarAvaliacao,
                child: Text(
                  loading ? "Enviando..." : "Enviar Avaliação",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
