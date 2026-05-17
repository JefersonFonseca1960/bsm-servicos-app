import 'package:flutter/material.dart';

import '../services/api_service.dart';

import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  bool loading = false;

  bool obscurePassword = true;

  // =========================
  // LOGIN
  // =========================
  Future<void> login() async {
    FocusScope.of(context).unfocus();

    final email = emailController.text.trim();

    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showMessage(
        "Preencha email e senha",
      );

      return;
    }

    setState(() {
      loading = true;
    });

    try {
      // =========================
      // LOGIN API
      // =========================
      final response = await ApiService.login(
        email,
        password,
      );

      final tipo = await ApiService.getUserType();

      debugPrint(
        "🧠 TIPO SALVO NO APP: [$tipo]",
      );

      debugPrint(
        "✅ LOGIN OK: $response",
      );

      if (!mounted) return;

      // =========================
      // NAVEGAÇÃO
      // =========================
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        _parseError(e),
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  // =========================
  // TRATAMENTO ERROS
  // =========================
  String _parseError(dynamic e) {
    final msg = e.toString().toLowerCase();

    if (msg.contains("inválido") || msg.contains("401")) {
      return "Email ou senha inválidos";
    }

    if (msg.contains("socket") ||
        msg.contains(
          "failed host lookup",
        ) ||
        msg.contains("network")) {
      return "Sem conexão com o servidor";
    }

    return "Erro ao fazer login";
  }

  // =========================
  // MENSAGENS
  // =========================
  void _showMessage(
    String msg, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();

    passwordController.dispose();

    super.dispose();
  }

  // =========================
  // UI
  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScope.of(
            context,
          ).unfocus();
        },
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 450,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // =========================
                  // LOGO
                  // =========================
                  const Icon(
                    Icons.business,
                    size: 90,
                    color: Colors.blue,
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  const Text(
                    "BSM Serviços",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 40,
                  ),

                  // =========================
                  // EMAIL
                  // =========================
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [
                      AutofillHints.username,
                    ],
                    decoration: InputDecoration(
                      labelText: "Email",
                      prefixIcon: const Icon(
                        Icons.email,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          12,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 18,
                  ),

                  // =========================
                  // SENHA
                  // =========================
                  TextField(
                    controller: passwordController,
                    obscureText: obscurePassword,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [
                      AutofillHints.password,
                    ],
                    onSubmitted: (_) {
                      login();
                    },
                    decoration: InputDecoration(
                      labelText: "Senha",
                      prefixIcon: const Icon(
                        Icons.lock,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          12,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 28,
                  ),

                  // =========================
                  // BOTÃO LOGIN
                  // =========================
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: loading ? null : login,
                      child: loading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              "Entrar",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(
                    height: 18,
                  ),

                  // =========================
                  // NOVO USUÁRIO
                  // =========================
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterScreen(),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.person_add,
                    ),
                    label: const Text(
                      "Criar novo usuário",
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  // =========================
                  // RECUPERAR SENHA
                  // =========================
                  TextButton(
                    onPressed: () {
                      _showMessage(
                        "Funcionalidade em breve",
                      );
                    },
                    child: const Text(
                      "Esqueci minha senha",
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
