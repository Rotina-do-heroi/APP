
class MicroPasso {
  String descricao;
  bool concluido;

  MicroPasso({required this.descricao, this.concluido = false});

  factory MicroPasso.fromJson(Map<String, dynamic> json) {
    return MicroPasso(
      descricao: json['descricao'] ?? '',
      concluido: json['concluido'] ?? false,
    );
  }
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
  List<int> diasRepeticao;

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
    this.diasRepeticao = const [],
  });

  factory Missao.fromJson(Map<String, dynamic> json) {
 
    return Missao(
      id: json['id']?.toString(),
      titulo: json['titulo'] ?? '',
      descricao: json['descricao'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      prioridade: json['prioridade'] ?? 'NORMAL',
      microPassos: json['microPassos'] != null
          ? List<MicroPasso>.from(
              (json['microPassos'] as List).map((mp) => MicroPasso.fromJson(mp)))
          : [],
      concluida: json['concluida'] ?? false,
      sessoesNecessarias: json['sessoesNecessarias'] ?? 1,
      sessoesConcluidas: json['sessoesConcluidas'] ?? 0,
      diasRepeticao: json['diasRepeticao'] != null ? List<int>.from(json['diasRepeticao']) : [],
    );
  }
}
