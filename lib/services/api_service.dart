import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/empresa_model.dart';
import '../models/servico.dart';

class ApiService {
  static const String baseUrl = "https://bsm-servicos-backend.onrender.com";

  static const String _tokenKey = "token";
  static const String _userTypeKey = "tipo_usuario";

  // =========================
  // TOKEN
  // =========================

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // =========================
  // USER TYPE
  // =========================

  static Future<void> saveUserType(String tipo) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userTypeKey, tipo);
  }

  static Future<String?> getUserType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userTypeKey);
  }

  // =========================
  // LOGOUT
  // =========================

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // =========================
  // HEADERS
  // =========================

  static Future<Map<String, String>> _headers() async {
    final token = await getToken();

    return {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  // =========================
  // LOGIN
  // =========================

  static Future<Map<String, dynamic>> login(
    String username,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/login"),
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: {"username": username.trim(), "password": password.trim()},
    );

    debugPrint("🔐 LOGIN STATUS: ${response.statusCode}");
    debugPrint("🔐 LOGIN BODY: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final token = data["access_token"];

      final tipo = (data["tipo_usuario"] ?? "usuario").toString().toLowerCase();

      await saveToken(token);
      await saveUserType(tipo);

      return data;
    }

    throw Exception("Erro no login");
  }

  // =========================
  // EMPRESAS
  // =========================

  static Future<List<Empresa>> getEmpresas() async {
    final response = await http.get(
      Uri.parse("$baseUrl/empresa/"),
      headers: await _headers(),
    );

    debugPrint("📡 EMPRESAS STATUS: ${response.statusCode}");
    debugPrint("📡 EMPRESAS BODY: ${response.body}");

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      return data.map((e) => Empresa.fromJson(e)).toList();
    }

    throw Exception("Erro ao buscar empresas");
  }

  // =========================
  // DETALHE EMPRESA
  // =========================

  static Future<Map<String, dynamic>> getEmpresa(int id) async {
    final response = await http.get(
      Uri.parse("$baseUrl/empresa/$id"),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception("Erro ao carregar empresa");
  }

  // =========================
  // SERVIÇOS
  // =========================

  static Future<List<Servico>> getServicos() async {
    final response = await http.get(
      Uri.parse("$baseUrl/servicos/"),
      headers: await _headers(),
    );

    debugPrint("📡 SERVIÇOS STATUS: ${response.statusCode}");
    debugPrint("📡 SERVIÇOS BODY: ${response.body}");

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      return data.map((e) => Servico.fromJson(e)).toList();
    }

    throw Exception("Erro ao buscar serviços");
  }

  // =========================
  // CREATE EMPRESA
  // =========================

  static Future<void> createEmpresa(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse("$baseUrl/empresa/"),
      headers: await _headers(),
      body: jsonEncode(data),
    );

    debugPrint("🏢 CREATE EMPRESA STATUS: ${response.statusCode}");
    debugPrint(response.body);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Erro ao criar empresa");
    }
  }

  // =========================
  // UPDATE EMPRESA
  // =========================

  static Future<void> updateEmpresa(int id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse("$baseUrl/empresa/$id"),
      headers: await _headers(),
      body: jsonEncode(data),
    );

    debugPrint("✏️ UPDATE EMPRESA STATUS: ${response.statusCode}");
    debugPrint(response.body);

    if (response.statusCode != 200) {
      throw Exception("Erro ao atualizar empresa");
    }
  }

  // =========================
  // UPLOAD FOTO EMPRESA
  // =========================

  static Future<bool> uploadFotoEmpresa({
    required int empresaId,
    required XFile imagem,
  }) async {
    try {
      final token = await getToken();

      final request = http.MultipartRequest(
        "POST",
        Uri.parse("$baseUrl/empresa/$empresaId/fotos"),
      );

      request.headers["Authorization"] = "Bearer $token";

      // WEB
      if (kIsWeb) {
        final bytes = await imagem.readAsBytes();

        request.files.add(
          http.MultipartFile.fromBytes("file", bytes, filename: imagem.name),
        );
      }
      // MOBILE
      else {
        request.files.add(
          await http.MultipartFile.fromPath("file", imagem.path),
        );
      }

      final response = await request.send();

      final body = await response.stream.bytesToString();

      debugPrint("📸 UPLOAD FOTO STATUS: ${response.statusCode}");
      debugPrint("📸 UPLOAD FOTO BODY: $body");

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint("❌ ERRO UPLOAD FOTO: $e");
      return false;
    }
  }

  // =========================
  // USUÁRIOS
  // =========================

  static Future<List<dynamic>> getUsuarios() async {
    final response = await http.get(
      Uri.parse("$baseUrl/usuarios/"),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception("Erro ao buscar usuários");
  }

  // =========================
  // UPDATE USUÁRIO
  // =========================

  static Future<void> updateUsuario(int id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse("$baseUrl/usuarios/$id"),
      headers: await _headers(),
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      throw Exception("Erro ao atualizar usuário");
    }
  }

  // =========================
  // DELETE USUÁRIO
  // =========================

  static Future<void> deleteUsuario(int id) async {
    final response = await http.delete(
      Uri.parse("$baseUrl/usuarios/$id"),
      headers: await _headers(),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception("Erro ao deletar usuário");
    }
  }
}
