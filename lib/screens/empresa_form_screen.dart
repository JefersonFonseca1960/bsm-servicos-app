import 'package:flutter/material.dart';

import '../models/empresa_model.dart';
import '../models/servico.dart';
import '../services/api_service.dart';

class EmpresaFormScreen extends StatefulWidget {
  final Empresa? empresa;

  const EmpresaFormScreen({super.key, this.empresa});

  @override
  State<EmpresaFormScreen> createState() => _EmpresaFormScreenState();
}

class _EmpresaFormScreenState extends State<EmpresaFormScreen> {
  final nomeController = TextEditingController();
  final descricaoController = TextEditingController();
  final telefoneController = TextEditingController();
  final whatsappController = TextEditingController();
  final emailController = TextEditingController();

  final enderecoController = TextEditingController();

  final cidadeController = TextEditingController();

  final estadoController = TextEditingController();

  final cepController = TextEditingController();

  final latitudeController = TextEditingController();

  final longitudeController = TextEditingController();

  final prioridadeController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  List<Servico> servicos = [];

  int? servicoSelecionado;

  bool carregando = false;

  bool carregandoEmpresa = false;

  // =========================
  // FLAGS PREMIUM
  // =========================

  bool destaque = false;

  bool whatsappDestacado = false;

  bool exibirNoTopo = false;

  bool seloPremium = false;

  bool ativo = true;

  String planoSelecionado = "gratuito";

  Empresa? get empresa => widget.empresa;

  bool get editando => empresa != null;

  @override
  void initState() {
    super.initState();

    carregarServicos();

    if (editando) {
      carregarEmpresaAtualizada();
    } else {
      prioridadeController.text = "0";

      debugPrint("🆕 NOVA EMPRESA");
    }
  }

  // =========================
  // RECARREGAR EMPRESA
  // =========================

  Future<void> carregarEmpresaAtualizada() async {
    try {
      setState(() {
        carregandoEmpresa = true;
      });

      final json = await ApiService.getEmpresa(empresa!.id);

      final e = Empresa.fromJson(json);

      nomeController.text = e.nome;

      descricaoController.text = e.descricao ?? '';

      telefoneController.text = e.telefone ?? '';

      whatsappController.text = e.whatsapp ?? "";

      emailController.text = e.email ?? '';

      enderecoController.text = e.endereco ?? '';

      cidadeController.text = e.cidade ?? '';

      estadoController.text = e.estado ?? '';

      cepController.text = e.cep ?? '';

      latitudeController.text = e.latitude?.toString() ?? '';

      longitudeController.text = e.longitude?.toString() ?? '';

      servicoSelecionado = e.servicoId;

      destaque = e.destaque;

      whatsappDestacado = e.whatsappDestacado;

      exibirNoTopo = e.exibirNoTopo;

      seloPremium = e.seloPremium;

      ativo = e.ativo;

      planoSelecionado = e.plano;

      prioridadeController.text = e.prioridade.toString();

      debugPrint("✅ EMPRESA RECARREGADA DO BACKEND");

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint("❌ ERRO AO RECARREGAR EMPRESA => $e");
    } finally {
      if (mounted) {
        setState(() {
          carregandoEmpresa = false;
        });
      }
    }
  }

  // =========================
  // CARREGAR SERVIÇOS
  // =========================

  Future<void> carregarServicos() async {
    try {
      final lista = await ApiService.getServicos();

      if (!mounted) return;

      setState(() {
        servicos = lista;
      });
    } catch (e) {
      debugPrint("❌ ERRO SERVIÇOS => $e");
    }
  }

  // =========================
  // SALVAR
  // =========================

  Future<void> salvar() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    if (servicoSelecionado == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Selecione um serviço")));

      return;
    }

