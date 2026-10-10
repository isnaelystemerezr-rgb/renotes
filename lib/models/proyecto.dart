class Proyecto {
  final String id;
  String nombre;
  String descripcion;
  final DateTime fechaCreacion;
  DateTime fechaModificacion;

  Proyecto({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.fechaCreacion,
    required this.fechaModificacion,
  });

  Proyecto copyWith({
    String? nombre,
    String? descripcion,
    DateTime? fechaModificacion,
  }) {
    return Proyecto(
      id: id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      fechaCreacion: fechaCreacion,
      fechaModificacion: fechaModificacion ?? this.fechaModificacion,
    );
  }
}