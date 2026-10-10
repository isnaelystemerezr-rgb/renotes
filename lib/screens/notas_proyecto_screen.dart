import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../models/nota.dart';
import '../models/etiqueta.dart';
import '../widgets/chip_etiqueta.dart';
import '../widgets/dialogo_confirmacion.dart';
import 'editor_nota_screen.dart';
import 'detalle_nota_screen.dart';

class NotasProyectoScreen extends StatefulWidget {
  final String proyectoId;
  const NotasProyectoScreen({super.key, required this.proyectoId});

  @override
  State<NotasProyectoScreen> createState() => _NotasProyectoScreenState();
}

class _NotasProyectoScreenState extends State<NotasProyectoScreen> {
  final _busquedaCtrl = TextEditingController();
  String _textoBusqueda = '';
  final Set<String> _etiquetasFiltro = {};

  @override
  void dispose() {
    _busquedaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final proyecto = state.buscarProyecto(widget.proyectoId);

    if (proyecto == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Proyecto no encontrado')),
      );
    }

    // Notas del proyecto
    var notas = state.notasDeProyecto(widget.proyectoId);

    // Etiquetas presentes en las notas del proyecto (para el filtro)
    final idsEtiquetasEnProyecto = <String>{};
    for (final n in notas) {
      idsEtiquetasEnProyecto.addAll(n.etiquetaIds);
    }
    final etiquetasDisponibles = state.etiquetas
        .where((e) => idsEtiquetasEnProyecto.contains(e.id))
        .toList()
      ..sort((a, b) => a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase()));

    // Filtro por etiquetas
    if (_etiquetasFiltro.isNotEmpty) {
      notas = notas.where((n) {
        return _etiquetasFiltro.every((id) => n.etiquetaIds.contains(id));
      }).toList();
    }

    // Filtro por texto
    if (_textoBusqueda.trim().isNotEmpty) {
      final t = _textoBusqueda.toLowerCase();
      notas = notas.where((n) {
        return n.titulo.toLowerCase().contains(t) ||
            n.descripcion.toLowerCase().contains(t);
      }).toList();
    }

    // Ordenar por fecha de modificación
    notas.sort((a, b) => b.fechaModificacion.compareTo(a.fechaModificacion));

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              proyecto.nombre,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '${state.notasDeProyecto(widget.proyectoId).length} notas',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // === Buscador ===
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: TextField(
              controller: _busquedaCtrl,
              onChanged: (v) => setState(() => _textoBusqueda = v),
              decoration: InputDecoration(
                hintText: 'Buscar por título o contenido...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _textoBusqueda.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _busquedaCtrl.clear();
                          setState(() => _textoBusqueda = '');
                        },
                      ),
              ),
            ),
          ),

          // === Filtro de etiquetas ===
          if (etiquetasDisponibles.isNotEmpty)
            SizedBox(
              height: 42,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: etiquetasDisponibles.length,
                itemBuilder: (context, i) {
                  final et = etiquetasDisponibles[i];
                  final activa = _etiquetasFiltro.contains(et.id);
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: FilterChip(
                      label: Text(et.nombre),
                      selected: activa,
                      onSelected: (sel) {
                        setState(() {
                          if (sel) {
                            _etiquetasFiltro.add(et.id);
                          } else {
                            _etiquetasFiltro.remove(et.id);
                          }
                        });
                      },
                      selectedColor: Colors.indigo.shade100,
                      checkmarkColor: Colors.indigo.shade700,
                    ),
                  );
                },
              ),
            ),

          // === Lista de notas ===
          Expanded(
            child: notas.isEmpty
                ? _EstadoVacio(
                    hayFiltros: _etiquetasFiltro.isNotEmpty ||
                        _textoBusqueda.trim().isNotEmpty,
                    hayNotas: state.notasDeProyecto(widget.proyectoId).isNotEmpty,
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 100),
                    itemCount: notas.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      return _TarjetaNota(nota: notas[i]);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EditorNotaScreen(
                proyectoId: widget.proyectoId,
                notaId: null,
              ),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Nueva nota'),
      ),
    );
  }
}

// ================== ESTADO VACÍO ==================
class _EstadoVacio extends StatelessWidget {
  final bool hayFiltros;
  final bool hayNotas;

  const _EstadoVacio({required this.hayFiltros, required this.hayNotas});

  @override
  Widget build(BuildContext context) {
    String texto;
    IconData icono;

    if (!hayNotas) {
      texto = 'Este proyecto todavía no tiene notas.\nToca "Nueva nota" para crear la primera.';
      icono = Icons.note_add_outlined;
    } else if (hayFiltros) {
      texto = 'No hay notas que coincidan con los filtros aplicados.';
      icono = Icons.filter_alt_off_outlined;
    } else {
      texto = 'No hay notas para mostrar.';
      icono = Icons.description_outlined;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icono, size: 72, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              texto,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

// ================== TARJETA DE NOTA ==================
class _TarjetaNota extends StatelessWidget {
  final Nota nota;
  const _TarjetaNota({required this.nota});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);

    // Extraer las etiquetas de la nota
    final etiquetas = nota.etiquetaIds
        .map((id) => state.buscarEtiqueta(id))
        .whereType<Etiqueta>()
        .toList();

    // Extracto de la descripción
    final extracto = nota.descripcion.length > 140
        ? '${nota.descripcion.substring(0, 140)}...'
        : nota.descripcion;

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetalleNotaScreen(notaId: nota.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      nota.titulo,
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 20),
                    onSelected: (v) async {
                      if (v == 'editar') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditorNotaScreen(
                              proyectoId: nota.proyectoId,
                              notaId: nota.id,
                            ),
                          ),
                        );
                      } else if (v == 'eliminar') {
                        final ok = await mostrarConfirmacion(
                          context,
                          titulo: 'Eliminar nota',
                          mensaje:
                              '¿Seguro que quieres eliminar "${nota.titulo}"?',
                        );
                        if (ok) {
                          state.eliminarNota(nota.id);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Nota eliminada')),
                            );
                          }
                        }
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: 'editar',
                        child: ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.edit_outlined),
                          title: Text('Editar'),
                        ),
                      ),
                      PopupMenuItem(
                        value: 'eliminar',
                        child: ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading:
                              Icon(Icons.delete_outline, color: Colors.red),
                          title: Text(
                            'Eliminar',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (extracto.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  extracto,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
              ],
              if (etiquetas.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  children: etiquetas
                      .map((e) => ChipEtiqueta(etiqueta: e))
                      .toList(),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.access_time,
                      size: 13, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(
                    _formatearFecha(nota.fechaModificacion),
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================== HELPERS ==================
String _formatearFecha(DateTime fecha) {
  final ahora = DateTime.now();
  final dif = ahora.difference(fecha);

  if (dif.inMinutes < 1) return 'ahora mismo';
  if (dif.inHours < 1) return 'hace ${dif.inMinutes} min';
  if (dif.inDays < 1) return 'hace ${dif.inHours} h';
  if (dif.inDays < 7) return 'hace ${dif.inDays} d';

  const meses = [
    'ene', 'feb', 'mar', 'abr', 'may', 'jun',
    'jul', 'ago', 'sep', 'oct', 'nov', 'dic'
  ];
  return '${fecha.day} ${meses[fecha.month - 1]} ${fecha.year}';
}