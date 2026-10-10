import 'package:flutter/material.dart';
import 'state/app_state.dart';
import 'data/datos_prueba.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const ReNotesApp());
}

class ReNotesApp extends StatefulWidget {
  const ReNotesApp({super.key});

  @override
  State<ReNotesApp> createState() => _ReNotesAppState();
}

class _ReNotesAppState extends State<ReNotesApp> {
  final AppState _state = AppState();

  @override
  void initState() {
    super.initState();
    cargarDatosDePrueba(_state);
  }

  @override
  Widget build(BuildContext context) {
    return AppStateScope(
      state: _state,
      child: MaterialApp(
        title: 'ReNotes',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: const Color(0xFF3F51B5),
          scaffoldBackgroundColor: const Color(0xFFF5F5F7),
          appBarTheme: const AppBarTheme(
            centerTitle: false,
            elevation: 0,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            surfaceTintColor: Colors.transparent,
          ),
          cardTheme: CardThemeData(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            color: Colors.white,
            surfaceTintColor: Colors.transparent,
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}