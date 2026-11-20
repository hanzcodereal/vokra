import 'package:flutter/material.dart';
import 'theme.dart';
import 'home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const VokraApp());
}

class VokraApp extends StatelessWidget {
  const VokraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vokra',
      debugShowCheckedModeBanner: false,
      theme: VokraTheme.light(),
      home: const HomePage(),
    );
  }
}
