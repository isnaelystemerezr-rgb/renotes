class Nota {
  final String id;
  final String proyectoId;
  String titulo;
  String descripcion;
  final DateTime fechaCreacion;
  DateTime fechaModificacion;
  List<String> etiquetaIds;

  Nota({
    required this.id,
    required this.proyectoId,
    required this.titulo,
    required this.descripcion,
    required this.fechaCreacion,
    required this.fechaModificacion,
    List<String>? etiquetaIds,
  }) : etiquetaIds = etiquetaIds ?? [];

  Nota copyWith({
    String? titulo,
    String? descripcion,
    DateTime? fechaModificacion,
    List<String>? etiquetaIds,
  }) {
    return Nota(
      id: id,
      proyectoId: proyectoId,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      fechaCreacion: fechaCreacion,
      fechaModificacion: fechaModificacion ?? this.fechaModificacion,
      etiquetaIds: etiquetaIds ?? List.from(this.etiquetaIds),
    );
  }
}