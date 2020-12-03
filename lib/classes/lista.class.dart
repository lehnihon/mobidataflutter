class Lista {
  final String setor;
  final String numlista;

  Lista({this.setor, this.numlista});

  factory Lista.fromJson(Map<String, dynamic> json) {
    return Lista(
      setor: json['setor'],
      numlista: json['numlista'],
    );
  }
}
