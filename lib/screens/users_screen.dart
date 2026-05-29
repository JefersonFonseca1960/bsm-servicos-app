import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'register_screen.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  List<dynamic> usuarios = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    carregarUsuarios();
  }

  Future<void> carregarUsuarios() async {
    try {
      final data = await ApiService.getUsuarios();

      setState(() {
        usuarios = data;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erro: $e")));
    }
  }

  /// 🔥 Nome inteligente
  String getNomeUsuario(dynamic user) {
    if (user["nome"] != null && user["nome"].toString().isNotEmpty) {
      return user["nome"];
    }

    if (user["email"] != null) {
      return user["email"];
    }

    return "Usuário #${user["id"]}";
  }

  /// 🔥 Tipo seguro
  String getTipoUsuario(dynamic user) {
    return user["tipo_usuario"] ?? "usuario";
  }

  /// ✏️ EDITAR USUÁRIO (COMPLETO)
  void editarUsuario(dynamic user) {
    final nomeController = TextEditingController(text: user["nome"] ?? "");

    final emailController = TextEditingController(text: user["email"] ?? "");

    String tipo = getTipoUsuario(user);

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Editar usuário"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// 👤 NOME
                TextField(
                  controller: nomeController,
                  decoration: const InputDecoration(labelText: "Nome"),
                ),

                const SizedBox(height: 12),

                /// 📧 EMAIL
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: "Email"),
                ),

                const SizedBox(height: 12),

                /// 🔐 TIPO
                DropdownButtonFormField<String>(
                  value: tipo,
                  decoration: const InputDecoration(
                    labelText: "Tipo de usuário",
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: "admin",
                      child: Text("Administrador"),
                    ),
                    DropdownMenuItem(value: "usuario", child: Text("Usuário")),
                  ],
                  onChanged: (value) {
                    tipo = value!;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await ApiService.updateUsuario(user["id"], {
                    "nome": nomeController.text,
                    "email": emailController.text,
                    "tipo_usuario": tipo,
                  });

                  Navigator.pop(context);
                  carregarUsuarios();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Usuário atualizado com sucesso"),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("Erro: $e")));
                }
              },
              child: const Text("Salvar"),
            ),
          ],
        );
      },
    );
  }

  /// 🗑️ EXCLUIR
  void excluirUsuario(int id) async {
    try {
      await ApiService.deleteUsuario(id);

      carregarUsuarios();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Usuário removido")));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erro: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Gerenciar Usuários")),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        child: const Icon(Icons.person_add, color: Colors.white),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => RegisterScreen()),
          );

          carregarUsuarios();
        },
      ),

      body: RefreshIndicator(
        onRefresh: carregarUsuarios,
        child: ListView.builder(
          itemCount: usuarios.length,
          itemBuilder: (context, index) {
            final user = usuarios[index];

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                leading: CircleAvatar(
                  child: Text(getNomeUsuario(user)[0].toUpperCase()),
                ),

                /// 👤 NOME
                title: Text(getNomeUsuario(user)),

                /// 🔐 TIPO (CORRIGIDO)
                subtitle: Text("Tipo: ${getTipoUsuario(user)}"),

                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /// ✏️ EDITAR
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => editarUsuario(user),
                    ),

                    /// 🗑️ EXCLUIR
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => excluirUsuario(user["id"]),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
