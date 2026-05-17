import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/missao.dart';

class MissaoService {
  static const String baseUrl = 'https://api-geral-production.up.railway.app';

  static Future<String?> adicionarMissao(Missao missao) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token') ?? '';

      final response = await http.post(
        Uri.parse('$baseUrl/tarefas'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'titulo': missao.titulo,
          'descricao': missao.descricao,
          'prioridade': missao.prioridade,
          'sessoesNecessarias': missao.sessoesNecessarias,
          'sessoesConcluidas': missao.sessoesConcluidas,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['id']?.toString() ?? data['tarefa']?['id']?.toString();
      } else {
        throw Exception('Falha ao adicionar missão: ${response.statusCode}');
      }
    } catch (e) {
      rethrow; // Passa o erro adiante para a UI capturar e printar
    }
  }

  static Future<void> deletarMissao(String missaoId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token') ?? '';

      final response = await http.delete(
        Uri.parse('$baseUrl/tarefas/$missaoId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Falha ao deletar missão: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> atualizarProgressoMissao(String missaoId, int sessoesConcluidas, bool concluida) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token') ?? '';

      final response = await http.put(
        Uri.parse('$baseUrl/tarefas/$missaoId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'sessoesConcluidas': sessoesConcluidas,
          'concluida': concluida,
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Falha ao atualizar progresso da missão: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> salvarSessaoHiperfoco(int duracaoMinutos) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token') ?? '';

      final response = await http.post(
        Uri.parse('$baseUrl/hiperfoco/sessao'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'duracaoMinutos': duracaoMinutos,
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Falha ao salvar sessão de foco: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}