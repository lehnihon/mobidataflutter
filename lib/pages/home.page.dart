import 'package:flutter/material.dart';
import 'package:mobidata_dtc/pages/baixa.page.dart';
import 'package:mobidata_dtc/pages/entregas.page.dart';
import 'package:mobidata_dtc/pages/historico.page.dart';
import 'package:mobidata_dtc/widgets/bottom_nav.widget.dart';

import 'lista.page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  List<Widget> _widgetOptions = <Widget>[
    BaixaPage(),
    ListaPage(),
    EntregasPage(),
    HistoricoPage(),
  ];

  onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Image.asset(
            "assets/images/logo.png",
            height: 30,
          ),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.settings),
              tooltip: 'Configurações',
              onPressed: () {
                Navigator.of(context).pushNamed('/configuracoes');
              },
            ),
          ],
        ),
        body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
        bottomNavigationBar:
            BottomNav(index: _selectedIndex, onTapped: onItemTapped));
  }
}
