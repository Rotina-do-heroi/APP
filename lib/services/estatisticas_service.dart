import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EstatisticasService {
  // ============================================================================
  // 🌟 INÍCIO DO PADRÃO SINGLETON (SINGLETON PATTERN) 🌟
  // Este padrão garante que apenas UMA instância desta classe exista na memória
  // durante toda a execução do aplicativo, economizando recursos e centralizando
  // o acesso aos dados.
  // ============================================================================
  
  // 1. Instância Privada Estática: A única que existirá no app.
  static final EstatisticasService _instancia = EstatisticasService._construtorPrivado();

  // 2. Construtor Privado: Impede que usem "EstatisticasService()" em outras telas.
  EstatisticasService._construtorPrivado();

  // 3. Ponto de Acesso Global (Getter): Como as outras telas acessam o serviço.
  static EstatisticasService get instance => _instancia;
  
  // ============================================================================
  // 🛑 FIM DO PADRÃO SINGLETON 🛑
  // ============================================================================

  // Apontando corretamente para a API de Autenticação, onde ficam os dados do usuário
  String get baseUrl {
    String url = 'https://api-autenticacao-production.up.railway.app';

    return url;
  }

  // Removido o 'static', pois agora usamos a instância do Singleton para chamar o método
  Future<Map<String, double>> buscarEstatisticas() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token') ?? '';

      final response = await http.get(
        Uri.parse('$baseUrl/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final estatisticas = data['estatisticas'] ?? {};
        
        return {
          'foco': (estatisticas['foco'] ?? 0).toDouble(),
          'disciplina': (estatisticas['disciplina'] ?? 0).toDouble(),
          'intelecto': (estatisticas['intelecto'] ?? 0).toDouble(),
          'forca': (estatisticas['forca'] ?? 0).toDouble(),
          'consistencia': (estatisticas['consistencia'] ?? 0).toDouble(),
        };
      } else {
        throw Exception('Falha ao buscar estatísticas: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}