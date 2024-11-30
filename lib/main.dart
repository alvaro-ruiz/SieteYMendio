import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() => runApp(const SieteYMediaApp());

class SieteYMediaApp extends StatelessWidget {
  const SieteYMediaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Siete y Media - Baraja Española',
      theme: ThemeData.dark(),
      home: const HomePage(), // Redirige a la pantalla de inicio
    );
  }
}
