import 'package:flutter/material.dart';

import '../models/empresa_model.dart';
import '../models/servico.dart';
import '../services/api_service.dart';

class EmpresaFormScreen extends StatefulWidget {
  final Empresa? empresa;

  const EmpresaFormScreen({
    super.key,
    this.empresa,
  });

  @override
  State<EmpresaFormScreen> createState() => _EmpresaFormScreenState();
}

class _EmpresaFormScreenState extends State<EmpresaFormScreen> {
  final nomeController = TextEditingController();
  final descricaoController = TextEditingController();
  final telefoneController = TextEditingController();
  final emailController = TextEditingController();
  final enderecoController = TextEditingController();
  final cidadeController = TextEditingController();
  final estadoController = TextEditingController();
  final cepController = TextEditingController();
  final latitudeController = TextEditingController();
  final longitudeController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  List<Servico> servicos = [];

  int? servicoSelecionado;

  bool carregando = false;

  Empresa? get empresa => widget.empresa;

  bool get editando => empresa != null;

  @override
  void initState() {
    super.initState();

    carregarServicos();

    if (empresa != null) {
      nomeController.text = empresa!.nome;

      descricaoController.text = empresa!.descricao ?? '';
      telefoneController.text = empresa!.telefone ?? '';
      emailController.text = empresa!.email ?? '';
      enderecoController.text = empresa!.endereco ?? '';
      cidadeController.text = empresa!.cidade ?? '';
      estadoController.text = empresa!.estado ?? '';
      cepController.text = empresa!.cep ?? '';

      latitudeController.text = empresa!.latitude?.toString() ?? '';

      longitudeController.text = empresa!.longitude?.toString() ?? '';

      servicoSelecionado = empresa!.servicoId;

      debugPrint("✏️ EDITANDO EMPRESA ID ${empresa!.id}");
    } else {
      debugPrint("🆕 NOVA EMPRESA");
    }
  }

  @override
  void dispose() {
    nomeController.dispose();
    descricaoController.dispose();
    telefoneController.dispose();
    emailController.dispose();
    enderecoController.dispose();
    cidadeController.dispose();
    estadoController.dispose();
    cepController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();

    super.dispose();
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
      debugPrint("❌ ERRO AO CARREGAR SERVIÇOS: $e");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Erro ao carregar serviços"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // =========================
  // MENSAGEM
  // =========================

  void msg(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto)),
    );
  }

  // =========================
  // SALVAR
  // =========================

  Future<void> salvar() async {
    FocusScope.of(context).unfocus();

    if (!formKey.currentState!.validate()) {
      return;
    }

    if (servicoSelecionado == null) {
      msg("Selecione um serviço");
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
        "email": emailController.text.trim(),
        "endereco": enderecoController.text.trim(),
        "cidade": cidadeController.text.trim(),
        "estado": estadoController.text.trim(),
        "cep": cepController.text.trim(),
        "latitude": latitudeController.text.trim().isEmpty
            ? null
            : double.tryParse(
                latitudeController.text.replaceAll(',', '.'),
              ),
        "longitude": longitudeController.text.trim().isEmpty
            ? null
            : double.tryParse(
                longitudeController.text.replaceAll(',', '.'),
              ),
        "servico_id": servicoSelecionado,
      };

      debugPrint("📤 ENVIANDO: $data");

      if (editando) {
        debugPrint("✏️ ATUALIZANDO EMPRESA ${empresa!.id}");

        await ApiService.updateEmpresa(
          empresa!.id,
          data,
        );
      } else {
        debugPrint("🆕 CRIANDO EMPRESA");

        await ApiService.createEmpresa(data);
      }

      if (!mounted) return;

      msg(
        editando
            ? "Empresa atualizada com sucesso"
            : "Empresa criada com sucesso",
      );

      Navigator.pop(context, true);
    } catch (e) {
      debugPrint("❌ ERRO AO SALVAR: $e");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro ao salvar empresa: $e"),
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
  // CAMPO PADRÃO
  // =========================

  Widget campo(
    TextEditingController controller,
    String label, {
    TextInputType? keyboard,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        validator: validator,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          editando ? "Editar Empresa" : "Nova Empresa",
        ),
      ),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              campo(
                nomeController,
                "Nome",
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Informe o nome";
                  }

                  return null;
                },
              ),
              campo(
                descricaoController,
                "Descrição",
                maxLines: 3,
              ),
              campo(
                telefoneController,
                "Telefone",
                keyboard: TextInputType.phone,
              ),
              campo(
                emailController,
                "Email",
                keyboard: TextInputType.emailAddress,
              ),
              campo(
                enderecoController,
                "Endereço",
              ),
              campo(
                cidadeController,
                "Cidade",
              ),
              campo(
                estadoController,
                "Estado",
              ),
              campo(
                cepController,
                "CEP",
                keyboard: TextInputType.number,
              ),
              campo(
                latitudeController,
                "Latitude",
                keyboard: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              campo(
                longitudeController,
                "Longitude",
                keyboard: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                value: servicos.any(
                  (s) => s.id == servicoSelecionado,
                )
                    ? servicoSelecionado
                    : null,
                decoration: InputDecoration(
                  labelText: "Serviço",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: servicos.map((s) {
                  return DropdownMenuItem<int>(
                    value: s.id,
                    child: Text(s.nome),
                  );
                }).toList(),
                onChanged: carregando
                    ? null
                    : (value) {
                        setState(() {
                          servicoSelecionado = value;
                        });
                      },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: carregando ? null : salvar,
                  child: carregando
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          editando ? "Atualizar Empresa" : "Criar Empresa",
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
