import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../models/nota.dart';
import '../models/etiqueta.dart';
import '../utils/normalizar_texto.dart';
import '../widgets/chip_etiqueta.dart';
import '../widgets/dialogo_confirmacion.dart';

class EditorNotaScreen extends StatefulWidget {
  final String proyectoId;
  final String? notaId;

  const EditorNotaScreen({
    super.key,
    required this.proyectoId,
    this.notaId,
  });

  @override
  State<EditorNotaScreen> createState() => _EditorNotaScreenState();
}

class _EditorNotaScreenState extends State<EditorNotaScreen> {
  late final TextEditingController _tituloCtrl;
  late final TextEditingController _descripcionCtrl;
  final _tagCtrl = TextEditingController();
  final _tagFocus = FocusNode();
  final _formKey = GlobalKey<FormState>();

  // Lista de IDs de etiquetas asignadas al borrador
  final List<String> _etiquetasSeleccionadas = [];

  Nota? _notaOriginal;
  bool _esEdicion = false;
  bool _cambiosSinGuardar = false;
  bool _inicializado = false;
  
@override
void initState() {
  super.initState();

  _tituloCtrl = TextEditingController();
  _descripcionCtrl = TextEditingController();

  _tituloCtrl.addListener(_marcarCambio);
  _descripcionCtrl.addListener(_marcarCambio);
}

@override
void didChangeDependencies() {

  super.didChangeDependencies();

  if (_inicializado) return;
  _inicializado = true;

  final state = AppStateScope.of(context);

  if (widget.notaId != null) {
    _notaOriginal = state.buscarNota(widget.notaId!);
    _esEdicion = _notaOriginal != null;
  }

  if (_notaOriginal != null) {
    _tituloCtrl.text = _notaOriginal!.titulo;
    _descripcionCtrl.text = 

_notaOriginal!.descripcion;
    _etiquetasSeleccionadas.addAll(_notaOriginal!.etiquetaIds);
  }
}

  void _marcarCambio() {
    if (!_cambiosSinGuardar) {
      setState(() => _cambiosSinGuardar = true);
    }
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descripcionCtrl.dispose();
    _tagCtrl.dispose();
    _tagFocus.dispose();
    super.dispose();
  }

  // ============ LÓGICA DE ETIQUETAS ============

  void _asignarEtiqueta(Etiqueta e) {
    if (_etiquetasSeleccionadas.contains(e.id)) return;
    setState(() {
      _etiquetasSeleccionadas.add(e.id);
      _cambiosSinGuardar = true;
    });
    _tagCtrl.clear();
  }

  void _crearYAsignarEtiqueta(String nombre) {
    final state = AppStateScope.of(context);
    final et = state.obtenerOCrearEtiqueta(nombre);
    _asignarEtiqueta(et);
  }


  // ============ GUARDAR ============

