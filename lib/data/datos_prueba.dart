import '../models/proyecto.dart';
import '../models/nota.dart';
import '../models/etiqueta.dart';
import '../state/app_state.dart';

void cargarDatosDePrueba(AppState state) {
  final ahora = DateTime.now();

  // ============ ETIQUETAS (8) ============
  final eMetodologia = Etiqueta(id: 'eti_metodologia', nombre: 'Metodología');
  final eResultados = Etiqueta(id: 'eti_resultados', nombre: 'Resultados');
  final eBibliografia = Etiqueta(id: 'eti_bibliografia', nombre: 'Bibliografía');
  final eHipotesis = Etiqueta(id: 'eti_hipotesis', nombre: 'Hipótesis');
  final eDatos = Etiqueta(id: 'eti_datos', nombre: 'Datos');
  final eAnalisis = Etiqueta(id: 'eti_analisis', nombre: 'Análisis');
  final eConclusiones = Etiqueta(id: 'eti_conclusiones', nombre: 'Conclusiones');
  final ePendiente = Etiqueta(id: 'eti_pendiente', nombre: 'Pendiente'); // ← sin notas

  state.etiquetas.addAll([
    eMetodologia,
    eResultados,
    eBibliografia,
    eHipotesis,
    eDatos,
    eAnalisis,
    eConclusiones,
    ePendiente,
  ]);

  // ============ PROYECTOS (3) ============
  final p1 = Proyecto(
    id: 'pro_1',
    nombre: 'Inteligencia Artificial en Educación',
    descripcion: 'Estudio sobre el impacto de la IA en el aprendizaje universitario.',
    fechaCreacion: ahora.subtract(const Duration(days: 30)),
    fechaModificacion: ahora.subtract(const Duration(days: 2)),
  );

  final p2 = Proyecto(
    id: 'pro_2',
    nombre: 'Cambio Climático en el Caribe',
    descripcion: 'Análisis de los efectos del cambio climático en las islas del Caribe.',
    fechaCreacion: ahora.subtract(const Duration(days: 60)),
    fechaModificacion: ahora.subtract(const Duration(days: 5)),
  );

  final p3 = Proyecto(
    id: 'pro_3',
    nombre: 'Energías Renovables',
    descripcion: 'Investigación sobre fuentes de energía sostenible en Cuba.',
    fechaCreacion: ahora.subtract(const Duration(days: 15)),
    fechaModificacion: ahora.subtract(const Duration(days: 1)),
  );

  state.proyectos.addAll([p1, p2, p3]);

  // ============ NOTAS (15) ============

  // Texto largo de ejemplo (más de 600 caracteres) para reutilizar
  const textoLargo = '''
La inteligencia artificial ha experimentado un crecimiento exponencial en los últimos años, transformando múltiples sectores de la sociedad. En el ámbito educativo, su incorporación plantea tanto oportunidades como desafíos que requieren un análisis profundo y cuidadoso. Por un lado, los sistemas de tutoría inteligente pueden personalizar el aprendizaje adaptándose al ritmo y estilo de cada estudiante, ofreciendo retroalimentación inmediata y detectando áreas de dificultad antes de que se conviertan en problemas mayores.

Sin embargo, es fundamental considerar las implicaciones éticas y pedagógicas de esta tecnología. La dependencia excesiva de sistemas automatizados podría reducir la interacción humana esencial en el proceso educativo. Además, surgen preguntas sobre la privacidad de los datos de los estudiantes, la equidad en el acceso a estas herramientas y la formación docente necesaria para utilizarlas efectivamente.

Diversos estudios han demostrado que la efectividad de la IA en educación depende en gran medida del contexto en que se aplica y de la preparación de los docentes para integrarla en sus prácticas pedagógicas cotidianas. No se trata simplemente de introducir tecnología, sino de repensar los modelos educativos para aprovechar su potencial sin perder de vista los objetivos formativos fundamentales.
''';

  // --- Proyecto 1: 5 notas ---
  state.notas.add(Nota(
    id: 'not_1',
    proyectoId: p1.id,
    titulo: 'Estado del arte en IA educativa',
    descripcion: textoLargo,
    fechaCreacion: ahora.subtract(const Duration(days: 25)),
    fechaModificacion: ahora.subtract(const Duration(days: 3)),
    etiquetaIds: [eMetodologia.id, eBibliografia.id, eAnalisis.id],
  ));

  state.notas.add(Nota(
    id: 'not_2',
    proyectoId: p1.id,
    titulo: 'Hipótesis principal de la investigación',
    descripcion: textoLargo,
    fechaCreacion: ahora.subtract(const Duration(days: 20)),
    fechaModificacion: ahora.subtract(const Duration(days: 4)),
    etiquetaIds: [eHipotesis.id, eMetodologia.id],
  ));

  state.notas.add(Nota(
    id: 'not_3',
    proyectoId: p1.id,
    titulo: 'Resultados preliminares del primer trimestre',
    descripcion: textoLargo,
    fechaCreacion: ahora.subtract(const Duration(days: 15)),
    fechaModificacion: ahora.subtract(const Duration(days: 2)),
    etiquetaIds: [eResultados.id, eDatos.id],
  ));

  state.notas.add(Nota(
    id: 'not_4',
    proyectoId: p1.id,
    titulo: 'Consideraciones éticas sobre IA en el aula',
    descripcion: 'Análisis de los principales dilemas éticos: privacidad, sesgo algorítmico, dependencia tecnológica y equidad en el acceso.',
    fechaCreacion: ahora.subtract(const Duration(days: 10)),
    fechaModificacion: ahora.subtract(const Duration(days: 1)),
    etiquetaIds: [eAnalisis.id, eMetodologia.id],
  ));

  state.notas.add(Nota(
    id: 'not_5',
    proyectoId: p1.id,
    titulo: 'Notas sueltas sin clasificar',
    descripcion: 'Ideas pendientes de organizar sobre posibles colaboraciones con otros investigadores.',
    fechaCreacion: ahora.subtract(const Duration(days: 5)),
    fechaModificacion: ahora.subtract(const Duration(days: 5)),
    etiquetaIds: [], // ← Nota SIN etiquetas
  ));

  // --- Proyecto 2: 5 notas ---
  state.notas.add(Nota(
    id: 'not_6',
    proyectoId: p2.id,
    titulo: 'Temperaturas históricas del Caribe',
    descripcion: textoLargo,
    fechaCreacion: ahora.subtract(const Duration(days: 55)),
    fechaModificacion: ahora.subtract(const Duration(days: 10)),
    etiquetaIds: [eDatos.id, eAnalisis.id, eMetodologia.id],
  ));

  state.notas.add(Nota(
    id: 'not_7',
    proyectoId: p2.id,
    titulo: 'Impacto en la agricultura local',
    descripcion: textoLargo,
    fechaCreacion: ahora.subtract(const Duration(days: 45)),
    fechaModificacion: ahora.subtract(const Duration(days: 8)),
    etiquetaIds: [eResultados.id, eAnalisis.id],
  ));

  state.notas.add(Nota(
    id: 'not_8',
    proyectoId: p2.id,
    titulo: 'Modelos predictivos del nivel del mar',
    descripcion: 'Revisión de distintos modelos climáticos utilizados para predecir el aumento del nivel del mar en la región caribeña.',
    fechaCreacion: ahora.subtract(const Duration(days: 35)),
    fechaModificacion: ahora.subtract(const Duration(days: 7)),
    etiquetaIds: [eMetodologia.id, eDatos.id],
  ));

  state.notas.add(Nota(
    id: 'not_9',
    proyectoId: p2.id,
    titulo: 'Conclusiones parciales del estudio',
    descripcion: textoLargo,
    fechaCreacion: ahora.subtract(const Duration(days: 25)),
    fechaModificacion: ahora.subtract(const Duration(days: 5)),
    etiquetaIds: [eConclusiones.id, eAnalisis.id],
  ));

  state.notas.add(Nota(
    id: 'not_10',
    proyectoId: p2.id,
    titulo: 'Bibliografía sobre cambio climático',
    descripcion: 'Listado de artículos científicos y libros de referencia utilizados en el proyecto.',
    fechaCreacion: ahora.subtract(const Duration(days: 20)),
    fechaModificacion: ahora.subtract(const Duration(days: 6)),
    etiquetaIds: [eBibliografia.id, eMetodologia.id],
  ));

  // --- Proyecto 3: 5 notas ---
  state.notas.add(Nota(
    id: 'not_11',
    proyectoId: p3.id,
    titulo: 'Panorama energético cubano actual',
    descripcion: textoLargo,
    fechaCreacion: ahora.subtract(const Duration(days: 12)),
    fechaModificacion: ahora.subtract(const Duration(days: 2)),
    etiquetaIds: [eMetodologia.id, eAnalisis.id],
  ));

  state.notas.add(Nota(
    id: 'not_12',
    proyectoId: p3.id,
    titulo: 'Potencial solar en la región oriental',
    descripcion: textoLargo,
    fechaCreacion: ahora.subtract(const Duration(days: 10)),
    fechaModificacion: ahora.subtract(const Duration(days: 1)),
    etiquetaIds: [eDatos.id, eResultados.id, eMetodologia.id],
  ));

  state.notas.add(Nota(
    id: 'not_13',
    proyectoId: p3.id,
    titulo: 'Energía eólica: casos de éxito',
    descripcion: 'Análisis de parques eólicos existentes y su contribución a la matriz energética nacional.',
    fechaCreacion: ahora.subtract(const Duration(days: 8)),
    fechaModificacion: ahora.subtract(const Duration(days: 3)),
    etiquetaIds: [eResultados.id, eAnalisis.id],
  ));

  state.notas.add(Nota(
    id: 'not_14',
    proyectoId: p3.id,
    titulo: 'Hipótesis sobre viabilidad económica',
    descripcion: 'Planteamiento inicial sobre la viabilidad económica de transición energética a gran escala.',
    fechaCreacion: ahora.subtract(const Duration(days: 6)),
    fechaModificacion: ahora.subtract(const Duration(days: 2)),
    etiquetaIds: [eHipotesis.id, eMetodologia.id],
  ));

  state.notas.add(Nota(
    id: 'not_15',
    proyectoId: p3.id,
    titulo: 'Próximos pasos del proyecto',
    descripcion: 'Planificación de las siguientes fases: recopilación de datos, entrevistas con expertos y análisis comparativo.',
    fechaCreacion: ahora.subtract(const Duration(days: 3)),
    fechaModificacion: ahora.subtract(const Duration(days: 1)),
    etiquetaIds: [ePendiente.id, eMetodologia.id],
  ));

  
}