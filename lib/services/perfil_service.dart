import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PerfilService {
  static String get baseUrl => 'https://api-autenticacao-production.up.railway.app';

  static Future<Map<String, dynamic>> buscarPerfil() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token') ?? '';
      final savedName = prefs.getString('user_name');
      final userId = prefs.getString('user_id') ?? '';

      final response = await http.get(
        Uri.parse('$baseUrl/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        String nomeUsuario = savedName ?? 'Herói';
        if (data['user'] != null && data['user']['name'] != null) {
          nomeUsuario = data['user']['name'];
        }
        
        String emailUsuario = '';
        if (data['user'] != null && data['user']['email'] != null) {
          emailUsuario = data['user']['email'];
        } else if (data['email'] != null) {
          emailUsuario = data['email'];
        }

        // Dados iniciais pegos da API de Autenticação (Fallback)
        int xpFinal = data['xp'] ?? 0;
        int nivelFinal = data['nivel'] ?? 1;
        int tituloEquipadoId = data['tituloEquipadoId'] ?? 1;
        int itemEquipadoId = data['itemEquipadoId'] ?? 0;

        Map<String, String> estatisticasMap = {
          'foco': '0', 'disciplina': '0', 'intelecto': '0', 'forca': '0', 'consistencia': '0'
        };

        if (data['estatisticas'] != null) {
          estatisticasMap['foco'] = data['estatisticas']['foco']?.toString() ?? '0';
          estatisticasMap['disciplina'] = data['estatisticas']['disciplina']?.toString() ?? '0';
          estatisticasMap['intelecto'] = data['estatisticas']['intelecto']?.toString() ?? '0';
          estatisticasMap['forca'] = data['estatisticas']['forca']?.toString() ?? '0';
          estatisticasMap['consistencia'] = data['estatisticas']['consistencia']?.toString() ?? '0';
        }

        // NOVO: Busca os dados reais de RPG (XP, Nível e Atributos) da API Geral
        try {
          final geralUrl = 'https://api-geral-production.up.railway.app';
          final heroResp = await http.get(
            Uri.parse('$geralUrl/heroi?userId=$userId'),
            headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
          );
          if (heroResp.statusCode == 200) {
            final heroData = jsonDecode(heroResp.body);
            xpFinal = heroData['xpAtual'] ?? xpFinal;
            nivelFinal = heroData['nivelAtual'] ?? nivelFinal;
            tituloEquipadoId = heroData['tituloId'] ?? tituloEquipadoId;
            itemEquipadoId = heroData['itemAvatarId'] ?? itemEquipadoId;
            
            estatisticasMap['foco'] = heroData['foco']?.toString() ?? estatisticasMap['foco']!;
            estatisticasMap['disciplina'] = heroData['disciplina']?.toString() ?? estatisticasMap['disciplina']!;
            estatisticasMap['intelecto'] = heroData['intelecto']?.toString() ?? estatisticasMap['intelecto']!;
            estatisticasMap['forca'] = heroData['forca']?.toString() ?? estatisticasMap['forca']!;
            estatisticasMap['consistencia'] = heroData['consistencia']?.toString() ?? estatisticasMap['consistencia']!;
          }
        } catch (e) {
          debugPrint('Aviso: Falha ao buscar dados do RPG na API Geral: $e');
        }

        List<dynamic> conquistasRecentes = data['tarefasConcluidas'] ?? data['conquistasRecentes'] ?? data['historico'] ?? [];

        return {
          'nivel': nivelFinal,
          'xp': xpFinal,
          'dataCriacao': data['createdAt'] ?? data['criadoEm'] ?? data['created_at'],
          'tituloEquipadoId': tituloEquipadoId,
          'itemEquipadoId': itemEquipadoId,
          'nomeUsuario': nomeUsuario,
          'emailUsuario': emailUsuario,
          'estatisticas': estatisticasMap,
          'itensDesbloqueados': data['itensDesbloqueados'] ?? [],
          'conquistasRecentes': conquistasRecentes,
        };
      } else {
        throw Exception('Falha ao buscar perfil: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> atualizarPerfil({String? nome, String? email, String? senha}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token') ?? '';
      final userId = prefs.getString('user_id') ?? '';

      Map<String, dynamic> body = {};
      if (nome != null && nome.isNotEmpty) body['name'] = nome;
      if (email != null && email.isNotEmpty) body['email'] = email;
      if (senha != null && senha.isNotEmpty) body['password'] = senha;

      final response = await http.put(
        // Substituindo o /me pela rota com o ID. 
        // Se o seu back-end estiver em inglês, troque 'usuarios' por 'users'
        Uri.parse('$baseUrl/usuarios/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        if (nome != null && nome.isNotEmpty) {
          await prefs.setString('user_name', nome);
        }
      } else {
        throw Exception('Falha ao atualizar perfil: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}