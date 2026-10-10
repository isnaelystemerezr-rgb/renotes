import 'package:flutter/material.dart';
import '../models/proyecto.dart';
import '../models/nota.dart';
import '../models/etiqueta.dart';
import '../utils/normalizar_texto.dart';

class AppState extends ChangeNotifier {
  // ============ DATOS EN MEMORIA ============
  final List<Proyecto> proyectos = [];
  final List<Nota> notas = [];
  final List<Etiqueta> etiquetas = [];

  // ============ GENERADOR DE IDs ============
  int _contadorId = 0;
  String generarId(String prefijo) {
    _contadorId++;
    return '${prefijo}_${DateTime.now().millisecondsSinceEpoch}_$_contadorId';
  }

  // ============ PROYECTOS ============
  void agregarProyecto(Proyecto p) {
    proyectos.add(p);
    notifyListeners();
  }

  void actualizarProyecto(Proyecto p) {
    final index = proyectos.indexWhere((x) => x.id == p.id);
    if (index != -1) {
      proyectos[index] = p;
      notifyListeners();
    }
  }

  void eliminarProyecto(String id) {
    proyectos.removeWhere((p) => p.id == id);
    // Eliminar también las notas del proyecto
    notas.removeWhere((n) => n.proyectoId == id);
    // Las etiquetas NO se eliminan
    notifyListeners();
  }

  Proyecto? buscarProyecto(String id) {
    try {
      return proyectos.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  int cantidadNotasDeProyecto(String proyectoId) {
    return notas.where((n) => n.proyectoId == proyectoId).length;
  }

  // ============ NOTAS ============
  void agregarNota(Nota n) {
    notas.add(n);
    // Actualizar fecha de modificación del proyecto
    final proyecto = buscarProyecto(n.proyectoId);
    if (proyecto != null) {
      proyecto.fechaModificacion = DateTime.now();
    }
    notifyListeners();
  }

  void actualizarNota(Nota n) {
    final index = notas.indexWhere((x) => x.id == n.id);
    if (index != -1) {
      n.fechaModificacion = DateTime.now();
      notas[index] = n;
      final proyecto = buscarProyecto(n.proyectoId);
      if (proyecto != null) {
        proyecto.fechaModificacion = DateTime.now();
      }
      notifyListeners();
    }
  }

  void eliminarNota(String id) {
    final nota = buscarNota(id);
    notas.removeWhere((n) => n.id == id);
    if (nota != null) {
      final proyecto = buscarProyecto(nota.proyectoId);
      if (proyecto != null) {
        proyecto.fechaModificacion = DateTime.now();
      }
    }
    notifyListeners();
  }

  Nota? buscarNota(String id) {
    try {
      return notas.firstWhere((n) => n.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Nota> notasDeProyecto(String proyectoId) {
    return notas.where((n) => n.proyectoId == proyectoId).toList();
  }

  // ============ ETIQUETAS ============
  /// Busca una etiqueta por nombre (ignorando mayúsculas, acentos, espacios)
  Etiqueta? buscarEtiquetaPorNombre(String nombre) {
    final clave = normalizarTexto(nombre);
    try {
      return etiquetas.firstWhere((e) => e.claveNormalizada == clave);
    } catch (_) {
      return null;
    }
  }

  Etiqueta? buscarEtiqueta(String id) {
    try {
      return etiquetas.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Obtiene una etiqueta existente o crea una nueva si no existe
  Etiqueta obtenerOCrearEtiqueta(String nombre) {
    final existente = buscarEtiquetaPorNombre(nombre);
    if (existente != null) return existente;

    final nueva = Etiqueta(
      id: generarId('eti'),
      nombre: nombre.trim(),
    );
    etiquetas.add(nueva);
    notifyListeners();
    return nueva;
  }

  void agregarEtiqueta(Etiqueta e) {
    etiquetas.add(e);
    notifyListeners();
  }

  /// Renombra una etiqueta. Devuelve true si tuvo éxito, false si ya existe otra con ese nombre.
  bool renombrarEtiqueta(String id, String nuevoNombre) {
    final clave = normalizarTexto(nuevoNombre);

    // Verificar duplicado (que no sea ella misma)
    final existente = etiquetas.firstWhere(
      (e) => e.claveNormalizada == clave && e.id != id,
      orElse: () => Etiqueta(id: '', nombre: ''),
    );

    if (existente.id.isNotEmpty) {
      return false; // Ya existe otra con ese nombre
    }

    final etiqueta = buscarEtiqueta(id);
    if (etiqueta != null) {
      etiqueta.nombre = nuevoNombre.trim();
      notifyListeners();
      return true;
    }
    return false;
  }

  void eliminarEtiqueta(String id) {
    // Quitar de todas las notas
    for (final nota in notas) {
      nota.etiquetaIds.remove(id);
    }
    etiquetas.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  /// Cantidad de notas que usan esta etiqueta
  int cantidadNotasDeEtiqueta(String etiquetaId) {
    return notas.where((n) => n.etiquetaIds.contains(etiquetaId)).length;
  }

  /// Notas que tienen una etiqueta específica (de cualquier proyecto)
  List<Nota> notasConEtiqueta(String etiquetaId) {
    return notas.where((n) => n.etiquetaIds.contains(etiquetaId)).toList();
  }

  /// Notas que tienen TODAS las etiquetas dadas
  List<Nota> notasConTodasLasEtiquetas(List<String> etiquetaIds) {
    if (etiquetaIds.isEmpty) return [];
    return notas.where((n) {
      return etiquetaIds.every((id) => n.etiquetaIds.contains(id));
    }).toList();
  }

  /// Notas que tienen AL MENOS UNA de las etiquetas dadas
  List<Nota> notasConAlgunaEtiqueta(List<String> etiquetaIds) {
    if (etiquetaIds.isEmpty) return [];
    return notas.where((n) {
      return etiquetaIds.any((id) => n.etiquetaIds.contains(id));
    }).toList();
  }

  /// Búsqueda global: por título o contenido, opcionalmente filtrada por proyecto y etiquetas
  List<Nota> buscarNotas({
    String texto = '',
    String? proyectoId,
    List<String> etiquetaIds = const [],
    bool modoTodas = true,
  }) {
    Iterable<Nota> resultado = notas;

    // Filtro por proyecto
    if (proyectoId != null && proyectoId.isNotEmpty) {
      resultado = resultado.where((n) => n.proyectoId == proyectoId);
    }

    // Filtro por etiquetas
    if (etiquetaIds.isNotEmpty) {
      if (modoTodas) {
        resultado = resultado.where(
          (n) => etiquetaIds.every((id) => n.etiquetaIds.contains(id)),
        );
      } else {
        resultado = resultado.where(
          (n) => etiquetaIds.any((id) => n.etiquetaIds.contains(id)),
        );
      }
    }

    // Filtro por texto
    final textoNorm = normalizarTexto(texto);
    if (textoNorm.isNotEmpty) {
      resultado = resultado.where((n) {
        return normalizarTexto(n.titulo).contains(textoNorm) ||
            normalizarTexto(n.descripcion).contains(textoNorm);
      });
    }

    return resultado.toList();
  }
}

/// Widget para acceder al estado desde cualquier pantalla
class AppStateScope extends InheritedNotifier<AppState> {
  const AppStateScope({
    super.key,
    required AppState state,
    required super.child,
  }) : super(notifier: state);

  static AppState of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<AppStateScope>();
    assert(scope != null, 'AppStateScope no encontrado en el árbol de widgets');
    return scope!.notifier!;
  }
}