class MicroPasso {
  String descricao;
  bool concluido;

  MicroPasso({required this.descricao, this.concluido = false});
}

class Missao {
  String? id;
  String titulo;
  String descricao;
  List<String> tags;
  String prioridade;
  List<MicroPasso> microPassos;
  bool concluida;
  int sessoesNecessarias;
  int sessoesConcluidas;

  Missao({
    this.id,
    required this.titulo,
    required this.descricao,
    required this.tags,
    required this.prioridade,
    required this.microPassos,
    this.concluida = false,
    this.sessoesNecessarias = 1,
    this.sessoesConcluidas = 0,
  });
}
