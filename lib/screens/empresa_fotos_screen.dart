import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import '../services/api_service.dart';

class EmpresaFotosScreen extends StatefulWidget {
  final int empresaId;
  final bool isAdmin;

  const EmpresaFotosScreen({
    super.key,
    required this.empresaId,
    required this.isAdmin,
  });

  @override
  State<EmpresaFotosScreen> createState() => _EmpresaFotosScreenState();
}

class _EmpresaFotosScreenState extends State<EmpresaFotosScreen> {
  final ImagePicker picker = ImagePicker();

  final List<XFile> _fotos = [];

  bool _loading = false;

  // =========================
  // SELECIONAR + UPLOAD
  // =========================
  Future<void> _selecionarImagem() async {
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image == null) return;

      setState(() {
        _loading = true;
      });

      debugPrint("IMAGEM => ${image.path}");

      // 🔥 UPLOAD API
      final ok = await ApiService.uploadFotoEmpresa(
        empresaId: widget.empresaId,
        imagem: image,
      );

      if (ok) {
        setState(() {
          _fotos.add(image);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Foto enviada com sucesso")),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Erro ao enviar foto")));
        }
      }
    } catch (e) {
      debugPrint("ERRO FOTO => $e");

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Erro: $e")));
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  // =========================
  // REMOVER
  // =========================
  void _removerFoto(int index) {
    setState(() {
      _fotos.removeAt(index);
    });
  }

  // =========================
  // BUILD WEB
  // =========================
  Widget _buildWebImage(XFile foto) {
    return FutureBuilder<Uint8List>(
      future: foto.readAsBytes(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
            color: Colors.grey[300],
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        return Image.memory(
          snapshot.data!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        );
      },
    );
  }

  // =========================
  // BUILD IMAGE
  // =========================
  Widget _buildImage(XFile foto) {
    if (kIsWeb) {
      return _buildWebImage(foto);
    }

    return Image.file(
      File(foto.path),
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
    );
  }

  // =========================
  // UI
  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F7FB),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blue,
        title: const Text(
          "Fotos da Empresa",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),

      floatingActionButton: widget.isAdmin
          ? FloatingActionButton.extended(
              backgroundColor: Colors.blue,
              onPressed: _loading ? null : _selecionarImagem,
              icon: const Icon(Icons.add_a_photo),
              label: const Text("Adicionar"),
            )
          : null,

      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _fotos.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.photo_library_outlined,
                    size: 90,
                    color: Colors.grey[400],
                  ),

                  const SizedBox(height: 20),

                  Text(
                    "Nenhuma foto cadastrada",
                    style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(14),
              itemCount: _fotos.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                final foto = _fotos[index];

                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: _buildImage(foto),
                      ),

                      if (widget.isAdmin)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () => _removerFoto(index),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
