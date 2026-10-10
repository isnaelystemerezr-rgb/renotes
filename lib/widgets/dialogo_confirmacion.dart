import 'package:flutter/material.dart';

/// Muestra un diálogo de confirmación.
/// Retorna true si el usuario confirma, false/null si cancela.
Future<bool> mostrarConfirmacion(
  BuildContext context, {
  required String titulo,
  required String mensaje,
  String textoConfirmar = 'Eliminar',
  String textoCancelar = 'Cancelar',
  Color? colorConfirmar,
}) async {
  final resultado = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(titulo),
      content: Text(mensaje),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(textoCancelar),
        ),
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          style: FilledButton.styleFrom(
            backgroundColor: colorConfirmar ?? Colors.red.shade600,
          ),
          child: Text(textoConfirmar),
        ),
      ],
    ),
  );
  return resultado ?? false;
}