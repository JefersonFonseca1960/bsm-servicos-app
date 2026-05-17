class User {
  final int id;
  final String nome;
  final String email;
  final bool isAdmin;

  User({
    required this.id,
    required this.nome,
    required this.email,
    required this.isAdmin,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json["id"],
      nome: json["nome"] ?? "",
      email: json["email"] ?? "",
      isAdmin: json["is_admin"] ?? false,
    );
  }
}
