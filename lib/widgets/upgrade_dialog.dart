import 'package:flutter/material.dart';

void mostrarDialogUpgrade(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Funcionalidade Premium"),
      content: const Text(
        "Este recurso está disponível apenas nos planos Premium e Master.",
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Agora não"),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, "/planos");
          },
          child: const Text("Ver planos"),
        ),
      ],
    ),
  );
}
