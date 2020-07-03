import 'package:flutter/material.dart';

class BottomNav extends StatelessWidget {
  int index;
  Function onTapped;

  BottomNav({
    @required this.index,
    @required this.onTapped,
  });


  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.airport_shuttle),
          title: Text('Baixa'),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.apps),
          title: Text('Lista'),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment),
          title: Text('Histórico'),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.build),
          title: Text('Config.'),
        ),
      ],
      currentIndex: index,
      type: BottomNavigationBarType.fixed, 
      selectedItemColor: Theme.of(context).primaryColor,
      onTap: onTapped,
    );
  }
}