import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PerfilService {
  // ============================================================================
  // 🌟 INÍCIO DO PADRÃO SINGLETON (SINGLETON PATTERN) 🌟
  // Este padrão garante que apenas UMA instância desta classe exista na memória
  // durante toda a execução do aplicativo, economizando recursos e centralizando
  // o acesso aos dados.
  // ============================================================================
  
  // 1. Instância Privada Estática: A única que existirá no app.
  static final PerfilService _instancia = PerfilService._construtorPrivado();

  // 2. Construtor Privado: Impede que usem "PerfilService()" em outras telas.
  PerfilService._construtorPrivado();

  // 3. Ponto de Acesso Global (Getter): Como as outras telas acessam o serviço.
  static PerfilService get instance => _instancia;
  
  // ============================================================================
  // 🛑 FIM DO PADRÃO SINGLETON 🛑
  // ============================================================================

  String get baseUrl {
    String url = 'https://api-autenticacao-production.up.railway.app';
    if (!kIsWeb && Platform.isAndroid) {
      url = 'http://10.0.2.2:3000';
    }
    return url;
  }

  // Removido o 'static', pois agora usamos a instância do Singleton para chamar o método
  Future<Map<String, dynamic>> buscarPerfil() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token') ?? '';
      final savedName = prefs.getString('user_name');

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

        List<dynamic> conquistasRecentes = data['tarefasConcluidas'] ?? data['conquistasRecentes'] ?? data['historico'] ?? [];

        return {
          'nivel': data['nivel'] ?? 1,
          'xp': data['xp'] ?? 0,
          'dataCriacao': data['createdAt'] ?? data['criadoEm'] ?? data['created_at'],
          'tituloEquipadoId': data['tituloEquipadoId'] ?? 1,
          'itemEquipadoId': data['itemEquipadoId'] ?? 1,
          'nomeUsuario': nomeUsuario,
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
}