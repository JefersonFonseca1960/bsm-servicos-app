class Avaliacao {
  final int id;

  final int nota;

  final String? comentario;

  final String? usuarioNome;

  final String? dataCriacao;

  const Avaliacao({
    required this.id,
    required this.nota,
    this.comentario,
    this.usuarioNome,
    this.dataCriacao,
  });

  factory Avaliacao.fromJson(Map<String, dynamic> json) {
    return Avaliacao(
      id: json['id'] ?? 0,

      nota: json['nota'] ?? 0,

      comentario: json['comentario'],

      // aceita os 2 formatos
      usuarioNome: json['usuario_nome'] ?? json['usuario'],

      // aceita os 2 formatos
      dataCriacao: json['created_at'] ?? json['data_criacao'],
    );
  }
}
