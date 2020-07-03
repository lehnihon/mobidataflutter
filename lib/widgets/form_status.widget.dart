import 'package:flutter/material.dart';
import 'package:mobidata_dtc/classes/status.class.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobidata_dtc/helpers/database_helper_status.dart';

class FormStatus extends StatefulWidget {
  final Status _dropdownValue;
  final Function _alteraStatus;

  FormStatus(this._dropdownValue, this._alteraStatus);

  @override
  _FormStatusState createState() => _FormStatusState();
}

class _FormStatusState extends State<FormStatus> {
  List<Status> status;
  List<DropdownMenuItem<Status>> dropdownStatus;
  DatabaseHelperStatus _dbs = DatabaseHelperStatus();

  @override
  void initState() {
    super.initState();
    _getStatus();
  }

  _getStatus() async {
    _dbs.getStatusLista().then((lista) {
      if (lista.isEmpty) {
        _getStatusApi();
      } else {
        _getStatusDb(lista);
      }
    });
  }

  _getStatusApi() async {
    final response =
        await http.get('http://34.200.50.59/mobidataapi/status.php');
    setState(() {
      Iterable data = json.decode(response.body);
      final list = List<Status>();
      for (Map dt in data) {
        Status status = Status.fromMap(dt);
        _dbs.insertStatus(status);
        list.add(status);
      }
      dropdownStatus = list.map<DropdownMenuItem<Status>>((Status status) {
        return DropdownMenuItem<Status>(
          value: status,
          child: Text(status.nome),
        );
      }).toList();
    });
  }

  _getStatusDb(lista) {
    setState(() {
      dropdownStatus = lista.map<DropdownMenuItem<Status>>((Status status) {
        return DropdownMenuItem<Status>(
          value: status,
          child: Text(status.nome),
        );
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<Status>(
      value: widget._dropdownValue,
      hint: new Text("Selecione o status"),
      isExpanded: true,
      elevation: 16,
      style: new TextStyle(color: Colors.grey[600], fontSize: 16),
      underline: Container(
        height: 1,
        color: Colors.grey[500],
      ),
      onChanged: (Status newValue) {
        widget._alteraStatus(newValue);
      },
      items: dropdownStatus,
    );
  }
}
