import 'empresa_foto_model.dart';

class Empresa {
  final int id;

  final String nome;

  final String? descricao;
  final String? telefone;
  final String? whatsapp;
  final String? email;

  final String? endereco;
  final String? cidade;
  final String? bairro;
  final String? estado;
  final String? cep;

  final double? latitude;
  final double? longitude;

  final bool ativo;

  final double? avaliacaoMedia;

  final int? servicoId;

  final String? fotoPrincipal;

  final List<EmpresaFoto> fotos;

  final double? distanciaKm;

  // =========================
  // PREMIUM
  // =========================

  final bool destaque;

  final String plano;

  final int prioridade;

  final bool whatsappDestacado;

  final bool exibirNoTopo;

  final bool seloPremium;

  final Map<String, dynamic>? permissoes;

  Empresa({
    required this.id,
    required this.nome,
    this.descricao,
    this.telefone,
    this.whatsapp,
    this.email,
    this.endereco,
    this.cidade,
    this.bairro,
    this.estado,
    this.cep,
    this.latitude,
    this.longitude,
    required this.ativo,
    this.avaliacaoMedia,
    this.servicoId,
    this.fotoPrincipal,
    this.fotos = const [],
    this.distanciaKm,

    // PREMIUM
    this.destaque = false,
    this.plano = 'gratuito',
    this.prioridade = 0,
    this.whatsappDestacado = false,
    this.exibirNoTopo = false,
    this.seloPremium = false,
    this.permissoes,
  });

  factory Empresa.fromJson(Map<String, dynamic> json) {
    return Empresa(
      id: _toInt(json['id']) ?? 0,

      nome: json['nome']?.toString() ?? '',

      descricao: json['descricao']?.toString(),
      telefone: json['telefone']?.toString(),
      whatsapp: json['whatsapp']?.toString(),
      email: json['email']?.toString(),

      endereco: json['endereco']?.toString(),
      cidade: json['cidade']?.toString(),
      bairro: json['bairro']?.toString(),
      estado: json['estado']?.toString(),
      cep: json['cep']?.toString(),

      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),

      ativo: _toBool(json['ativo']),

      avaliacaoMedia: _toDouble(json['avaliacao_media']),

      servicoId: _toInt(json['servico_id']),

      fotoPrincipal: json['foto_principal']?.toString(),

      fotos: json['fotos'] is List
          ? (json['fotos'] as List).map((e) => EmpresaFoto.fromJson(e)).toList()
          : [],

      distanciaKm: _toDouble(json['distancia_km']),

      // =========================
      // PREMIUM
      // =========================
      destaque: _toBool(json['destaque']),

      plano: json['plano']?.toString() ?? 'gratuito',

      prioridade: _toInt(json['prioridade']) ?? 0,

      whatsappDestacado: _toBool(json['whatsapp_destacado']),

      exibirNoTopo: _toBool(json['exibir_no_topo']),

      seloPremium: _toBool(json['selo_premium']),

      permissoes: json["permissoes"] ?? {"galeria": false},
    );
  }

  // =========================
  // HELPERS
  // =========================

  static int? _toInt(dynamic value) {
    if (value == null) return null;

    if (value is int) return value;

    return int.tryParse(value.toString());
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;

    if (value is double) return value;

    if (value is int) return value.toDouble();

    return double.tryParse(value.toString().replaceAll(',', '.'));
  }

  static bool _toBool(dynamic value) {
    if (value == null) return false;

    if (value is bool) return value;

    if (value is int) return value == 1;

    final str = value.toString().toLowerCase();

    return str == 'true' || str == '1';
  }
}