  Future<bool> _guardar() async {
    if (!_formKey.currentState!.validate()) return false;

    final state = AppStateScope.of(context);

    if (_esEdicion && _notaOriginal != null) {
      final actualizada = _notaOriginal!.copyWith(
        titulo: _tituloCtrl.text.trim(),
        descripcion: _descripcionCtrl.text,
        etiquetaIds: List.from(_etiquetasSeleccionadas),
      );
      state.actualizarNota(actualizada);
    } else {
      final nueva = Nota(
        id: state.generarId('not'),
        proyectoId: widget.proyectoId,
        titulo: _tituloCtrl.text.trim(),
        descripcion: _descripcionCtrl.text,
        fechaCreacion: DateTime.now(),
        fechaModificacion: DateTime.now(),
        etiquetaIds: List.from(_etiquetasSeleccionadas),
      );
      state.agregarNota(nueva);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_esEdicion ? 'Nota actualizada' : 'Nota creada'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
    return true;
  }

  Future<void> _salir() async {
    if (_cambiosSinGuardar) {
      final ok = await mostrarConfirmacion(
        context,
        titulo: 'Descartar cambios',
        mensaje: 'Tienes cambios sin guardar. ¿Quieres salir de todos modos?',
        textoConfirmar: 'Salir sin guardar',
        textoCancelar: 'Seguir editando',
      );
      if (!ok) return;
    }
    if (mounted) Navigator.pop(context);
  }

  // ============ UI ============

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final etiquetasAsignadas = _etiquetasSeleccionadas
        .map((id) => state.buscarEtiqueta(id))
        .whereType<Etiqueta>()
        .toList();

    return WillPopScope(
      onWillPop: () async {
        if (_cambiosSinGuardar) {
          await _salir();
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _salir,
          ),
          title: Text(_esEdicion ? 'Editar nota' : 'Nueva nota'),
          actions: [
            TextButton.icon(
              onPressed: () async {
                final ok = await _guardar();
                if (ok && mounted) Navigator.pop(context);
              },
              icon: const Icon(Icons.check),
              label: const Text('Guardar'),
            ),
          ],
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              children: [
                // === TÍTULO ===
                TextFormField(
                  controller: _tituloCtrl,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Título *',
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'El título es obligatorio';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // === DESCRIPCIÓN ===
                TextFormField(
                  controller: _descripcionCtrl,
                  maxLines: null,
                  minLines: 8,
                  keyboardType: TextInputType.multiline,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    alignLabelWithHint: true,
                    hintText: 'Escribe aquí el contenido de tu nota...',
                  ),
                ),

                const SizedBox(height: 20),

                // === ETIQUETAS ASIGNADAS ===
                Row(
                  children: [
                    const Icon(Icons.local_offer_outlined, size: 18),
                    const SizedBox(width: 6),
                    const Text(
                      'Etiquetas',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${etiquetasAsignadas.length}',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (etiquetasAsignadas.isNotEmpty)
                  Wrap(
                    children: etiquetasAsignadas
                        .map(
                          (e) => ChipEtiqueta(
                            etiqueta: e,
                            onDeleted: () {
                              setState(() {
                                _etiquetasSeleccionadas.remove(e.id);
                                _cambiosSinGuardar = true;
                              });
                            },
                          ),
                        )
                        .toList(),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      'Sin etiquetas. Escribe abajo para agregar.',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ),

                const SizedBox(height: 12),

                // === AUTOCOMPLETADO DE ETIQUETAS ===
                _CampoAutocompletadoEtiquetas(
                  controller: _tagCtrl,
                  focusNode: _tagFocus,
                  etiquetasYaAsignadas: _etiquetasSeleccionadas,
                  onSeleccionar: _asignarEtiqueta,
                  onCrear: _crearYAsignarEtiqueta,
                ),

                const SizedBox(height: 8),
                Text(
                  'Escribe para buscar etiquetas. Enter o coma para confirmar.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 24),

                // === BOTONES ===
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _salir,
                        icon: const Icon(Icons.close),
                        label: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () async {
                          final ok = await _guardar();
                          if (ok && mounted) Navigator.pop(context);
                        },
                        icon: const Icon(Icons.save_outlined),
                        label: const Text('Guardar'),
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
}

// =============================================================
// CAMPO DE AUTOCOMPLETADO DE ETIQUETAS (RawAutocomplete)
// =============================================================
class _CampoAutocompletadoEtiquetas extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final List<String> etiquetasYaAsignadas;
  final void Function(Etiqueta) onSeleccionar;
  final void Function(String) onCrear;

  const _CampoAutocompletadoEtiquetas({
    required this.controller,
    required this.focusNode,
    required this.etiquetasYaAsignadas,
    required this.onSeleccionar,
    required this.onCrear,
  });

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);

    return RawAutocomplete<Etiqueta>(
      textEditingController: controller,
      focusNode: focusNode,
      displayStringForOption: (e) => e.nombre,
      optionsBuilder: (TextEditingValue value) {
        final texto = value.text.trim();
        if (texto.isEmpty) {
          return const Iterable<Etiqueta>.empty();
        }

        final clave = normalizarTexto(texto);
        final yaAsignadas = etiquetasYaAsignadas.toSet();

        // Sugerencias: etiquetas globales que coincidan parcialmente,
        // sin las que ya están asignadas a la nota.
        return state.etiquetas.where((e) {
          return !yaAsignadas.contains(e.id) &&
              e.claveNormalizada.contains(clave);
        });
      },
      fieldViewBuilder: (context, ctrl, fn, onSubmitted) {
        return TextField(
          controller: ctrl,
          focusNode: fn,
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(
            labelText: 'Agregar etiqueta',
            hintText: 'Ej: metodología',
            prefixIcon: Icon(Icons.add),
          ),
          onSubmitted: (valor) {
            final texto = valor.trim();
            if (texto.isEmpty) return;

            // Buscar coincidencia exacta
            final existente = state.buscarEtiquetaPorNombre(texto);
            if (existente != null) {
              onSeleccionar(existente);
            } else {
              onCrear(texto);
            }
          },
          onChanged: (valor) {
            // Si el usuario escribe una coma, confirmar la etiqueta
            if (valor.endsWith(',')) {
              final texto = valor.substring(0, valor.length - 1).trim();
              if (texto.isEmpty) return;

              final existente = state.buscarEtiquetaPorNombre(texto);
              if (existente != null) {
                onSeleccionar(existente);
              } else {
                onCrear(texto);
              }
            }
          },
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        final lista = options.toList();
        final textoActual = controller.text.trim();
        final existeExacta = textoActual.isNotEmpty &&
            state.buscarEtiquetaPorNombre(textoActual) != null;
        final mostrarOpcionCrear =
            textoActual.isNotEmpty && !existeExacta && lista.isEmpty;

        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(12),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: 240,
                maxWidth: 320,
              ),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: lista.length + (mostrarOpcionCrear ? 1 : 0),
                itemBuilder: (context, i) {
                  if (i == lista.length) {
                    // Opción "Crear nueva etiqueta"
                    return ListTile(
                      dense: true,
                      leading: const Icon(Icons.add_circle_outline,
                          color: Colors.indigo),
                      title: Text('Crear "$textoActual"'),
                      onTap: () => onCrear(textoActual),
                    );
                  }
                  final e = lista[i];
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.label_outline),
                    title: Text(e.nombre),
                    onTap: () => onSelected(e),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}