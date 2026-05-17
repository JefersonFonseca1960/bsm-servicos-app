import 'empresa_foto_model.dart';
import 'avaliacao_model.dart';

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

  final int? servicoId;

  final String? fotoPrincipal;

  final double? avaliacaoMedia;

  final List<EmpresaFoto> fotos;

  final List<Avaliacao> avaliacoes;

  const Empresa({
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
    this.ativo = true,
    this.servicoId,
    this.fotoPrincipal,
    this.avaliacaoMedia,
    this.fotos = const [],
    this.avaliacoes = const [],
  });

  factory Empresa.fromJson(
    Map<String, dynamic> json,
  ) {
    return Empresa(
      id: json['id'] ?? 0,
      nome: json['nome'] ?? '',
      descricao: json['descricao'],
      telefone: json['telefone'],
      whatsapp: json['whatsapp'],
      email: json['email'],
      endereco: json['endereco'],
      cidade: json['cidade'],
      bairro: json['bairro'],
      estado: json['estado'],
      cep: json['cep'],
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
      ativo: json['ativo'] ?? true,
      servicoId: json['servico_id'],
      fotoPrincipal: json['foto_principal'],
      avaliacaoMedia: _toDouble(json['avaliacao_media']),
      fotos: _parseFotos(json['fotos']),
      avaliacoes: (json['avaliacoes'] as List<dynamic>?)
              ?.map((a) => Avaliacao.fromJson(a))
              .toList() ??
          [],

      // avaliacoes: _parseAvaliacoes(json['avaliacoes']),
    );
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;

    if (value is double) return value;

    if (value is int) {
      return value.toDouble();
    }

    return double.tryParse(value.toString());
  }

  static List<EmpresaFoto> _parseFotos(dynamic fotosJson) {
    if (fotosJson is List) {
      return fotosJson.map((f) {
        // backend retorna string
        if (f is String) {
          return EmpresaFoto(
            id: 0,
            url: f,
            principal: false,
          );
        }

        // backend retorna objeto
        return EmpresaFoto.fromJson(f);
      }).toList();
    }

    return [];
  }

  static List<Avaliacao> _parseAvaliacoes(dynamic avaliacoesJson) {
    if (avaliacoesJson is List) {
      return avaliacoesJson.map((a) {
        return Avaliacao.fromJson(a);
      }).toList();
    }

    return [];
  }
}