    try {
      setState(() {
        carregando = true;
      });

      final data = {
        "nome": nomeController.text.trim(),

        "descricao": descricaoController.text.trim(),

        "telefone": telefoneController.text.trim(),

        "whatsapp": whatsappController.text.trim(),

        "email": emailController.text.trim(),

        "endereco": enderecoController.text.trim(),

        "cidade": cidadeController.text.trim(),

        "estado": estadoController.text.trim(),

        "cep": cepController.text.trim(),

        "latitude": double.tryParse(
          latitudeController.text.replaceAll(',', '.'),
        ),

        "longitude": double.tryParse(
          longitudeController.text.replaceAll(',', '.'),
        ),

        "servico_id": servicoSelecionado,

        // =========================
        // PREMIUM
        // =========================
        "destaque": destaque,

        "whatsapp_destacado": whatsappDestacado,

        "exibir_no_topo": exibirNoTopo,

        "selo_premium": seloPremium,

        "ativo": ativo,

        "plano": planoSelecionado,

        "prioridade": int.tryParse(prioridadeController.text) ?? 0,
      };

      debugPrint("📤 PAYLOAD => $data");

      if (editando) {
        final id = empresa!.id;

        await ApiService.updateEmpresa(id, data);

        debugPrint("✅ EMPRESA ATUALIZADA");
      } else {
        await ApiService.createEmpresa(data);

        debugPrint("✅ EMPRESA CRIADA");
      }

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      debugPrint("❌ ERRO => $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro ao salvar empresa"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          carregando = false;
        });
      }
    }
  }

  // =========================
  // UI
  // =========================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(editando ? "Editar Empresa" : "Nova Empresa")),

      body: carregandoEmpresa
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),

                children: [
                  // =========================
                  // DADOS BÁSICOS
                  // =========================
                  TextFormField(
                    controller: nomeController,

                    decoration: const InputDecoration(labelText: "Nome"),

                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return "Informe o nome";
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 12),

                  TextFormField(
                    controller: descricaoController,

                    decoration: const InputDecoration(labelText: "Descrição"),

                    maxLines: 3,
                  ),

                  const SizedBox(height: 12),

                  TextFormField(
                    controller: telefoneController,

                    decoration: const InputDecoration(labelText: "Telefone"),
                  ),

                  const SizedBox(height: 12),

                  TextFormField(
                    controller: whatsappController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: "WhatsApp",
                      prefixIcon: Icon(Icons.message),
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextFormField(
                    controller: emailController,

                    decoration: const InputDecoration(labelText: "Email"),
                  ),

                  const SizedBox(height: 12),

                  TextFormField(
                    controller: enderecoController,

                    decoration: const InputDecoration(labelText: "Endereço"),
                  ),

                  const SizedBox(height: 12),

                  TextFormField(
                    controller: cidadeController,

                    decoration: const InputDecoration(labelText: "Cidade"),
                  ),

                  const SizedBox(height: 12),

                  TextFormField(
                    controller: estadoController,

                    decoration: const InputDecoration(labelText: "Estado"),
                  ),

                  const SizedBox(height: 12),

                  TextFormField(
                    controller: cepController,

                    decoration: const InputDecoration(labelText: "CEP"),
                  ),

                  const SizedBox(height: 20),

                  // =========================
                  // LOCALIZAÇÃO
                  // =========================
                  const Text(
                    "Localização",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 12),

                  TextFormField(
                    controller: latitudeController,

                    keyboardType: TextInputType.number,

                    decoration: const InputDecoration(labelText: "Latitude"),
                  ),

                  const SizedBox(height: 12),

                  TextFormField(
                    controller: longitudeController,

                    keyboardType: TextInputType.number,

                    decoration: const InputDecoration(labelText: "Longitude"),
                  ),

                  const SizedBox(height: 20),

                  // =========================
                  // SERVIÇO
                  // =========================
                  DropdownButtonFormField<int>(
                    value: servicoSelecionado,

                    items: servicos
                        .map(
                          (s) => DropdownMenuItem<int>(
                            value: s.id,
                            child: Text(s.nome),
                          ),
                        )
                        .toList(),

                    onChanged: (v) {
                      setState(() {
                        servicoSelecionado = v;
                      });
                    },

                    decoration: const InputDecoration(labelText: "Serviço"),
                  ),

                  const SizedBox(height: 20),

                  // =========================
                  // PREMIUM
                  // =========================
                  const Text(
                    "Configurações Premium",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 12),

                  SwitchListTile(
                    value: destaque,

                    onChanged: (v) {
                      setState(() {
                        destaque = v;
                      });
                    },

                    title: const Text("Destaque"),
                  ),

                  SwitchListTile(
                    value: whatsappDestacado,

                    onChanged: (v) {
                      setState(() {
                        whatsappDestacado = v;
                      });
                    },

                    title: const Text("WhatsApp Destacado"),
                  ),

                  SwitchListTile(
                    value: exibirNoTopo,

                    onChanged: (v) {
                      setState(() {
                        exibirNoTopo = v;
                      });
                    },

                    title: const Text("Exibir no Topo"),
                  ),

                  SwitchListTile(
                    value: seloPremium,

                    onChanged: (v) {
                      setState(() {
                        seloPremium = v;
                      });
                    },

                    title: const Text("Selo Premium"),
                  ),

                  SwitchListTile(
                    value: ativo,

                    onChanged: (v) {
                      setState(() {
                        ativo = v;
                      });
                    },

                    title: const Text("Empresa Ativa"),
                  ),

                  const SizedBox(height: 20),

                  // =========================
                  // PLANO
                  // =========================
                  DropdownButtonFormField<String>(
                    value: planoSelecionado,

                    items: const [
                      DropdownMenuItem(
                        value: "gratuito",

                        child: Text("Gratuito"),
                      ),

                      DropdownMenuItem(
                        value: "premium",

                        child: Text("Premium"),
                      ),

                      DropdownMenuItem(value: "master", child: Text("Master")),
                    ],

                    onChanged: (v) {
                      if (v != null) {
                        setState(() {
                          planoSelecionado = v;
                        });
                      }
                    },

                    decoration: const InputDecoration(labelText: "Plano"),
                  ),

                  const SizedBox(height: 12),

                  TextFormField(
                    controller: prioridadeController,

                    keyboardType: TextInputType.number,

                    decoration: const InputDecoration(labelText: "Prioridade"),
                  ),

                  const SizedBox(height: 30),

                  ElevatedButton(
                    onPressed: carregando ? null : salvar,

                    child: carregando
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            editando ? "Atualizar Empresa" : "Criar Empresa",
                          ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }
}
