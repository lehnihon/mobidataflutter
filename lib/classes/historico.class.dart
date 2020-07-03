class Historico{
  final String nota;
  final String nomeentrega;
  final String enderecoentrega;
  final String cepentrega;
  final String databaixa;
  final String motivo;

  Historico({this.nota, this.nomeentrega, this.enderecoentrega, this.cepentrega, this.databaixa, this.motivo});

  factory Historico.fromJson(Map<String, dynamic> json){
    return Historico(
      nota: json['nota'],
      nomeentrega: json['nomeentrega'],
      enderecoentrega: json['enderecoentrega'],
      cepentrega: json['cepentrega'],
      databaixa: json['databaixa'],
      motivo: json['motivo'],
    );
  }

}