import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../services/api_service.dart';
import '../models/empresa_model.dart';
import 'empresa_fotos_screen.dart';
import 'avaliacoes_screen.dart';

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
  List<Map<String, dynamic>> avaliacoes = [];

  int notaSelecionada = 5;
  final comentarioController = TextEditingController();

  bool enviandoAvaliacao = false;
  bool carregandoAvaliacoes = false;

  final String baseUrl = "https://bsm-servicos-backend-1.onrender.com";

  int? usuarioId;

  // =========================
  // 🔐 PERMISSÕES
  // =========================
  Map<String, dynamic> get permissoes =>
      widget.empresa.permissoes ?? {"galeria": false};

  bool get podeUsarGaleria => permissoes["galeria"] == true || widget.isAdmin;

  //
  //
  //
  void abrirAvaliacoes() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AvaliacoesScreen(
          empresaId: widget.empresa.id,
          isAdmin: widget.isAdmin,
        ),
      ),
    );
  }
  //
  //
  //

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      carregarDados();
    });
  }

  @override
  void dispose() {
    comentarioController.dispose();
    super.dispose();
  }

  // =========================
  // NAV GALERIA
  // =========================
  void abrirGaleria() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EmpresaFotosScreen(
          empresaId: widget.empresa.id,
          isAdmin: widget.isAdmin,
          permissoes: permissoes,
        ),
      ),
    );
  }

  // =========================
  // LINKS
  // =========================
  Future<void> _ligar(String? telefone) async {
    if (telefone == null || telefone.isEmpty) return;

    final uri = Uri.parse("tel:$telefone");

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _whatsapp(String? telefone) async {
    if (telefone == null || telefone.isEmpty) return;

    final numero = telefone.replaceAll(RegExp(r'[^0-9]'), '');
    final uri = Uri.parse("https://wa.me/55$numero");

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _email(String? email) async {
    if (email == null || email.isEmpty) return;

    final uri = Uri.parse("mailto:$email");

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _mapa() async {
    if (widget.empresa.latitude == null || widget.empresa.longitude == null)
      return;

    final uri = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=${widget.empresa.latitude},${widget.empresa.longitude}",
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // =========================
  // AVALIAÇÕES
  // =========================
  Future<void> carregarAvaliacoes() async {
    try {
      setState(() => carregandoAvaliacoes = true);

      final response = await http.get(Uri.parse("$baseUrl/avaliacoes/"));

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint("ERRO: $e");
    } finally {
      setState(() => carregandoAvaliacoes = false);
    }
  }

  Future<void> carregarDados() async {
    await carregarAvaliacoes();
  }

  // =========================
  // MÉDIA
  // =========================
  double get mediaAvaliacoes {
    if (avaliacoes.isEmpty) return 0;

    final total = avaliacoes.fold<double>(
      0,
      (sum, item) => sum + double.tryParse(item["nota"].toString())!,
    );

    return total / avaliacoes.length;
  }

  // =========================
  // UI
  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.empresa.nome),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.photo_library),
            onPressed: podeUsarGaleria
                ? abrirGaleria
                : () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Disponível apenas no plano Premium"),
                      ),
                    );
                  },
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =========================
            // GALERIA
            // =========================
            SizedBox(
              height: 220,
              child: widget.empresa.fotos.isNotEmpty
                  ? PageView.builder(
                      itemCount: widget.empresa.fotos.length,
                      itemBuilder: (_, index) {
                        final foto = widget.empresa.fotos[index];

                        return GestureDetector(
                          onTap: podeUsarGaleria ? abrirGaleria : null,
                          child: CachedNetworkImage(
                            imageUrl: foto.url,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            placeholder: (_, __) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            errorWidget: (_, __, ___) =>
                                const Icon(Icons.broken_image),
                          ),
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.image_not_supported, size: 50),
                      ),
                    ),
            ),

            const SizedBox(height: 16),

            // =========================
            // INFO
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

                  Text(widget.empresa.descricao ?? ""),

                  const SizedBox(height: 16),

                  _info(Icons.phone, widget.empresa.telefone),
                  _info(Icons.email, widget.empresa.email),
                  _info(Icons.location_on, widget.empresa.endereco),

                  const SizedBox(height: 20),

                  Wrap(
                    spacing: 10,
                    children: [
                      _btn(
                        "Ligar",
                        Icons.phone,
                        Colors.green,
                        () => _ligar(widget.empresa.telefone),
                      ),
                      _btn(
                        "WhatsApp",
                        Icons.chat,
                        Colors.teal,
                        () => _whatsapp(widget.empresa.telefone),
                      ),
                      _btn(
                        "Email",
                        Icons.email,
                        Colors.orange,
                        () => _email(widget.empresa.email),
                      ),
                      _btn("Mapa", Icons.map, Colors.blue, _mapa),
                    ],
                  ),

                  const SizedBox(height: 30),

                  Row(
                    children: [
                      const Text(
                        "Avaliações",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const Spacer(),

                      ElevatedButton.icon(
                        onPressed: abrirAvaliacoes,
                        icon: const Icon(Icons.star),
                        label: const Text("Avaliar"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black,
                        ),
                      ),

                      const SizedBox(width: 10),

                      const Icon(Icons.star, color: Colors.amber),

                      Text(mediaAvaliacoes.toStringAsFixed(1)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _info(IconData icon, String? text) {
    if (text == null || text.isEmpty) return const SizedBox();

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

  Widget _btn(String label, IconData icon, Color color, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
      ),
    );
  }
}
