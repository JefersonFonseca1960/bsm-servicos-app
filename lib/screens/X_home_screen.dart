import 'dart:async';

import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../models/empresa_model.dart';
import 'empresa_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Empresa> empresas = [];

  bool loading = false;
  String erro = "";
  bool jaBuscou = false;

  Timer? _debounce;

  String tipoUsuario = "";

  bool get isAdmin => tipoUsuario == "admin";

  @override
  void initState() {
    super.initState();

    carregarUsuario();

    debugPrint("🔥 HOME SCREEN INICIADA");
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  // =========================
  // 👤 USUÁRIO
  // =========================
  Future<void> carregarUsuario() async {
    try {
      final tipo = await ApiService.getUserType();

      final normalizado = tipo
          .toString()
          .toLowerCase()
          .replaceAll("[", "")
          .replaceAll("]", "")
          .trim();

      debugPrint("🧠 TIPO FINAL NORMALIZADO: [$normalizado]");

      if (!mounted) return;

      setState(() {
        tipoUsuario = normalizado;
      });

      debugPrint("🔥 IS ADMIN => $isAdmin");
    } catch (e) {
      debugPrint("❌ ERRO AO CARREGAR USUÁRIO: $e");
    }
  }

  // =========================
  // 🔍 BUSCA
  // =========================
  void buscar(String texto) {
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }

    _debounce = Timer(
      const Duration(milliseconds: 500),
      () async {
        if (texto.trim().isEmpty) {
          setState(() {
            empresas = [];
            jaBuscou = false;
          });

          return;
        }

        setState(() {
          loading = true;
          erro = "";
          jaBuscou = true;
        });

        try {
          // =========================
          // 🔥 AJUSTE PRINCIPAL
          // =========================
          final lista = await ApiService.getEmpresas();

          final filtro = lista.where((empresa) {
            final busca = texto.toLowerCase();

            final nomeEmpresa = empresa.nome.toLowerCase();

            return nomeEmpresa.contains(busca);
          }).toList();

          if (!mounted) return;

          setState(() {
            empresas = filtro;
            loading = false;
          });

          debugPrint(
            "📋 EMPRESAS FILTRADAS: ${empresas.length}",
          );
        } catch (e) {
          if (!mounted) return;

          setState(() {
            loading = false;
            erro = "Erro ao buscar empresas";
          });

          debugPrint("❌ ERRO BUSCA: $e");
        }
      },
    );
  }

  // =========================
  // 🖼 IMAGEM
  // =========================
  String? getImageUrl(Empresa empresa) {
    if (empresa.fotoPrincipal != null && empresa.fotoPrincipal!.isNotEmpty) {
      return empresa.fotoPrincipal!;
    }

    if (empresa.fotos.isNotEmpty) {
      return empresa.fotos.first.url;
    }

    return null;
  }

  // =========================
  // 📦 CARD EMPRESA
  // =========================
  Widget buildEmpresaCard(Empresa empresa) {
    final imageUrl = getImageUrl(empresa);

    debugPrint(
      "🔥 RENDER CARD => ${empresa.nome} / ADMIN: $tipoUsuario",
    );

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(10),

        // =========================
        // 📸 FOTO
        // =========================
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: imageUrl != null
              ? Image.network(
                  imageUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _imagemPadrao(),
                )
              : _imagemPadrao(),
        ),

        // =========================
        // 📝 TÍTULO
        // =========================
        title: Text(
          empresa.nome,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        // =========================
        // 📄 SUBTÍTULO
        // =========================
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (empresa.cidade != null) Text(empresa.cidade!),
            if (empresa.bairro != null)
              Text(
                empresa.bairro!,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
          ],
        ),

        // =========================
        // 👉 BOTÕES
        // =========================
        trailing: SizedBox(
          width: isAdmin ? 90 : 30,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (isAdmin)
                IconButton(
                  tooltip: "Editar Empresa",
                  icon: const Icon(
                    Icons.edit,
                    color: Colors.blue,
                  ),
                  onPressed: () {
                    debugPrint(
                      "🆕 CLICOU ADMIN",
                    );

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EmpresaDetailScreen(
                          empresa: empresa,
                          isAdmin: true,
                        ),
                      ),
                    );
                  },
                ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
              ),
            ],
          ),
        ),

        // =========================
        // 👉 DETALHES
        // =========================
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EmpresaDetailScreen(
                empresa: empresa,
                isAdmin: isAdmin,
              ),
            ),
          );
        },
      ),
    );
  }

  // =========================
  // 🧱 UI
  // =========================
  @override
  Widget build(BuildContext context) {
    debugPrint(
      "🔥 BUILD HOME => ADMIN: $tipoUsuario",
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("BSM Serviços"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // =========================
          // 🔍 BUSCA
          // =========================
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: buscar,
              decoration: InputDecoration(
                hintText: "Buscar empresa...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // =========================
          // ⏳ LOADING
          // =========================
          if (loading)
            const Padding(
              padding: EdgeInsets.all(10),
              child: CircularProgressIndicator(),
            ),

          // =========================
          // ❌ ERRO
          // =========================
          if (erro.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                erro,
                style: const TextStyle(
                  color: Colors.red,
                ),
              ),
            ),

          // =========================
          // 🔍 INICIAL
          // =========================
          if (!jaBuscou && !loading)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                "Digite algo para buscar",
              ),
            ),

          // =========================
          // 📭 VAZIO
          // =========================
          if (jaBuscou && !loading && empresas.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                "Nenhuma empresa encontrada",
              ),
            ),

          // =========================
          // 📋 LISTA
          // =========================
          if (empresas.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: empresas.length,
                itemBuilder: (context, index) {
                  return buildEmpresaCard(
                    empresas[index],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  // =========================
  // 🧱 PLACEHOLDER
  // =========================
  Widget _imagemPadrao() {
    return Container(
      width: 60,
      height: 60,
      color: Colors.grey[300],
      child: const Icon(Icons.store),
    );
  }
}
