import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../models/etiqueta.dart';
import '../widgets/chip_etiqueta.dart';
import '../widgets/dialogo_confirmacion.dart';
import 'editor_nota_screen.dart';
import 'etiquetas_screen.dart';

class DetalleNotaScreen extends StatelessWidget {
  final String notaId;
  const DetalleNotaScreen({super.key, required this.notaId});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final nota = state.buscarNota(notaId);

    if (nota == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Nota no encontrada')),
      );
    }

    final proyecto = state.buscarProyecto(nota.proyectoId);
    final etiquetas = nota.etiquetaIds
        .map((id) => state.buscarEtiqueta(id))
        .whereType<Etiqueta>()
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de nota'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Editar',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditorNotaScreen(
                    proyectoId: nota.proyectoId,
                    notaId: nota.id,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Eliminar',
            onPressed: () async {
              final ok = await mostrarConfirmacion(
                context,
                titulo: 'Eliminar nota',
                mensaje: '¿Seguro que quieres eliminar "${nota.titulo}"?',
              );
              if (ok) {
                state.eliminarNota(nota.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Nota eliminada')),
                  );
                  Navigator.pop(context);
                }
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            // === TÍTULO ===
            Text(
              nota.titulo,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),

            const SizedBox(height: 12),

            // === PROYECTO ===
            if (proyecto != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.folder_outlined,
                      size: 16,
                      color: Colors.indigo.shade700,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        proyecto.nombre,
                        style: TextStyle(
                          color: Colors.indigo.shade900,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 12),

            // === FECHAS ===
            Row(
              children: [
                Icon(Icons.event_outlined,
                    size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  'Creada: ${_formatearFechaCompleta(nota.fechaCreacion)}',
                  style:
                      TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.update, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  'Modificada: ${_formatearFechaCompleta(nota.fechaModificacion)}',
                  style:
                      TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),

            // === ETIQUETAS ===
            if (etiquetas.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Row(
                children: [
                  Icon(Icons.local_offer_outlined, size: 16),
                  SizedBox(width: 6),
                  Text(
                    'Etiquetas',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                children: etiquetas
                    .map(
                      (e) => ChipEtiqueta(
                        etiqueta: e,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  EtiquetasScreen(etiquetaInicialId: e.id),
                            ),
                          );
                        },
                      ),
                    )
                    .toList(),
              ),
            ],

            const SizedBox(height: 24),

            // === DESCRIPCIÓN ===
            const Row(
              children: [
                Icon(Icons.subject, size: 16),
                SizedBox(width: 6),
                Text(
                  'Contenido',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: nota.descripcion.isEmpty
                  ? Text(
                      'Esta nota no tiene contenido.',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontStyle: FontStyle.italic,
                      ),
                    )
                  : SelectableText(
                      nota.descripcion,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: Colors.black87,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================== HELPERS ==================
String _formatearFechaCompleta(DateTime fecha) {
  const meses = [
    'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
    'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
  ];
  final h = fecha.hour.toString().padLeft(2, '0');
  final m = fecha.minute.toString().padLeft(2, '0');
  return '${fecha.day} de ${meses[fecha.month - 1]} de ${fecha.year}, $h:$m';
}