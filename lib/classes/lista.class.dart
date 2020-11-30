class Lista {
  final String numlista;
  final String idexterno;

  Lista({this.numlista, this.idexterno});

  factory Lista.fromJson(Map<String, dynamic> json) {
    return Lista(
      numlista: json['numlista'],
      idexterno: json['idexterno'],
    );
  }
}
