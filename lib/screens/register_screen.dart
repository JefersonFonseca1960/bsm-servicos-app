import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final senhaController = TextEditingController();

  bool loading = false;

  final baseUrl = "https://bsm-servicos-backend-1.onrender.com";

  Future<void> cadastrar() async {
    FocusScope.of(context).unfocus();

    if (nomeController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        senhaController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Preencha todos os campos"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      setState(() {
        loading = true;
      });

      final response = await http.post(
        Uri.parse("$baseUrl/usuarios/"), // 🔥 CORREÇÃO AQUI
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "nome": nomeController.text.trim(),
          "email": emailController.text.trim(),
          "senha": senhaController.text.trim(),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Conta criada com sucesso"),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context);
      } else {
        throw Exception("Erro ao cadastrar: ${response.body}");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    nomeController.dispose();
    emailController.dispose();
    senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Criar Conta")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Icon(Icons.person_add, size: 80, color: Colors.blue),
            const SizedBox(height: 20),
            TextField(
              controller: nomeController,
              decoration: const InputDecoration(
                labelText: "Nome",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: senhaController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Senha",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: loading ? null : cadastrar,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Criar Conta"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
