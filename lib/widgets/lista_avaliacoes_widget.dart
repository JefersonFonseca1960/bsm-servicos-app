import 'package:flutter/material.dart';

import '../models/avaliacao_model.dart';

class ListaAvaliacoesWidget extends StatelessWidget {
  final List<Avaliacao> avaliacoes;

  const ListaAvaliacoesWidget({super.key, required this.avaliacoes});

  // =========================
  // STARS
  // =========================

  Widget buildStars(int nota) {
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
  // DATA
  // =========================

  String formatarData(dynamic data) {
    if (data == null) {
      return "";
    }

    try {
      final d = DateTime.parse(data.toString());

      return "${d.day.toString().padLeft(2, '0')}/"
          "${d.month.toString().padLeft(2, '0')}/"
          "${d.year}";
    } catch (e) {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    if (avaliacoes.isEmpty) {
      return Container(
        width: double.infinity,

        padding: const EdgeInsets.all(24),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),

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
            Icon(Icons.star_border, size: 60, color: Colors.grey.shade400),

            const SizedBox(height: 16),

            Text(
              "Ainda não existem avaliações",
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        // =========================
        // HEADER
        // =========================
        Text(
          "Avaliações",
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 6),

        Text(
          "${avaliacoes.length} avaliações recebidas",
          style: TextStyle(color: Colors.grey.shade600),
        ),

        const SizedBox(height: 20),

        // =========================
        // LISTA
        // =========================
        ...avaliacoes.map((avaliacao) {
          return Container(
            width: double.infinity,

            margin: const EdgeInsets.only(bottom: 16),

            padding: const EdgeInsets.all(18),

            decoration: BoxDecoration(
              color: Colors.white,

              borderRadius: BorderRadius.circular(22),

              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                // =========================
                // TOPO
                // =========================
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,

                      backgroundColor: Colors.blue.shade100,

                      child: Icon(Icons.person, color: Colors.blue.shade700),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            avaliacao.usuarioNome ?? "Usuário",

                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),

                          const SizedBox(height: 4),

                          buildStars(avaliacao.nota ?? 0),
                        ],
                      ),
                    ),

                    Text(
                      formatarData(avaliacao.dataCriacao),

                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // =========================
                // COMENTÁRIO
                // =========================
                Text(
                  avaliacao.comentario ?? "Sem comentário",

                  style: TextStyle(
                    color: Colors.grey.shade800,
                    height: 1.5,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
