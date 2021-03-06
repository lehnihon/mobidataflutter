class Baixa {
  String id, nota, status, foto, data, hora, latitude, longitude, userid;

  Baixa(this.nota, this.status, this.foto, this.data, this.hora, this.latitude,
      this.longitude, this.userid);

  Map toMap() {
    var map = {
      'nota': nota,
      'status': status,
      'foto': foto,
      'data': data,
      'hora': hora,
      'latitude': latitude,
      'longitude': longitude,
      'userid': userid
    };
    return map;
  }

  Baixa.fromMap(Map map) {
    id = map['id'].toString();
    nota = map['nota'];
    status = map['status'];
    foto = map['foto'];
    data = map['data'];
    hora = map['hora'];
    latitude = map['latitude'];
    longitude = map['longitude'];
    userid = map['userid'];
  }

  @override
  String toString() {
    return "Baixa => (id: $id,nota: $nota, status: $status, foto: $foto, data: $data, hora: $hora, latitude: $latitude, longitude: $longitude, userid: $userid)";
  }
}
