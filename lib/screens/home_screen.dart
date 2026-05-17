import 'package:flutter/material.dart';

import '../services/api_service.dart' as api;
import '../models/empresa_model.dart';
import '../models/servico.dart';

import '../widgets/app_drawer.dart';

import 'empresa_form_screen.dart';
import 'empresa_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Empresa> empresas = [];
  List<Servico> servicos = [];

  bool carregando = true;
  bool carregandoUsuario = true;

  int? servicoSelecionado;

  String tipoUsuario = "";
  String busca = "";

  @override
  void initState() {
    super.initState();
    _init();
  }

  // =========================
  // INIT
  // =========================
  Future<void> _init() async {
    await Future.wait([
      carregarEmpresas(),
      carregarUsuario(),
      carregarServicos(),
    ]);
  }

  // =========================
  // USUÁRIO
  // =========================
  Future<void> carregarUsuario() async {
    final tipo = await api.ApiService.getUserType();

    if (!mounted) return;

    setState(() {
      tipoUsuario = (tipo ?? "").trim().toLowerCase();
      carregandoUsuario = false;
    });

    debugPrint("🧠 HOME USER => $tipoUsuario");
  }

  // =========================
  // EMPRESAS
  // =========================
  Future<void> carregarEmpresas() async {
    try {
      final lista = await api.ApiService.getEmpresas();

      if (!mounted) return;

      setState(() {
        empresas = lista;
        carregando = false;
      });
    } catch (e) {
      debugPrint("ERRO HOME => $e");

      if (!mounted) return;

      setState(() {
        carregando = false;
      });
    }
  }

  // =========================
  // SERVIÇOS
  // =========================
  Future<void> carregarServicos() async {
    try {
      final lista = await api.ApiService.getServicos();

      if (!mounted) return;

      setState(() {
        servicos = lista;
      });
    } catch (e) {
      debugPrint("ERRO SERVIÇOS => $e");
    }
  }

  // =========================
  // REFRESH
  // =========================
  Future<void> refresh() async {
    await carregarEmpresas();
  }

  // =========================
  // FILTRO
  // =========================
  List<Empresa> get empresasFiltradas {
    final termo = busca.toLowerCase();

    return empresas.where((empresa) {
      final nomeMatch = empresa.nome.toLowerCase().contains(termo);

      final descricaoMatch = (empresa.descricao ?? "").toLowerCase().contains(
        termo,
      );

      final servicoMatch =
          servicoSelecionado == null || empresa.servicoId == servicoSelecionado;

      return (nomeMatch || descricaoMatch) && servicoMatch;
    }).toList();
  }

  // =========================
  // IMAGEM
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
  // PLACEHOLDER
  // =========================
  Widget imagemPlaceholder() {
    return Container(
      width: 85,
      height: 85,
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(Icons.store, size: 40, color: Colors.blue.shade300),
    );
  }

  // =========================
  // CARD EMPRESA
  // =========================
  Widget buildEmpresaCard(Empresa empresa) {
    final imageUrl = getImageUrl(empresa);

    return InkWell(
      borderRadius: BorderRadius.circular(22),

      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EmpresaDetailScreen(
              empresa: empresa,
              isAdmin: tipoUsuario == "admin",
            ),
          ),
        );
      },

      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

        padding: const EdgeInsets.all(12),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),

        child: Row(
          children: [
            // FOTO
            ClipRRect(
              borderRadius: BorderRadius.circular(16),

              child: imageUrl != null
                  ? Image.network(
                      imageUrl,
                      width: 85,
                      height: 85,
                      fit: BoxFit.cover,

                      errorBuilder: (_, __, ___) => imagemPlaceholder(),
                    )
                  : imagemPlaceholder(),
            ),

            const SizedBox(width: 14),

            // TEXTO
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    empresa.nome,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    empresa.descricao ?? "",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey.shade700),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.red.shade400,
                      ),

                      const SizedBox(width: 4),

                      Expanded(
                        child: Text(
                          empresa.bairro ?? "",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ADMIN
            Column(
              children: [
                if (tipoUsuario == "admin")
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EmpresaFormScreen(empresa: empresa),
                        ),
                      );

                      refresh();
                    },
                  ),

                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // UI
  // =========================
  @override
  Widget build(BuildContext context) {
    if (carregando || carregandoUsuario) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xffF4F7FB),

      drawer: const AppDrawer(),

      floatingActionButton: tipoUsuario == "admin"
          ? FloatingActionButton.extended(
              backgroundColor: Colors.blue,

              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EmpresaFormScreen()),
                );

                refresh();
              },

              icon: const Icon(Icons.add_business, color: Colors.white),

              label: const Text(
                "Nova Empresa",
                style: TextStyle(color: Colors.white),
              ),
            )
          : null,

      body: RefreshIndicator(
        onRefresh: refresh,

        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),

          slivers: [
            // =========================
            // HEADER
            // =========================
            SliverAppBar(
              expandedHeight: 280,
              pinned: true,
              elevation: 0,
              backgroundColor: Colors.transparent,

              iconTheme: const IconThemeData(color: Colors.white),

              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xff1565C0), Color(0xff42A5F5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),

                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),

                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        const SizedBox(height: 10),

                        const Text(
                          "BSM Serviços",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 6),

                        const Text(
                          "Encontre empresas e serviços",
                          style: TextStyle(color: Colors.white70, fontSize: 15),
                        ),

                        const SizedBox(height: 24),

                        // BUSCA
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                          ),

                          child: TextField(
                            onChanged: (v) {
                              setState(() {
                                busca = v;
                              });
                            },

                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.search),

                              hintText: "Buscar empresa...",

                              border: InputBorder.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // DROPDOWN
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14),

                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                          ),

                          child: Row(
                            children: [
                              Expanded(
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<int>(
                                    isExpanded: true,

                                    value: servicoSelecionado,

                                    hint: const Text("Filtrar por serviço"),

                                    items: servicos.map((s) {
                                      return DropdownMenuItem<int>(
                                        value: s.id,
                                        child: Text(s.nome),
                                      );
                                    }).toList(),

                                    onChanged: (value) {
                                      setState(() {
                                        servicoSelecionado = value;
                                      });
                                    },
                                  ),
                                ),
                              ),

                              // LIMPAR FILTRO
                              if (servicoSelecionado != null)
                                IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.red,
                                  ),

                                  onPressed: () {
                                    setState(() {
                                      servicoSelecionado = null;
                                    });
                                  },
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // =========================
            // VAZIO
            // =========================
            if (empresasFiltradas.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,

                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,

                    children: [
                      Icon(
                        Icons.search_off,
                        size: 80,
                        color: Colors.grey.shade400,
                      ),

                      const SizedBox(height: 16),

                      Text(
                        "Nenhuma empresa encontrada",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // =========================
            // LISTA
            // =========================
            if (empresasFiltradas.isNotEmpty)
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final empresa = empresasFiltradas[index];

                  return buildEmpresaCard(empresa);
                }, childCount: empresasFiltradas.length),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}
