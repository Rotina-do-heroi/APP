import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// =====================================================================
/// PADRÃO SINGLETON - 
/// =====================================================================
/// Transformamos o [EstatisticasService] em um Singleton.
/// O padrão Singleton garante que esta classe tenha apenas UMA ÚNICA 
/// instância em toda a aplicação, economizando memória e centralizando
/// o acesso aos dados ou configurações.
/// =====================================================================
class EstatisticasService {
  // ------------------------------------------------------------------
  // 1. A INSTÂNCIA PRIVADA E ESTÁTICA (O SEGREDO DO SINGLETON)
  // ------------------------------------------------------------------
  // Criamos uma variável estática e privada (indicada pelo '_').
  // Ela guarda a ÚNICA instância que existirá desta classe na memória. 
  static final EstatisticasService _instancia = EstatisticasService._internal();

  // ------------------------------------------------------------------
  // 2. O CONSTRUTOR FACTORY PÚBLICO (A PORTA DE ENTRADA)
  // ------------------------------------------------------------------
  // Em Dart, usamos a palavra-chave 'factory'. Ela permite que o construtor 
  // decida o que retornar, em vez de sempre alocar um novo espaço na memória.
  // Sempre que alguém chamar `EstatisticasService()`, receberá a `_instancia`.
  factory EstatisticasService() {
    return _instancia;
  }

  // ------------------------------------------------------------------
  // 3. O CONSTRUTOR PRIVADO (A BLINDAGEM)
  // ------------------------------------------------------------------
  // Este é um construtor nomeado privado (`._internal`). 
  // Impede que outros programadores criem novas instâncias acidentalmente.
  EstatisticasService._internal();

  // ==================================================================
  // DADOS E MÉTODOS DA INSTÂNCIA (O que o Singleton faz de fato)
  // ==================================================================
  // Agora estes métodos pertencem à instância única e não são estáticos.
  
  String get baseUrl => dotenv.env['AUTH_API_URL'] ?? '';

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