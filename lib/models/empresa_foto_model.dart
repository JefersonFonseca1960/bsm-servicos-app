class EmpresaFoto {
  final int id;
  final String url;
  final bool principal;

  EmpresaFoto({
    required this.id,
    required this.url,
    this.principal = false,
  });

  factory EmpresaFoto.fromJson(
    Map<String, dynamic> json,
  ) {
    return EmpresaFoto(
      id: json['id'] ?? 0,
      url: json['url'] ?? '',
      principal: json['principal'] ?? false,
    );
  }
}
