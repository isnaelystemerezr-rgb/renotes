import 'package:flutter/material.dart';
import '../models/etiqueta.dart';

class ChipEtiqueta extends StatelessWidget {
  final Etiqueta etiqueta;
  final VoidCallback? onDeleted;
  final VoidCallback? onTap;
  final bool seleccionada;

  const ChipEtiqueta({
    super.key,
    required this.etiqueta,
    this.onDeleted,
    this.onTap,
    this.seleccionada = false,
  });

  /// Genera un color estable a partir del nombre de la etiqueta
  Color _colorFondo() {
    final hash = etiqueta.nombre.hashCode;
    final colores = [
      const Color(0xFFE3F2FD), // azul claro
      const Color(0xFFF3E5F5), // lila
      const Color(0xFFE8F5E9), // verde claro
      const Color(0xFFFFF3E0), // naranja claro
      const Color(0xFFFCE4EC), // rosa claro
      const Color(0xFFE0F7FA), // cian claro
      const Color(0xFFFFF9C4), // amarillo claro
      const Color(0xFFEDE7F6), // violeta claro
    ];
    return colores[hash.abs() % colores.length];
  }

  Color _colorTexto() {
    final fondo = _colorFondo();
    return Color.lerp(fondo, Colors.black, 0.6)!;
  }

  @override
  Widget build(BuildContext context) {
    final fondo = seleccionada ? Colors.indigo.shade700 : _colorFondo();
    final texto = seleccionada ? Colors.white : _colorTexto();

    return Padding(
      padding: const EdgeInsets.only(right: 6, bottom: 6),
      child: Material(
        color: fondo,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.local_offer, size: 14, color: texto),
                const SizedBox(width: 4),
                Text(
                  etiqueta.nombre,
                  style: TextStyle(
                    color: texto,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (onDeleted != null) ...[
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: onDeleted,
                    child: Icon(Icons.close, size: 16, color: texto),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}