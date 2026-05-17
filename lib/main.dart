import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/users_screen.dart';
import 'screens/empresa_form_screen.dart';

import 'services/api_service.dart';
import 'models/empresa_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final isLogged = await ApiService.isLoggedIn();

  runApp(
    MyApp(isLogged: isLogged),
  );
}

class MyApp extends StatelessWidget {
  final bool isLogged;

  const MyApp({
    super.key,
    required this.isLogged,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'BSM Serviços',

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        useMaterial3: true,
      ),

      /// 🔥 DEFINE ROTA INICIAL
      initialRoute: isLogged ? "/home" : "/login",

      /// 🔥 ROTAS CENTRALIZADAS
      routes: {
        "/login": (context) => const LoginScreen(),

        "/home": (context) => const HomeScreen(),

        "/admin": (context) => const AdminDashboardScreen(),

        /// 👥 USUÁRIOS
        "/users": (context) => const UsersScreen(),

        /// 🏢 FORM EMPRESA
        "/empresa-form": (context) {
          final route = ModalRoute.of(context);

          final args = route?.settings.arguments;

          /// ✏️ EDITAR
          if (args is Empresa) {
            return EmpresaFormScreen(
              empresa: args,
            );
          }

          /// 🆕 NOVA EMPRESA
          return const EmpresaFormScreen();
        },
      },
    );
  }
}
