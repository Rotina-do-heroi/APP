import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/missao.dart';

class MissaoService {
  static const baseUrl = 'https://api-geral-production.up.railway.app';

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

  static Future<void> atualizarProgressoMissao(String missaoId, int sessoesConcluidas, bool concluida, {List<String>? tags}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token') ?? '';

      String? atributoGanho;
      if (concluida && tags != null && tags.isNotEmpty) {
        atributoGanho = tags.first; // Ex: 'Intelecto', 'Força', etc.
      }

      final response = await http.put(
        Uri.parse('$baseUrl/tarefas/$missaoId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
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

      // Como o XP pertence ao Usuário, enviamos para a API de Autenticação!
      const authApiUrl = 'https://api-autenticacao-production.up.railway.app';

      final response = await http.post(
        Uri.parse('$authApiUrl/hiperfoco/sessao'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'duracaoMinutos': duracaoMinutos,
          'xpBonus': xpBonus, // Adicionamos o envio do bônus de XP da ofensiva
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