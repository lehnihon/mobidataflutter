import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:mobidata_dtc/classes/baixa.class.dart';
import 'package:mobidata_dtc/classes/status.class.dart';
import 'package:mobidata_dtc/helpers/database_helper.dart';
import 'package:mobidata_dtc/helpers/database_helper_baixa.dart';
import 'package:mobidata_dtc/widgets/form_status.widget.dart';

class BaixaPage extends StatefulWidget {
  @override
  _BaixaPageState createState() => _BaixaPageState();
}

class _BaixaPageState extends State<BaixaPage> {
  Status status;
  Position _position;
  Baixa _baixa;
  DatabaseHelperBaixa dbb = DatabaseHelperBaixa();
  DatabaseHelper db = DatabaseHelper();
  final _notaController = TextEditingController();

  void saveBaixa(nota, status) {
    var dt = DateTime.now();
    var formatData = DateFormat("yyyy-MM-dd");
    String data = formatData.format(dt);
    var formatHora = DateFormat("HH:mm:ss");
    String hora = formatHora.format(dt);
    getPosition().then((posi) {
      db.getConfig().then((config) {
        setState(() {
          _baixa = new Baixa(
            nota,
            status,
            "foto link",
            data,
            hora,
            _position.latitude.toString(),
            _position.longitude.toString(),
            config.id,
          );
          dbb.insertBaixa(_baixa);
          dbb.getBaixaLista().then((lista) {
            print(lista);
          });
        });
      });
    });
  }

  Future getPosition() async {
    _position = await Geolocator()
        .getLastKnownPosition(desiredAccuracy: LocationAccuracy.high);
    return 1;
  }

  void alteraStatus(newValue) {
    setState(() {
      status = newValue;
    });
  }

  Future<void> barCodeScan() async {
    var result = await BarcodeScanner.scan();

    print(result.type); // The result type (barcode, cancelled, failed)
    print(result.rawContent); // The barcode content
    print(result.format); // The barcode format (as enum)
    print(result.formatNote);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        children: <Widget>[
          TextFormField(
            controller: _notaController,
            decoration: InputDecoration(
              labelText: "Código da Nota",
              suffixIcon: IconButton(
                icon: Icon(Icons.developer_mode),
                onPressed: () {
                  barCodeScan();
                },
              ),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            },
          ),
          SizedBox(
            height: 10,
          ),
          FormStatus(status, alteraStatus),
          SizedBox(
            height: 10,
          ),
          RaisedButton(
            onPressed: () {
              saveBaixa(_notaController.text, status.id);
            },
            child: const Text('Gravar', style: TextStyle(fontSize: 20)),
          ),
        ],
      ),
    );
  }
}
