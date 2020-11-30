class Status {
  final String id;
  final String nome;
  final String tiraFoto;

  Status({this.id, this.nome, this.tiraFoto});

  factory Status.fromMap(Map map) {
    return Status(
      id: map['id'].toString(),
      nome: map['nome'],
      tiraFoto: map['tira_foto'],
    );
  }

  Map toMap() {
    var map = {
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
