class Configuracoes{
  String id;

  Configuracoes(this.id);

  Map<String,dynamic> toMap(){
    var map = <String,dynamic>{
      'id':id,
    };
    return map;
  }

  Configuracoes.fromMap(Map<String,dynamic> map){
    id = map['id'];
  }

  @override
  String toString(){
    return "Configuracoes => (id: $id)";
  }
}