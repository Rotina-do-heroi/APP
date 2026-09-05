import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/missao.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Exceção customizada para erros de API e rede
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

class MissaoService {
  static String get _baseUrl => dotenv.env['GERAL_API_URL'] ?? '';

  /// Centraliza a criação de Headers para evitar duplicação de lógica de autenticação
  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token') ?? '';
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Centraliza a recuperação do ID do usuário com validação de segurança
  static Future<String> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    if (userId == null || userId.isEmpty) {
      throw ApiException('Usuário não autenticado. ID não encontrado.');
    }
    return userId;
  }

  /// Busca a lista de missões do usuário no servidor
  static Future<List<Missao>> obterMissoes() async {
    try {
      final userId = await _getUserId();
      final headers = await _getHeaders();
      
      final response = await http.get(
        Uri.parse('$_baseUrl/missoes?userId=$userId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((json) => Missao.fromJson(json)).toList();
      }
      
      throw ApiException('Falha ao carregar missões', statusCode: response.statusCode);
    } catch (e) {
      debugPrint('Error in obterMissoes: $e');
      rethrow;
    }
  }

  /// Adiciona uma nova missão e retorna o ID gerado pelo banco
  static Future<String?> adicionarMissao(Missao missao) async {
    try {
      final userId = await _getUserId();
      final headers = await _getHeaders();

      final response = await http.post(
        Uri.parse('$_baseUrl/missoes'),
        headers: headers,
        body: jsonEncode({
          'userId': userId,
          'titulo': missao.titulo,
          'descricao': missao.descricao,
          'prioridade': missao.prioridade.toUpperCase(),
          'sessoesNecessarias': missao.sessoesNecessarias,
          'sessoesConcluidas': missao.sessoesConcluidas,
          'diasRepeticao': missao.diasRepeticao,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['id']?.toString() ?? data['tarefa']?['id']?.toString();
      }
      
      throw ApiException('Erro ao criar missão', statusCode: response.statusCode);
    } catch (e) {
      debugPrint('Error in adicionarMissao: $e');
      rethrow;
    }
  }

  /// Remove uma missão permanentemente
  static Future<void> deletarMissao(String missaoId) async {
    try {
      final userId = await _getUserId();
      final headers = await _getHeaders();

      final response = await http.delete(
        Uri.parse('$_baseUrl/missoes/$missaoId'),
        headers: headers,
        body: jsonEncode({'userId': userId}),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ApiException('Erro ao deletar missão', statusCode: response.statusCode);
      }
    } catch (e) {
      debugPrint('Error in deletarMissao: $e');
      rethrow;
    }
  }

  /// Atualiza o progresso de uma missão ou a marca como concluída
  static Future<bool> atualizarProgressoMissao(
    String missaoId, 
    int sessoesConcluidas, 
    bool concluida, 
    {List<String>? tags, String? prioridade}
  ) async {
    try {
      final userId = await _getUserId();
      final headers = await _getHeaders();

      // Fluxo de Conclusão: Envolve XP e Recompensas
      if (concluida) {
        return await _concluirMissaoComRecompensas(missaoId, userId, headers, tags, prioridade);
      }

      // Fluxo de Atualização Simples: Apenas persiste as sessões atuais
      final response = await http.patch(
        Uri.parse('$_baseUrl/missoes/$missaoId'),
        headers: headers,
        body: jsonEncode({
          'userId': userId, 
          'concluida': false, 
          'sessoesConcluidas': sessoesConcluidas
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
         throw ApiException('Falha ao atualizar missão', statusCode: response.statusCode);
      }

      return false; // Não houve ganho de consistência diária neste fluxo
    } catch (e) {
      debugPrint('Error in atualizarProgressoMissao: $e');
      rethrow;
    }
  }

  /// Encapsula a lógica de finalização de missão e processamento de recompensas
  static Future<bool> _concluirMissaoComRecompensas(
    String missaoId, 
    String userId, 
    Map<String, String> headers,
    List<String>? tags,
    String? prioridade
  ) async {
    final respConcluir = await http.patch(
      Uri.parse('$_baseUrl/missoes/$missaoId/concluir'),
      headers: headers,
      body: jsonEncode({'userId': userId}),
    );

    if (respConcluir.statusCode != 200 && respConcluir.statusCode != 201) {
      throw ApiException('Falha ao concluir missão no servidor', statusCode: respConcluir.statusCode);
    }

    // Após concluir, processamos a evolução do personagem baseada na missão
    return await _processarAtributosHeroi(userId, headers, tags, prioridade);
  }

  /// Lógica de evolução de RPG (Atributos e Consistência)
  static Future<bool> _processarAtributosHeroi(
    String userId, 
    Map<String, String> headers, 
    List<String>? tags, 
    String? prioridade
  ) async {
    final prefs = await SharedPreferences.getInstance();
    
    // 1. Busca estado atual do Herói para incrementar
    final heroResp = await http.get(
      Uri.parse('$_baseUrl/heroi?userId=$userId'),
      headers: headers,
    );

    if (heroResp.statusCode != 200) return false;
    final heroData = jsonDecode(heroResp.body);

    Map<String, dynamic> updateData = {'userId': userId};
    bool ganhouConsistencia = false;

    // 2. Incremento de Atributo baseado em Tags (Força, Intelecto, etc)
    if (tags != null && tags.isNotEmpty) {
      final tag = tags.first.toLowerCase();
      if (tag.contains('for')) updateData['forca'] = (heroData['forca'] ?? 0) + 1;
      else if (tag.contains('int')) updateData['intelecto'] = (heroData['intelecto'] ?? 0) + 1;
    }

    // 3. Bônus de Disciplina (Missões de Alta Prioridade)
    if (prioridade?.toUpperCase() == 'ALTA') {
      updateData['disciplina'] = (heroData['disciplina'] ?? 0) + 1;
    }

    // 4. Verificação de Consistência Diária (1x por dia)
    final hoje = DateTime.now().toIso8601String().substring(0, 10);
    if (prefs.getString('ultima_consistencia_$userId') != hoje) {
      ganhouConsistencia = true;
      updateData['consistencia'] = (heroData['consistencia'] ?? 0) + 1;
    }

    // 5. Envia todas as atualizações de atributos em uma única chamada PATCH
    if (updateData.length > 1) {
      final patchResp = await http.patch(
        Uri.parse('$_baseUrl/heroi'),
        headers: headers,
        body: jsonEncode(updateData),
      );
      
      if (patchResp.statusCode == 200 && ganhouConsistencia) {
        await prefs.setString('ultima_consistencia_$userId', hoje);
      }
    }

    return ganhouConsistencia;
  }

  /// Salva uma sessão de foco no servidor e gerencia recompensas de tempo
  static Future<void> salvarSessaoHiperfoco(int duracaoMinutos, {int xpBonus = 0, bool sessaoCompleta = false}) async {
    try {
      final userId = await _getUserId();
      final headers = await _getHeaders();

      var response = await http.post(
        Uri.parse('$_baseUrl/hiperfoco/sessao'), 
        headers: headers,
        body: jsonEncode({
          'duracaoMinutos': duracaoMinutos,
          'xpBonus': xpBonus,
        }),
      );

      // Auto-reparo: Se o perfil do herói não existir, cria e retenta
      if (response.statusCode == 404 && response.body.contains('Crie um perfil primeiro')) {
        final createProfileResponse = await http.post(
          Uri.parse('$_baseUrl/heroi'),
          headers: headers,
          body: jsonEncode({'userId': userId}),
        );

        if (createProfileResponse.statusCode == 201 || createProfileResponse.statusCode == 200) {
          response = await http.post(
            Uri.parse('$_baseUrl/hiperfoco/sessao'), 
            headers: headers,
            body: jsonEncode({'duracaoMinutos': duracaoMinutos, 'xpBonus': xpBonus}),
          );
        }
      }

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ApiException('Falha ao salvar sessão', statusCode: response.statusCode);
      }

      // Se a sessão foi concluída integralmente (25min), concede +1 Foco
      if (sessaoCompleta) {
        final heroResp = await http.get(
          Uri.parse('$_baseUrl/heroi?userId=$userId'),
          headers: headers,
        );
        if (heroResp.statusCode == 200) {
          final heroData = jsonDecode(heroResp.body);
          await http.patch(
            Uri.parse('$_baseUrl/heroi'),
            headers: headers,
            body: jsonEncode({'userId': userId, 'foco': (heroData['foco'] ?? 0) + 1}),
          );
        }
      }
    } catch (e) {
      debugPrint('Error in salvarSessaoHiperfoco: $e');
      rethrow;
    }
  }
}
