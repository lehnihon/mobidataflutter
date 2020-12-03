class Entrega {
  final String idexterno;

  Entrega({this.idexterno});

  factory Entrega.fromJson(Map<String, dynamic> json) {
    return Entrega(
      idexterno: json['idexterno'],
    );
  }
}
