import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/missao.dart';

class MissaoService {
  static const baseUrl = 'https://api-geral-production.up.railway.app';

  static Future<List<Missao>> obterMissoes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token') ?? '';
      final userId = prefs.getString('user_id');

      if (userId == null || userId.isEmpty) {
        throw Exception('ID do usuário não encontrado');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/missoes?userId=$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data.map((missaoJson) => Missao.fromJson(missaoJson)).toList();
      } else {
        debugPrint('Erro ao obter missões: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('Erro ao buscar missões: $e');
      return [];
    }
  }

  static Future<String?> adicionarMissao(Missao missao) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token') ?? '';
      final userId = prefs.getString('user_id');
      final response = await http.post(
        Uri.parse('$baseUrl/missoes'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'userId': userId,
          'titulo': missao.titulo,
          'descricao': missao.descricao,
          'prioridade': missao.prioridade.toUpperCase(),
          'sessoesNecessarias': missao.sessoesNecessarias,
          'sessoesConcluidas': missao.sessoesConcluidas,
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['id']?.toString() ?? data['tarefa']?['id']?.toString();
      } else {
        debugPrint(response.body);
        throw Exception('Falha ao adicionar missão: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> deletarMissao(String missaoId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token') ?? '';
      final userId = prefs.getString('user_id');  

      final response = await http.delete(
        Uri.parse('$baseUrl/missoes/$missaoId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'userId': userId, 
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Falha ao deletar missão: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> atualizarProgressoMissao(String missaoId, int sessoesConcluidas, bool concluida, {List<String>? tags}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token') ?? '';

      String? atributoGanho;
      if (concluida && tags != null && tags.isNotEmpty) {
        atributoGanho = tags.first; // Ex: 'Intelecto', 'Força', etc.
      }

      final userId = prefs.getString('user_id');

      final response = await http.patch(
        Uri.parse('$baseUrl/missoes/$missaoId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'userId': userId,
          'sessoesConcluidas': sessoesConcluidas,
          'concluida': concluida,
          if (atributoGanho != null) 'atributoGanho': atributoGanho, // Envia o bônus para a API
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Falha ao atualizar progresso da missão: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> salvarSessaoHiperfoco(int duracaoMinutos, {int xpBonus = 0}) async {
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
          'xpBonus': xpBonus,
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