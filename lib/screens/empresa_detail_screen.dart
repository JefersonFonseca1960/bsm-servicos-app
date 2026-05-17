import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../services/api_service.dart';
import '../models/empresa_model.dart';
import 'empresa_fotos_screen.dart';
import 'dart:async';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class EmpresaDetailScreen extends StatefulWidget {
  final Empresa empresa;
  final bool isAdmin;

  const EmpresaDetailScreen({
    super.key,
    required this.empresa,
    required this.isAdmin,
  });

  @override
  State<EmpresaDetailScreen> createState() => _EmpresaDetailScreenState();
}

class _EmpresaDetailScreenState extends State<EmpresaDetailScreen> {
  // =========================
  // ⭐ AVALIAÇÕES
  // =========================
  List<Map<String, dynamic>> avaliacoes = [];

  int notaSelecionada = 5;

  final comentarioController = TextEditingController();

  bool enviandoAvaliacao = false;

  final String baseUrl = "https://bsm-servicos-backend.onrender.com";

  int? usuarioId;

  @override
  void initState() {
    super.initState();

    carregarUsuario();
    carregarAvaliacoes();
  }

  // =========================
  // 👤 USUÁRIO LOGADO
  // =========================
  Future<void> carregarUsuario() async {
    try {
      final token = await ApiService.getToken();

      if (token == null) return;

      final payload = token.split('.')[1];

      final normalized = base64Url.normalize(payload);

      final decoded = utf8.decode(base64Url.decode(normalized));

      final data = jsonDecode(decoded);

      setState(() {
        usuarioId = int.tryParse(data["sub"].toString());
      });

      debugPrint("👤 USUÁRIO LOGADO => $usuarioId");
    } catch (e) {
      debugPrint("❌ ERRO USUÁRIO => $e");
    }
  }

  // =========================
  // 🚫 JÁ AVALIOU?
  // =========================
  bool usuarioJaAvaliou() {
    if (usuarioId == null) return false;

    return avaliacoes.any((a) => a["usuario_id"] == usuarioId);
  }

  // =========================
  // 📞 AÇÕES
  // =========================
  Future<void> _ligar(String? telefone) async {
    if (telefone == null || telefone.isEmpty) {
      return;
    }

    final uri = Uri.parse("tel:$telefone");

    await launchUrl(uri);
  }

  Future<void> _whatsapp(String? telefone) async {
    if (telefone == null || telefone.isEmpty) {
      return;
    }

    final numero = telefone.replaceAll(RegExp(r'[^0-9]'), '');

    final uri = Uri.parse("https://wa.me/55$numero");

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _email(String? email) async {
    if (email == null || email.isEmpty) {
      return;
    }

    final uri = Uri.parse("mailto:$email");

    await launchUrl(uri);
  }

  Future<void> _mapa() async {
    if (widget.empresa.latitude == null || widget.empresa.longitude == null) {
      return;
    }

    final uri = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=${widget.empresa.latitude},${widget.empresa.longitude}",
    );

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  // =========================
  // ⭐ CARREGAR AVALIAÇÕES
  // =========================
  Future<void> carregarAvaliacoes() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/avaliacoes/avaliacoes/"),
      );

      debugPrint("⭐ STATUS AVALIAÇÕES: ${response.statusCode}");

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        setState(() {
          avaliacoes = data
              .where((a) => a["empresa_id"] == widget.empresa.id)
              .map<Map<String, dynamic>>((a) => Map<String, dynamic>.from(a))
              .toList();
        });

