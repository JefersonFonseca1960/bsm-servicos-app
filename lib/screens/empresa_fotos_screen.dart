import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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

  Future<void> _selecionarImagem() async {
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image == null) return;

      setState(() {
        _fotos.add(image);
      });

      debugPrint("IMAGEM => ${image.path}");
    } catch (e) {
      debugPrint("ERRO AO SELECIONAR IMAGEM: $e");
    }
  }

  void _removerFoto(int index) {
    setState(() {
      _fotos.removeAt(index);
    });
  }

  Widget _buildImage(XFile foto) {
    // 🔥 WEB
    if (kIsWeb) {
      return Image.network(
        foto.path,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
      );
    }

    // 📱 MOBILE / DESKTOP
    return Image.file(
      File(foto.path),
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Fotos da Empresa")),
      body: Column(
        children: [
          if (widget.isAdmin)
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _selecionarImagem,
                  icon: const Icon(Icons.add_a_photo),
                  label: const Text("Adicionar Foto"),
                ),
              ),
            ),

          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _fotos.isEmpty
                ? Center(
                    child: Text(
                      "Nenhuma foto cadastrada\nEmpresa ID: ${widget.empresaId}",
                      textAlign: TextAlign.center,
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _fotos.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                    itemBuilder: (context, index) {
                      final foto = _fotos[index];

                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: _buildImage(foto),
                          ),

                          if (widget.isAdmin)
                            Positioned(
                              top: 6,
                              right: 6,
                              child: GestureDetector(
                                onTap: () => _removerFoto(index),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(100),
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
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
