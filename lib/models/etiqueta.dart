import '../utils/normalizar_texto.dart';

class Etiqueta {
  final String id;
  String nombre;
  int? color;

  Etiqueta({
    required this.id,
    required this.nombre,
    this.color,
  });

  /// Clave normalizada para comparar unicidad
  /// (sin acentos, minúsculas, sin espacios al borde)
  String get claveNormalizada => normalizarTexto(nombre);

  /// Copia con nuevos valores
  Etiqueta copyWith({String? nombre, int? color}) {
    return Etiqueta(
      id: id,
      nombre: nombre ?? this.nombre,
      color: color ?? this.color,
    );
  }
}