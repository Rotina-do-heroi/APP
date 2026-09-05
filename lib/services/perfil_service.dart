import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Exceção customizada para erros de Perfil
class PerfilException implements Exception {
  final String message;
  final int? statusCode;
  PerfilException(this.message, {this.statusCode});

  @override
  String toString() => 'PerfilException: $message (Status: $statusCode)';
}

class PerfilService {
  // Puxa as URLs das variáveis de ambiente (.env)
  static String get _authBaseUrl => dotenv.env['AUTH_API_URL'] ?? 'https://api-autenticacao-production.up.railway.app';
  static String get _geralBaseUrl => dotenv.env['GERAL_API_URL'] ?? 'https://api-geral-production.up.railway.app';

  /// Centraliza headers para evitar duplicação
  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token') ?? '';
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Busca o perfil completo agregando dados da API de Auth e da API Geral (RPG)
  static Future<Map<String, dynamic>> buscarPerfil() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final headers = await _getHeaders();
      final userId = prefs.getString('user_id') ?? '';

      // 1. Busca dados básicos (Autenticação)
      final authResp = await http.get(
        Uri.parse('$_authBaseUrl/me'),
        headers: headers,
      );

      if (authResp.statusCode != 200) {
        throw PerfilException('Falha ao obter dados básicos', statusCode: authResp.statusCode);
      }

      final authData = jsonDecode(authResp.body);
      
      // Processamento de dados de fallback
      String nomeUsuario = prefs.getString('user_name') ?? authData['user']?['name'] ?? 'Herói';
      String emailUsuario = authData['user']?['email'] ?? authData['email'] ?? '';
      
      // Valores padrão de RPG caso a API Geral falhe
      int xpFinal = authData['xp'] ?? 0;
      int nivelFinal = authData['nivel'] ?? 1;
      int tituloId = authData['tituloEquipadoId'] ?? 1;
      int itemAvatarId = authData['itemEquipadoId'] ?? 0;

      Map<String, String> stats = {
        'foco': '0', 'disciplina': '0', 'intelecto': '0', 'forca': '0', 'consistencia': '0'
      };

      // 2. Busca dados reais de RPG na API Geral (Sobrescreve o fallback se sucesso)
      try {
        final heroResp = await http.get(
          Uri.parse('$_geralBaseUrl/heroi?userId=$userId'),
          headers: headers,
        );
        
        if (heroResp.statusCode == 200) {
          final heroData = jsonDecode(heroResp.body);
          xpFinal = heroData['xpAtual'] ?? xpFinal;
          nivelFinal = heroData['nivelAtual'] ?? nivelFinal;
          tituloId = heroData['tituloId'] ?? tituloId;
          itemAvatarId = heroData['itemAvatarId'] ?? itemAvatarId;
          
          stats['foco'] = heroData['foco']?.toString() ?? '0';
          stats['disciplina'] = heroData['disciplina']?.toString() ?? '0';
          stats['intelecto'] = heroData['intelecto']?.toString() ?? '0';
          stats['forca'] = heroData['forca']?.toString() ?? '0';
          stats['consistencia'] = heroData['consistencia']?.toString() ?? '0';
        }
      } catch (e) {
        debugPrint('Aviso: API Geral indisponível, usando dados de fallback: $e');
      }

      return {
        'nivel': nivelFinal,
        'xp': xpFinal,
        'dataCriacao': authData['createdAt'] ?? authData['criadoEm'],
        'tituloEquipadoId': tituloId,
        'itemEquipadoId': itemAvatarId,
        'nomeUsuario': nomeUsuario,
        'emailUsuario': emailUsuario,
        'estatisticas': stats,
        'itensDesbloqueados': authData['itensDesbloqueados'] ?? [],
        'conquistasRecentes': authData['tarefasConcluidas'] ?? [],
      };
    } catch (e) {
      debugPrint('Error in buscarPerfil: $e');
      rethrow;
    }
  }

  /// Atualiza dados cadastrais do usuário
  static Future<void> atualizarPerfil({String? nome, String? email, String? senha}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final headers = await _getHeaders();
      final userId = prefs.getString('user_id') ?? '';

      Map<String, dynamic> body = {};
      if (nome != null && nome.isNotEmpty) body['name'] = nome;
      if (email != null && email.isNotEmpty) body['email'] = email;
      if (senha != null && senha.isNotEmpty) body['password'] = senha;

      final response = await http.put(
        Uri.parse('$_authBaseUrl/usuarios/$userId'),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        if (nome != null) await prefs.setString('user_name', nome);
      } else {
        throw PerfilException('Falha ao atualizar cadastro', statusCode: response.statusCode);
      }
    } catch (e) {
      debugPrint('Error in atualizarPerfil: $e');
      rethrow;
    }
  }
}
