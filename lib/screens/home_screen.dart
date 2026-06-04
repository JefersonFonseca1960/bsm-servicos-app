import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Empresa> empresas = [];
  List<Servico> servicos = [];

  bool carregando = true;
  bool carregandoUsuario = true;

  int? servicoSelecionado;

  String tipoUsuario = "";
  String busca = "";

  Position? posicaoUsuario;

  // =========================
  // INIT
  // =========================

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await obterLocalizacao();

    await Future.wait([
      carregarEmpresas(),
      carregarUsuario(),
      carregarServicos(),
    ]);
  }

  // =========================
  // LOCALIZAÇÃO
  // =========================

  Future<void> obterLocalizacao() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        return;
      }

      posicaoUsuario = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      debugPrint("❌ ERRO GPS => $e");
    }
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
  }

  // =========================
  // EMPRESAS
  // =========================

  Future<void> carregarEmpresas() async {
    for (final e in empresas) {
      debugPrint("""
        EMPRESA: ${e.nome}
        PLANO: ${e.plano}
        DESTAQUE: ${e.destaque}
        WHATSAPP: ${e.whatsappDestacado}
        SELO: ${e.seloPremium}
        -----------------------
        """);
    }

    try {
      final lista = await api.ApiService.getEmpresas();

      for (final e in lista) {
        debugPrint("EMPRESA => ${e.nome} | PLANO => ${e.plano}");
      }

      if (!mounted) return;

      // ======================================
      // ORDENAÇÃO POR PLANO + DISTÂNCIA
      // ======================================

      lista.sort((a, b) {
        int pesoPlano(Empresa e) {
          switch ((e.plano ?? '').toLowerCase()) {
            case 'master':
              return 1;

            case 'premium':
              return 2;

            default:
              return 3;
          }
        }

        final planoA = pesoPlano(a);
        final planoB = pesoPlano(b);

        // primeiro ordena por plano
        if (a.exibirNoTopo != b.exibirNoTopo) {
          return a.exibirNoTopo ? -1 : 1;
        }

        if (planoA != planoB) {
          return planoA.compareTo(planoB);
        }

        // depois por destaque
        if (a.destaque != b.destaque) {
          return b.destaque ? 1 : -1;
        }

        // depois por distância
        final distA = calcularDistancia(a);
        final distB = calcularDistancia(b);

        return distA.compareTo(distB);
      });

      setState(() {
        empresas = lista;
        carregando = false;
      });
    } catch (e) {
      debugPrint("❌ ERRO HOME => $e");

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
      debugPrint("❌ ERRO SERVIÇOS => $e");
    }
  }

  // =========================
  // REFRESH
  // =========================

  Future<void> refresh() async {
    await carregarEmpresas();
  }

  // =========================
  // DISTÂNCIA
  // =========================

  double calcularDistancia(Empresa empresa) {
    if (posicaoUsuario == null ||
        empresa.latitude == null ||
        empresa.longitude == null) {
      return 999999;
    }

    return Geolocator.distanceBetween(
          posicaoUsuario!.latitude,
          posicaoUsuario!.longitude,
          empresa.latitude!,
          empresa.longitude!,
        ) /
        1000;
  }

  String distanciaTexto(Empresa empresa) {
    final km = calcularDistancia(empresa);

    if (km == 999999) return "";

    if (km < 1) {
      return "${(km * 1000).toInt()} m";
    }

    return "${km.toStringAsFixed(1)} km";
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
  // ÍCONES SERVIÇOS
  // =========================

  IconData getServicoIcon(String nome) {
    final texto = nome.toLowerCase();

    if (texto.contains("rest")) {
      return Icons.restaurant;
    }

    if (texto.contains("pizza")) {
      return Icons.local_pizza;
    }

    if (texto.contains("lanche")) {
      return Icons.lunch_dining;
    }

    if (texto.contains("hamb")) {
      return Icons.fastfood;
    }

    if (texto.contains("merc")) {
      return Icons.shopping_cart;
    }

    if (texto.contains("farm")) {
      return Icons.local_pharmacy;
    }

    if (texto.contains("hotel")) {
      return Icons.hotel;
    }

    if (texto.contains("beleza")) {
      return Icons.content_cut;
    }

    if (texto.contains("bar")) {
      return Icons.local_bar;
    }

    if (texto.contains("mec")) {
      return Icons.build;
    }

    return Icons.storefront;
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

  Widget imagemPlaceholder() {
    return Container(
      width: 85,
      height: 85,
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(Icons.store, size: 36, color: Colors.blue.shade300),
    );
  }

  // =========================
  // ESTRELAS
  // =========================

  Widget buildStars(double nota) {
    return Row(
      children: List.generate(
        5,
        (index) => Icon(
          index < nota.round() ? Icons.star : Icons.star_border,
          size: 15,
          color: Colors.amber,
        ),
      ),
    );
  }

  // =========================
  // CARD EMPRESA
  // =========================

  Widget buildEmpresaCard(Empresa empresa) {
    final imageUrl = getImageUrl(empresa);
    final plano = (empresa.plano ?? "").toLowerCase();
    final bool isMaster = plano == "master";
    final bool isPremium = plano == "premium";
    return InkWell(
      borderRadius: BorderRadius.circular(18),
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
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMaster
              ? Colors.orange.shade50
              : isPremium
              ? Colors.amber.shade50
              : Colors.white,
          borderRadius: BorderRadius.circular(18),

          border: Border.all(
            color: isMaster
                ? Colors.deepOrange
                : isPremium
                ? Colors.amber
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // FOTO
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      width: 82,
                      height: 82,
                      placeholder: (context, url) {
                        return Container(
                          width: 82,
                          height: 82,
                          alignment: Alignment.center,
                          child: const CircularProgressIndicator(),
                        );
                      },
                      errorWidget: (context, url, error) {
                        return imagemPlaceholder();
                      },
                    )
                  : imagemPlaceholder(),
            ),

            const SizedBox(width: 12),

            // TEXTO
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          empresa.nome,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      if (isMaster)
                        const Padding(
                          padding: EdgeInsets.only(left: 6),
                          child: Icon(
                            Icons.workspace_premium,
                            color: Colors.deepOrange,
                            size: 20,
                          ),
                        ),

                      if (isPremium)
                        Container(
                          margin: const EdgeInsets.only(left: 6),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            "PREMIUM",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  if (empresa.descricao != null &&
                      empresa.descricao!.trim().isNotEmpty)
                    Text(
                      empresa.descricao!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        height: 1.3,
                        fontSize: 13,
                      ),
                    ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      buildStars(empresa.avaliacaoMedia ?? 0),

                      const SizedBox(width: 5),

                      Text(
                        (empresa.avaliacaoMedia ?? 0).toStringAsFixed(1),
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 7),

                  if (empresa.whatsappDestacado &&
                      empresa.whatsapp != null &&
                      empresa.whatsapp!.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.chat, size: 14, color: Colors.green),
                          const SizedBox(width: 4),
                          Text(
                            empresa.whatsapp!,
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),

                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 15,
                        color: Colors.red.shade400,
                      ),

                      const SizedBox(width: 3),

                      Expanded(
                        child: Text(
                          empresa.bairro ?? empresa.cidade ?? "",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),

                  if (distanciaTexto(empresa).isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Row(
                        children: [
                          Icon(
                            Icons.near_me,
                            size: 14,
                            color: Colors.blue.shade600,
                          ),

                          const SizedBox(width: 4),

                          Text(
                            distanciaTexto(empresa),
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // ADMIN
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (tipoUsuario == "admin")
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
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
                  size: 14,
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
  // CATEGORIAS COM ÍCONES
  // =========================

  Widget buildCategorias() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: servicos.length,
        itemBuilder: (context, index) {
          final servico = servicos[index];

          final selecionado = servicoSelecionado == servico.id;

          return GestureDetector(
            onTap: () {
              setState(() {
                if (selecionado) {
                  servicoSelecionado = null;
                } else {
                  servicoSelecionado = servico.id;
                }
              });
            },
            child: Container(
              width: 82,
              margin: const EdgeInsets.only(right: 12),
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      color: selecionado ? Colors.blue : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Icon(
                      getServicoIcon(servico.nome),
                      color: selecionado ? Colors.white : Colors.blue,
                      size: 30,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    servico.nome,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: selecionado
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: selecionado ? Colors.blue : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // =========================
  // HEADER
  // =========================

  Widget buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xff1565C0), Color(0xff42A5F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TOPO
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      _scaffoldKey.currentState?.openDrawer();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.menu,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),

                  if (tipoUsuario == "admin")
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "ADMIN",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 18),

              const Text(
                "BSM Serviços",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              const Text(
                "Encontre empresas e serviços",
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),

              const SizedBox(height: 16),

              // BUSCA
              SizedBox(
                height: 52,
                child: TextField(
                  onChanged: (v) {
                    setState(() {
                      busca = v;
                    });
                  },
                  style: const TextStyle(fontSize: 15),
                  decoration: InputDecoration(
                    hintText: "Buscar empresa ou serviço...",
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    prefixIcon: Icon(Icons.search, color: Colors.blue.shade700),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.zero,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(28),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // FILTRO LISTA
              Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Icon(Icons.tune, color: Colors.blue.shade700, size: 20),

                    const SizedBox(width: 10),

                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          isExpanded: true,
                          value: servicoSelecionado,

                          hint: const Text(
                            "Filtrar categoria",
                            style: TextStyle(fontSize: 14),
                          ),

                          items: [
                            const DropdownMenuItem<int>(
                              value: null,
                              child: Text("Todas categorias"),
                            ),

                            ...servicos.map((s) {
                              return DropdownMenuItem<int>(
                                value: s.id,

                                child: Text(
                                  s.nome,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              );
                            }),
                          ],

                          onChanged: (value) {
                            setState(() {
                              servicoSelecionado = value;
                            });
                          },
                        ),
                      ),
                    ),

                    if (servicoSelecionado != null)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            servicoSelecionado = null;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close,
                            color: Colors.red.shade400,
                            size: 18,
                          ),
                        ),
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
  // UI
  // =========================

  @override
  Widget build(BuildContext context) {
    if (carregando || carregandoUsuario) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xffF4F7FB),

      drawer: const AppDrawer(),

      floatingActionButton: tipoUsuario == "admin"
          ? FloatingActionButton.small(
              backgroundColor: Colors.blue,
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EmpresaFormScreen()),
                );

                refresh();
              },
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,

      body: RefreshIndicator(
        onRefresh: refresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: buildHeader()),

            // TÍTULO
            if (empresasFiltradas.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
                  child: Text(
                    servicoSelecionado == null
                        ? "Empresas próximas"
                        : "Resultados",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade900,
                    ),
                  ),
                ),
              ),

            // VAZIO
            if (empresasFiltradas.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 70,
                        color: Colors.grey.shade400,
                      ),

                      const SizedBox(height: 16),

                      Text(
                        "Nenhuma empresa encontrada",
                        style: TextStyle(
                          fontSize: 17,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // LISTA
            if (empresasFiltradas.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.only(bottom: 90),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return buildEmpresaCard(empresasFiltradas[index]);
                  }, childCount: empresasFiltradas.length),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
