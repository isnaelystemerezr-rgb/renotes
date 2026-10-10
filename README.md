# renotes



# ReNotes - Notas de Investigación

App de notas de investigación hecha en Flutter para Android.

**Autor:** Isnaelys Temerez Rodríguez
**Asignatura:** Programación para Dispositivos Móviles

## ¿Qué hace la app?

Permite organizar el trabajo de investigación en proyectos. Dentro de cada proyecto se escriben notas 

largas que se pueden clasificar con etiquetas reutilizables entre proyectos.

## Características

- Crear, editar y eliminar proyectos
- Crear, editar y eliminar notas dentro de un proyecto
- Etiquetas globales reutilizables entre notas
- Autocompletado de etiquetas al escribir
- Búsqueda por título o contenido
- Filtros por proyecto y por etiquetas
- Agrupación de notas por varias etiquetas

## Pantallas

1. Proyectos – lista de proyectos
2. Notas del proyecto – notas con búsqueda y filtros
3. Editor de nota – crear/editar con autocompletado de etiquetas
4. Detalle de nota – ver contenido completo
5. Etiquetas – gestionar y agrupar por etiquetas
6. Buscar – búsqueda global en todas las notas

## Cómo ejecutar

1. Instalar Flutter (versión 3.x o superior)

2. Conectar un celular Android con depuración USB activada (o abrir un emulador)
3. Abrir una terminal en la carpeta del proyecto y ejecutar:

flutter pub get
flutter run

## Estructura del proyecto

lib/
- main.dart              → inicio de la app
- data/                  → datos de prueba
- models/                → Proyecto, Nota, Etiqueta
- screens/               → las 6 pantallas
- state/                 → estado global en 

memoria
- utils/                 → funciones auxiliares
- widgets/               → widgets reutilizables

## Capturas

Las capturas de las 6 pantallas están en la carpeta screenshots/.

## Notas

- Todos los datos se mantienen en memoria (no hay base de datos).
- Al iniciar se cargan datos de prueba (3 proyectos, 15 notas, 8 etiquetas).

- No se usan paquetes externos para el estado (solo lo que trae Flutter).
