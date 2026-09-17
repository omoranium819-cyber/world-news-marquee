import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

void main() {
  runApp(const WorldNewsApp());
}

class WorldNewsApp extends StatelessWidget {
  const WorldNewsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'World News Marquee',
      theme: ThemeData(primarySwatch: Colors.indigo, useMaterial3: true),
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}
