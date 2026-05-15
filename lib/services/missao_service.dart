import 'dart:convert';
import 'package:app_rotina_mvp/models/missao.dart';
import 'package:http/http.dart' as http;

class MissaoService {
  static const String baseUrl = 'http://localhost:3001';

  static Future<void> criarMissao(Missao missao) async {
    final response = await http.post(
      Uri.parse('$baseUrl/missoes'),
      headers: {
        'Content-Type': 'application/json'
        
      },
      body: jsonEncode({
        'titulo': missao.titulo,
        'descricao': missao.descricao,
        'prioridade': missao.prioridade.toUpperCase(),
        'atributoRecompensa': missao.tags.isNotEmpty
            ? missao.tags.first.toUpperCase()
            : 'FOCO',
        'microPassos': missao.microPassos
            .map((mp) => {'titulo': mp.descricao})
            .toList(),
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Erro ao criar missão: ${response.body}');
    }
  }
}