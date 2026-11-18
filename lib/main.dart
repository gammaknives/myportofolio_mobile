import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/screens/menu.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
  title: 'MyPortfolio',
  theme: ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.indigo,
      secondary: Colors.amber[700],
    ),
    scaffoldBackgroundColor: Colors.transparent,
    useMaterial3: true,
  ),
  builder: (context, child) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color.fromARGB(255, 132, 233, 249),
            const Color.fromARGB(255, 75, 139, 251),
          ],
        ),
      ),
      child: child,
    );
  },
  home: MyHomePage(),
);
  }
}

