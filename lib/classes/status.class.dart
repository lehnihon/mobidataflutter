class Status {
  final int id;
  final String nome;
  final String tiraFoto;

  Status({this.id, this.nome, this.tiraFoto});

  factory Status.fromMap(Map<String, dynamic> map) {
    return Status(
      id: map['id'],
      nome: map['nome'],
      tiraFoto: map['tira_foto'],
    );
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'nome': nome,
      'tira_foto': tiraFoto,
    };
    return map;
  }

  @override
  String toString() {
    return "Status => (id: $id, nome: $nome, tira_foto: $tiraFoto)";
  }
}
