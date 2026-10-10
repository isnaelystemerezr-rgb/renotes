import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../models/etiqueta.dart';
import '../widgets/dialogo_confirmacion.dart';
import 'detalle_nota_screen.dart';

class EtiquetasScreen extends StatefulWidget {
  /// Si se especifica, arranca mostrando las notas de esa etiqueta.
  final String? etiquetaInicialId;

  const EtiquetasScreen({super.key, this.etiquetaInicialId});

  @override
  State<EtiquetasScreen> createState() => _EtiquetasScreenState();
}

class _EtiquetasScreenState extends State<EtiquetasScreen> {
  final _busquedaCtrl = TextEditingController();
  String _textoBusqueda = '';

  /// Etiquetas seleccionadas para agrupar notas
  final Set<String> _seleccionadas = {};

  /// Modo de agrupación: true = todas, false = al menos una
  bool _modoTodas = true;

  @override
  void initState() {
    super.initState();
    if (widget.etiquetaInicialId != null) {
      _seleccionadas.add(widget.etiquetaInicialId!);
    }
  }

  @override
  void dispose() {
    _busquedaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);

    // ===== Etiquetas filtradas por búsqueda =====
    var etiquetas = List<Etiqueta>.from(state.etiquetas);
    if (_textoBusqueda.trim().isNotEmpty) {
      final t = _textoBusqueda.toLowerCase();
      etiquetas = etiquetas.where((e) {
        return e.nombre.toLowerCase().contains(t);
      }).toList();
    }
    etiquetas.sort((a, b) =>
        a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase()));

    // ===== Notas agrupadas (si hay selección) =====
  
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Etiquetas',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // ===== Buscador =====
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: TextField(
              controller: _busquedaCtrl,
              onChanged: (v) => setState(() => _textoBusqueda = v),
              decoration: InputDecoration(
                hintText: 'Buscar etiquetas...',
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

          // ===== Panel de agrupación (si hay seleccionadas) =====
          if (_seleccionadas.isNotEmpty) _panelAgrupacion(),

          // ===== Lista de etiquetas =====
          Expanded(
            child: etiquetas.isEmpty
                ? _EstadoVacio(hayBusqueda: _textoBusqueda.trim().isNotEmpty)
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 100),
                    itemCount: etiquetas.length,
                    itemBuilder: (context, i) {
                      return _ItemEtiqueta(
                        etiqueta: etiquetas[i],
                        seleccionada:
                            _seleccionadas.contains(etiquetas[i].id),
                        onToggle: () {
                          setState(() {
                            if (_seleccionadas
                                .contains(etiquetas[i].id)) {
                              _seleccionadas.remove(etiquetas[i].id);
                            } else {
                              _seleccionadas.add(etiquetas[i].id);
                            }
                          });
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _mostrarEditorEtiqueta(context, null),
        icon: const Icon(Icons.add),
        label: const Text('Nueva etiqueta'),
      ),
    );
  }

  // ===== PANEL DE AGRUPACIÓN =====
  Widget _panelAgrupacion() {
    final state = AppStateScope.of(context);

    // Contar notas según el modo
    final cantidad = _modoTodas
        ? state.notasConTodasLasEtiquetas(_seleccionadas.toList()).length
        : state.notasConAlgunaEtiqueta(_seleccionadas.toList()).length;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.indigo.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.filter_alt,
                  size: 18, color: Colors.indigo.shade700),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${_seleccionadas.length} etiqueta(s) seleccionada(s) - $cantidad nota(s)',
                  style: TextStyle(
                    color: Colors.indigo.shade900,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                padding: const EdgeInsets.all(0),
                constraints: const BoxConstraints(),
                onPressed: () {
                  setState(() => _seleccionadas.clear());
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              ChoiceChip(
                label: const Text('Todas'),
                selected: _modoTodas,
                onSelected: (_) => setState(() => _modoTodas = true),
              ),
              const SizedBox(width: 6),
              ChoiceChip(
                label: const Text('Al menos una'),
                selected: !_modoTodas,
                onSelected: (_) => setState(() => _modoTodas = false),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Mostrar notas agrupadas
          if (cantidad == 0)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No hay notas que coincidan con esta agrupación.',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 13,
                ),
              ),
            )
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 240),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: cantidad,
                itemBuilder: (context, i) {
                  final notas = _modoTodas
                      ? state.notasConTodasLasEtiquetas(_seleccionadas.toList())
                      : state.notasConAlgunaEtiqueta(_seleccionadas.toList());
                  final nota = notas[i];
                  final proyecto = state.buscarProyecto(nota.proyectoId);
                  return Card(
                    margin: const EdgeInsets.only(bottom: 6),
                    child: ListTile(
                      dense: true,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 10),
                      leading: const Icon(Icons.description_outlined,
                          size: 20),
                      title: Text(
                        nota.titulo,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: proyecto != null
                          ? Text(
                              proyecto.nombre,
                              style: TextStyle(
                                fontSize: 11.5,
                                color: Colors.grey.shade600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )
                          : null,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                DetalleNotaScreen(notaId: nota.id),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

// ================== ESTADO VACÍO ==================
class _EstadoVacio extends StatelessWidget {
  final bool hayBusqueda;
  const _EstadoVacio({required this.hayBusqueda});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hayBusqueda
                  ? Icons.search_off
                  : Icons.label_off_outlined,
              size: 72,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              hayBusqueda
                  ? 'No hay etiquetas que coincidan con la búsqueda.'
                  : 'No hay etiquetas todavía.\nToca "Nueva etiqueta" para crear la primera.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}

// ================== ITEM DE ETIQUETA ==================
class _ItemEtiqueta extends StatelessWidget {
  final Etiqueta etiqueta;
  final bool seleccionada;
  final VoidCallback onToggle;

  const _ItemEtiqueta({
    required this.etiqueta,
    required this.seleccionada,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final cantidad = state.cantidadNotasDeEtiqueta(etiqueta.id);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        margin: EdgeInsets.zero,
        color: seleccionada ? Colors.indigo.shade50 : null,
        child: ListTile(
          onTap: onToggle,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          leading: Checkbox(
            value: seleccionada,
            onChanged: (_) => onToggle(),
          ),
          title: Row(
            children: [
              Icon(
                Icons.label,
                size: 16,
                color: seleccionada
                    ? Colors.indigo.shade700
                    : Colors.grey.shade600,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  etiqueta.nombre,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          subtitle: Text(
            '$cantidad ${cantidad == 1 ? "nota" : "notas"}',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          trailing: PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (v) {
              if (v == 'renombrar') {
                _mostrarEditorEtiqueta(context, etiqueta);
              } else if (v == 'eliminar') {
                _confirmarEliminarEtiqueta(context, etiqueta, cantidad);
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'renombrar',
                child: ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.edit_outlined),
                  title: Text('Renombrar'),
                ),
              ),
              PopupMenuItem(
                value: 'eliminar',
                child: ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.delete_outline, color: Colors.red),
                  title: Text(
                    'Eliminar',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================== DIÁLOGOS ==================
void _confirmarEliminarEtiqueta(
    BuildContext context, Etiqueta e, int cantidad) async {
  final state = AppStateScope.of(context);
  final ok = await mostrarConfirmacion(
    context,
    titulo: 'Eliminar etiqueta',
    mensaje:
        '¿Eliminar "${e.nombre}"?\n\nEsta etiqueta se quitará de $cantidad ${cantidad == 1 ? "nota" : "notas"}. Las notas NO se eliminan.',
  );
  if (ok) {
    state.eliminarEtiqueta(e.id);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Etiqueta "${e.nombre}" eliminada')),
      );
    }
  }
}

void _mostrarEditorEtiqueta(BuildContext context, Etiqueta? etiqueta) {
  final state = AppStateScope.of(context);
  final ctrl = TextEditingController(text: etiqueta?.nombre ?? '');
  final formKey = GlobalKey<FormState>();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                etiqueta == null ? 'Nueva etiqueta' : 'Renombrar etiqueta',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: ctrl,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la etiqueta *',
                  prefixIcon: Icon(Icons.label_outline),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'El nombre es obligatorio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        if (!formKey.currentState!.validate()) return;
                        final nombre = ctrl.text.trim();

                        if (etiqueta == null) {
                          // Verificar duplicado antes de crear
                          final existente =
                              state.buscarEtiquetaPorNombre(nombre);
                          if (existente != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Ya existe una etiqueta llamada "${existente.nombre}"',
                                ),
                                backgroundColor: Colors.red.shade600,
                              ),
                            );
                            return;
                          }
                          state.agregarEtiqueta(
                            Etiqueta(
                              id: state.generarId('eti'),
                              nombre: nombre,
                            ),
                          );
                        } else {
                          final ok = state.renombrarEtiqueta(
                            etiqueta.id,
                            nombre,
                          );
                          if (!ok) {
                            ScaffoldMessenger.of(context).showSnackBar(
                               SnackBar(
                                content: Text(
                                  'Ya existe otra etiqueta con ese nombre',
                                ),
                                backgroundColor: Colors.red.shade600,
                              ),
                            );
                            return;
                          }
                        }
                        Navigator.pop(ctx);
                      },
                      child: Text(etiqueta == null ? 'Crear' : 'Guardar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}