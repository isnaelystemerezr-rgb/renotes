import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../models/proyecto.dart';
import '../widgets/dialogo_confirmacion.dart';
import 'notas_proyecto_screen.dart';

class ProyectosScreen extends StatelessWidget {
  const ProyectosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final proyectos = List<Proyecto>.from(state.proyectos)
      ..sort((a, b) => b.fechaModificacion.compareTo(a.fechaModificacion));

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mis Proyectos',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: proyectos.isEmpty
          ? _ListaVacia()
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),
              itemCount: proyectos.length,
              itemBuilder: (context, i) {
                final p = proyectos[i];
                return _TarjetaProyecto(proyecto: p);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _mostrarEditorProyecto(context, null),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo proyecto'),
      ),
    );
  }
}

// ================== ESTADO VACÍO ==================
class _ListaVacia extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              'No hay proyectos todavía',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Toca "Nuevo proyecto" para comenzar tu investigación',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}

// ================== TARJETA DE PROYECTO ==================
class _TarjetaProyecto extends StatelessWidget {
  final Proyecto proyecto;
  const _TarjetaProyecto({required this.proyecto});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final cantidad = state.cantidadNotasDeProyecto(proyecto.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NotasProyectoScreen(proyectoId: proyecto.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.folder,
                      color: Colors.indigo.shade700,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      proyecto.nombre,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (v) {
                      if (v == 'editar') {
                        _mostrarEditorProyecto(context, proyecto);
                      } else if (v == 'eliminar') {
                        _confirmarEliminar(context, proyecto, cantidad);
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
                          leading: Icon(Icons.delete_outline, color: Colors.red),
                          title: Text('Eliminar',
                              style: TextStyle(color: Colors.red)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (proyecto.descripcion.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  proyecto.descripcion,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 13.5,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.description_outlined,
                      size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    '$cantidad ${cantidad == 1 ? "nota" : "notas"}',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12.5,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.access_time,
                      size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    _formatearFecha(proyecto.fechaModificacion),
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12.5,
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

void _confirmarEliminar(BuildContext context, Proyecto p, int cantidad) async {
  final state = AppStateScope.of(context);
  final confirmado = await mostrarConfirmacion(
    context,
    titulo: 'Eliminar proyecto',
    mensaje:
        '¿Seguro que quieres eliminar "${p.nombre}"?\n\nSe eliminarán también sus $cantidad ${cantidad == 1 ? "nota" : "notas"}. Las etiquetas NO se eliminan.',
  );
  if (confirmado) {
    state.eliminarProyecto(p.id);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Proyecto "${p.nombre}" eliminado')),
      );
    }
  }
}

void _mostrarEditorProyecto(BuildContext context, Proyecto? proyecto) {
  final state = AppStateScope.of(context);
  final nombreCtrl = TextEditingController(text: proyecto?.nombre ?? '');
  final descCtrl = TextEditingController(text: proyecto?.descripcion ?? '');
  final formKey = GlobalKey<FormState>();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(ctx).viewInsets.bottom,
      ),
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
                proyecto == null ? 'Nuevo proyecto' : 'Editar proyecto',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: nombreCtrl,
                autofocus: true,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Nombre del proyecto *',
                  prefixIcon: Icon(Icons.folder_outlined),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'El nombre es obligatorio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: descCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descripción corta',
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.notes_outlined),
                ),
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

                        if (proyecto == null) {
                          final nuevo = Proyecto(
                            id: state.generarId('pro'),
                            nombre: nombreCtrl.text.trim(),
                            descripcion: descCtrl.text.trim(),
                            fechaCreacion: DateTime.now(),
                            fechaModificacion: DateTime.now(),
                          );
                          state.agregarProyecto(nuevo);
                        } else {
                          proyecto.nombre = nombreCtrl.text.trim();
                          proyecto.descripcion = descCtrl.text.trim();
                          proyecto.fechaModificacion = DateTime.now();
                          state.actualizarProyecto(proyecto);
                        }
                        Navigator.pop(ctx);
                      },
                      child: Text(proyecto == null ? 'Crear' : 'Guardar'),
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