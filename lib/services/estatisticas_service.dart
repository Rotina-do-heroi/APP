import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EstatisticasService {
  static String get baseUrl => 'https://api-autenticacao-production.up.railway.app';

  static Future<Map<String, double>> buscarEstatisticas() async {
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