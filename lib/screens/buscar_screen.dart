import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../models/nota.dart';
import '../models/etiqueta.dart';
import '../models/proyecto.dart';
import '../widgets/chip_etiqueta.dart';
import 'detalle_nota_screen.dart';

class BuscarScreen extends StatefulWidget {
  const BuscarScreen({super.key});

  @override
  State<BuscarScreen> createState() => _BuscarScreenState();
}

class _BuscarScreenState extends State<BuscarScreen> {
  final _busquedaCtrl = TextEditingController();
  String _textoBusqueda = '';
  String? _proyectoFiltro; // null = todos
  final Set<String> _etiquetasFiltro = {};
  bool _modoTodas = true; // true = todas, false = al menos una
  bool _mostrarFiltros = false;

  @override
  void dispose() {
    _busquedaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);

    // ====== RESULTADOS ======
    final resultados = state.buscarNotas(
      texto: _textoBusqueda,
      proyectoId: _proyectoFiltro,
      etiquetaIds: _etiquetasFiltro.toList(),
      modoTodas: _modoTodas,
    )..sort((a, b) => b.fechaModificacion.compareTo(a.fechaModificacion));

    final hayFiltrosActivos = _proyectoFiltro != null ||
        _etiquetasFiltro.isNotEmpty ||
        _textoBusqueda.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Buscar',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _mostrarFiltros ? Icons.filter_alt : Icons.filter_alt_outlined,
            ),
            tooltip: 'Filtros',
            onPressed: () {
              setState(() => _mostrarFiltros = !_mostrarFiltros);
            },
          ),
        ],
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
                hintText: 'Buscar en todas las notas...',
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

          // ===== Panel de filtros =====
          if (_mostrarFiltros) _panelFiltros(state),

          // ===== Contador de resultados =====
          if (hayFiltrosActivos)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Row(
                children: [
                  Text(
                    '${resultados.length} ${resultados.length == 1 ? "resultado" : "resultados"}',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  if (hayFiltrosActivos)
                    TextButton.icon(
                      icon: const Icon(Icons.clear_all, size: 16),
                      label: const Text('Limpiar'),
                      onPressed: () {
                        setState(() {
                          _busquedaCtrl.clear();
                          _textoBusqueda = '';
                          _proyectoFiltro = null;
                          _etiquetasFiltro.clear();
                        });
                      },
                    ),
                ],
              ),
            ),

          // ===== Lista de resultados =====
          Expanded(
            child: resultados.isEmpty
                ? _EstadoVacio(hayFiltros: hayFiltrosActivos)
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
                    itemCount: resultados.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final nota = resultados[i];
                      final proyecto = state.buscarProyecto(nota.proyectoId);
                      final etiquetas = nota.etiquetaIds
                          .map((id) => state.buscarEtiqueta(id))
                          .whereType<Etiqueta>()
                          .toList();

                      return _ResultadoNota(
                        nota: nota,
                        proyecto: proyecto,
                        etiquetas: etiquetas,
                        textoBusqueda: _textoBusqueda,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ===== PANEL DE FILTROS =====
  Widget _panelFiltros(AppState state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filtro por proyecto
          const Text(
            'Proyecto',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String?>(
            initialValue: _proyectoFiltro,
            isDense: true,
            decoration: const InputDecoration(
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('Todos los proyectos'),
              ),
              ...state.proyectos.map(
                (p) => DropdownMenuItem<String?>(
                  value: p.id,
                  child: Text(
                    p.nombre,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
            onChanged: (v) => setState(() => _proyectoFiltro = v),
          ),

          const SizedBox(height: 12),

          // Filtro por etiquetas
          const Text(
            'Etiquetas',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          if (state.etiquetas.isEmpty)
            Text(
              'No hay etiquetas creadas.',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            )
          else
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: state.etiquetas.map((e) {
                final activa = _etiquetasFiltro.contains(e.id);
                return FilterChip(
                  label: Text(e.nombre),
                  selected: activa,
                  selectedColor: Colors.indigo.shade100,
                  checkmarkColor: Colors.indigo.shade700,
                  onSelected: (sel) {
                    setState(() {
                      if (sel) {
                        _etiquetasFiltro.add(e.id);
                      } else {
                        _etiquetasFiltro.remove(e.id);
                      }
                    });
                  },
                );
              }).toList(),
            ),

          // Modo de agrupación (solo si hay 2+ etiquetas seleccionadas)
          if (_etiquetasFiltro.length >= 2) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Text(
                  'Modo:',
                  style: TextStyle(fontSize: 12.5),
                ),
                const SizedBox(width: 8),
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
          ],
        ],
      ),
    );
  }
}

// ================== ESTADO VACÍO ==================
class _EstadoVacio extends StatelessWidget {
  final bool hayFiltros;
  const _EstadoVacio({required this.hayFiltros});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hayFiltros ? Icons.search_off : Icons.search,
              size: 72,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              hayFiltros
                  ? 'No hay resultados para esta búsqueda.'
                  : 'Escribe algo para buscar en todas tus notas.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}

// ================== RESULTADO ==================
class _ResultadoNota extends StatelessWidget {
  final Nota nota;
  final Proyecto? proyecto;
  final List<Etiqueta> etiquetas;
  final String textoBusqueda;

  const _ResultadoNota({
    required this.nota,
    required this.proyecto,
    required this.etiquetas,
    required this.textoBusqueda,
  });

  @override
  Widget build(BuildContext context) {
    final extracto = nota.descripcion.length > 120
        ? '${nota.descripcion.substring(0, 120)}...'
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
              // Proyecto
              if (proyecto != null)
                Row(
                  children: [
                    Icon(
                      Icons.folder_outlined,
                      size: 13,
                      color: Colors.indigo.shade700,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        proyecto!.nombre,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: Colors.indigo.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 6),

              // Título
              Text(
                nota.titulo,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              // Extracto
              if (extracto.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  extracto,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ],

              // Etiquetas
              if (etiquetas.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  children: etiquetas
                      .map((e) => ChipEtiqueta(etiqueta: e))
                      .toList(),
                ),
              ],

              // Fecha
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.access_time,
                      size: 12, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(
                    _formatearFecha(nota.fechaModificacion),
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 11.5,
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