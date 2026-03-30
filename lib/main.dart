import 'package:flutter/material.dart';

void main() {
  runApp(const EmptyApp());
}

class EmptyApp extends StatelessWidget {
  const EmptyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Vacia',
      debugShowCheckedModeBanner: false,
      home: const Scaffold(
        body: Center(
          child: Text('App Flutter vacia'),
        ),
      ),
    );
  }
}
