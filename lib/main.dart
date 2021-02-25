import 'package:flutter/material.dart';
import 'package:mobidata_dtc/pages/configuracoes.page.dart';
import 'package:mobidata_dtc/pages/home.page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mobidata',
      routes: {
        '/configuracoes': (BuildContext context) => ConfiguracoesPage(),
      },
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}
