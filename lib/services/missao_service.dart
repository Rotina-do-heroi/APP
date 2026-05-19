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
<<<<<<< HEAD
      final userId = prefs.getString('user_id') ?? '';
=======
      final userId = prefs.getString('user_id');  
>>>>>>> 77a35a334ecf7622f3d158f8c6915efc34b60bde

      final response = await http.delete(
        Uri.parse('$baseUrl/missoes/$missaoId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
<<<<<<< HEAD
        body: jsonEncode({'userId': userId}),
=======
        body: jsonEncode({
          'userId': userId, 
        }),
>>>>>>> 77a35a334ecf7622f3d158f8c6915efc34b60bde
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Falha ao deletar missão: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<bool> atualizarProgressoMissao(String missaoId, int sessoesConcluidas, bool concluida, {List<String>? tags, String? prioridade}) async {
    bool ganhouConsistencia = false;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token') ?? '';
      final userId = prefs.getString('user_id') ?? '';

<<<<<<< HEAD
      if (concluida) {
        // Usa a rota específica que conclui a missão e te dá o XP no back-end
        final response = await http.patch(
          Uri.parse('$baseUrl/missoes/$missaoId/concluir'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({'userId': userId}),
        );
        if (response.statusCode != 200 && response.statusCode != 201) {
          throw Exception('Falha ao concluir missão: Status ${response.statusCode} | Resposta: ${response.body}');
        }

        // --- ATUALIZAÇÃO DE ATRIBUTO PELO FRONT-END ---
        String? atributoTag;
        if (tags != null && tags.isNotEmpty) {
          String tagStr = tags.first.toLowerCase();
          if (tagStr.contains('for')) atributoTag = 'forca';
          else if (tagStr.contains('int')) atributoTag = 'intelecto';
          else if (tagStr.contains('con')) atributoTag = 'consistencia';
        }

        bool ganhouCoragem = prioridade != null && prioridade.toUpperCase() == 'ALTA';

        final heroResp = await http.get(
          Uri.parse('$baseUrl/heroi?userId=$userId'),
          headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        );
        
        if (heroResp.statusCode == 200) {
          final heroData = jsonDecode(heroResp.body);
          Map<String, dynamic> updateData = {'userId': userId};
          
          // 1. Atributo principal da Missão
          if (atributoTag != null) {
            updateData[atributoTag] = (heroData[atributoTag] ?? 0) + 1;
          }
          
          // 2. Passiva de Coragem (salvo como 'disciplina' no banco)
          if (ganhouCoragem) updateData['disciplina'] = (heroData['disciplina'] ?? 0) + 1;

          // 3. Passiva de Consistência (1x por dia)
          final hoje = DateTime.now().toIso8601String().substring(0, 10); // Pega apenas AAAA-MM-DD
          final ultimaConsistencia = prefs.getString('ultima_consistencia_$userId');
          
          if (ultimaConsistencia != hoje) {
            ganhouConsistencia = true;
            updateData['consistencia'] = (heroData['consistencia'] ?? 0) + 1;
          }

          if (updateData.length > 1) {
            // Envia as atualizações juntas para a API
            final patchResp = await http.patch(
              Uri.parse('$baseUrl/heroi'),
              headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
              body: jsonEncode(updateData),
            );

            if ((patchResp.statusCode == 200 || patchResp.statusCode == 204) && ganhouConsistencia) {
              await prefs.setString('ultima_consistencia_$userId', hoje);
            }
          }
        }
      } else {
        // Atualiza a missão no back-end
        final response = await http.patch(
          Uri.parse('$baseUrl/missoes/$missaoId'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({'userId': userId, 'concluida': concluida}),
        );
        if (response.statusCode != 200 && response.statusCode != 204) {
          throw Exception('Falha ao atualizar missão: Status ${response.statusCode} | Resposta: ${response.body}');
        }
=======
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
>>>>>>> 77a35a334ecf7622f3d158f8c6915efc34b60bde
      }
      return ganhouConsistencia;
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> salvarSessaoHiperfoco(int duracaoMinutos, {int xpBonus = 0, bool sessaoCompleta = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token') ?? '';
      final userId = prefs.getString('user_id') ?? '';

<<<<<<< HEAD
      var response = await http.post(
        // Aponta para a API Geral, na rota exata que você criou no seu Node.js
        Uri.parse('$baseUrl/hiperfoco/sessao'), 
=======
      final response = await http.post(
        Uri.parse('$baseUrl/hiperfoco/sessao'),
>>>>>>> 77a35a334ecf7622f3d158f8c6915efc34b60bde
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'duracaoMinutos': duracaoMinutos,
          'xpBonus': xpBonus,
        }),
      );

      // Se a API retornar 404 porque o usuário ainda não tem um HeroPerfil no banco de dados, criamos um!
      if (response.statusCode == 404 && response.body.contains('Crie um perfil primeiro')) {
        debugPrint('Herói não encontrado. Criando perfil automaticamente na API...');
        final createProfileResponse = await http.post(
          Uri.parse('$baseUrl/heroi'),
          headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
          body: jsonEncode({'userId': userId}),
        );

        if (createProfileResponse.statusCode == 201 || createProfileResponse.statusCode == 200) {
          debugPrint('Perfil criado! Retentando salvar a sessão de foco...');
          // Tenta salvar a sessão novamente
          response = await http.post(
            Uri.parse('$baseUrl/hiperfoco/sessao'), 
            headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
            body: jsonEncode({'duracaoMinutos': duracaoMinutos, 'xpBonus': xpBonus}),
          );
        }
      }

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Falha ao salvar sessão: Status ${response.statusCode} | Resposta: ${response.body}');
      }

      // Se for uma sessão completa, garante o +1 de Foco
      if (sessaoCompleta) {
        try {
          final heroResp = await http.get(
            Uri.parse('$baseUrl/heroi?userId=$userId'),
            headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
          );
          if (heroResp.statusCode == 200) {
            final heroData = jsonDecode(heroResp.body);
            await http.patch(
              Uri.parse('$baseUrl/heroi'),
              headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
              body: jsonEncode({'userId': userId, 'foco': (heroData['foco'] ?? 0) + 1}),
            );
          }
        } catch (e) {
          debugPrint('Erro ao atualizar foco da sessão: $e');
        }
      }
    } catch (e) {
      rethrow;
    }
  }
}