        debugPrint("⭐ Avaliações carregadas: ${avaliacoes.length}");
      }
    } catch (e) {
      debugPrint("❌ ERRO AO CARREGAR AVALIAÇÕES => $e");
    }
  }

  // =========================
  // ⭐ ENVIAR AVALIAÇÃO
  // =========================
  Future<void> enviarAvaliacao() async {
    try {
      if (usuarioJaAvaliou()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Você já avaliou esta empresa.")),
        );

        return;
      }

      setState(() {
        enviandoAvaliacao = true;
      });

      final token = await ApiService.getToken();

      final response = await http.post(
        Uri.parse("$baseUrl/avaliacoes/avaliacoes/"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "empresa_id": widget.empresa.id,
          "usuario_id": usuarioId,
          "nota": notaSelecionada,
          "comentario": comentarioController.text.trim(),
        }),
      );

      debugPrint("⭐ STATUS ENVIO: ${response.statusCode}");

      debugPrint("⭐ BODY ENVIO: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        comentarioController.clear();

        notaSelecionada = 5;

        await carregarAvaliacoes();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Avaliação enviada com sucesso!")),
          );
        }
      }
    } catch (e) {
      debugPrint("❌ ERRO ENVIAR AVALIAÇÃO => $e");
    } finally {
      setState(() {
        enviandoAvaliacao = false;
      });
    }
  }

  // =========================
  // ⭐ MÉDIA AVALIAÇÕES
  // =========================
  double get mediaAvaliacoes {
    if (avaliacoes.isEmpty) return 0;

    final total = avaliacoes.fold<int>(
      0,
      (sum, item) => sum + ((item["nota"] ?? 0) as int),
    );

    return total / avaliacoes.length;
  }

  // =========================
  // 🎨 UI
  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.empresa.nome),
        backgroundColor: Colors.blue,
        actions: [
          if (widget.isAdmin)
            IconButton(
              icon: const Icon(Icons.photo_library),
              tooltip: "Manutenção de Fotos",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EmpresaFotosScreen(
                      empresaId: widget.empresa.id,
                      isAdmin: widget.isAdmin,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: carregarAvaliacoes,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // =========================
              // 📸 GALERIA
              // =========================
              SizedBox(
                height: 220,
                child: widget.empresa.fotos.isNotEmpty
                    ? PageView.builder(
                        itemCount: widget.empresa.fotos.length,
                        itemBuilder: (_, index) {
                          return Image.network(
                            widget.empresa.fotos[index].url,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (_, __, ___) => _placeholder(),
                          );
                        },
                      )
                    : _placeholder(),
              ),

              const SizedBox(height: 16),

              // =========================
              // 📌 INFORMAÇÕES
              // =========================
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.empresa.nome,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    if (widget.empresa.descricao != null)
                      Text(
                        widget.empresa.descricao!,
                        style: const TextStyle(fontSize: 16),
                      ),

                    const SizedBox(height: 16),

                    _infoItem(Icons.phone, widget.empresa.telefone),

                    _infoItem(Icons.email, widget.empresa.email),

                    _infoItem(Icons.location_on, widget.empresa.endereco),

                    const SizedBox(height: 20),

                    // =========================
                    // 🚀 BOTÕES
                    // =========================
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _actionButton(
                          icon: Icons.phone,
                          label: "Ligar",
                          color: Colors.green,
                          onTap: () => _ligar(widget.empresa.telefone),
                        ),
                        _actionButton(
                          icon: Icons.chat,
                          label: "WhatsApp",
                          color: Colors.teal,
                          onTap: () => _whatsapp(widget.empresa.telefone),
                        ),
                        _actionButton(
                          icon: Icons.email,
                          label: "Email",
                          color: Colors.orange,
                          onTap: () => _email(widget.empresa.email),
                        ),
                        _actionButton(
                          icon: Icons.map,
                          label: "Mapa",
                          color: Colors.blue,
                          onTap: _mapa,
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // =========================
                    // ⭐ AVALIAR
                    // =========================
                    const Text(
                      "Avalie esta empresa",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    if (usuarioJaAvaliou())
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          "Você já avaliou esta empresa.",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      )
                    else ...[
                      Row(
                        children: List.generate(
                          5,
                          (index) => IconButton(
                            onPressed: () {
                              setState(() {
                                notaSelecionada = index + 1;
                              });
                            },
                            icon: Icon(
                              index < notaSelecionada
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber,
                            ),
                          ),
                        ),
                      ),
                      TextField(
                        controller: comentarioController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: "Escreva sua avaliação",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: enviandoAvaliacao ? null : enviarAvaliacao,
                          icon: enviandoAvaliacao
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.send),
                          label: Text(
                            enviandoAvaliacao
                                ? "Enviando..."
                                : "Enviar avaliação",
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 30),

                    // =========================
                    // ⭐ MÉDIA
                    // =========================
                    Row(
                      children: [
                        const Text(
                          "Avaliações",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(Icons.star, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          mediaAvaliacoes.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Text(
                      avaliacoes.isEmpty
                          ? "Nenhuma avaliação ainda"
                          : "${avaliacoes.length} avaliações recebidas",
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================
  // 🔧 COMPONENTES
  // =========================
  Widget _infoItem(IconData icon, String? text) {
    if (text == null || text.isEmpty) {
      return const SizedBox();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: Colors.grey[300],
      child: const Center(child: Icon(Icons.image_not_supported, size: 50)),
    );
  }
}
