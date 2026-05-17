import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EstatisticasService {
  // Usando a mesma URL base do MissaoService para consistência
  static const String baseUrl = 'https://api-geral-production.up.railway.app';

  static Future<Map<String, double>> buscarEstatisticas() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token') ?? '';

      final response = await http.get(
        Uri.parse('$baseUrl/estatisticas'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'foco': (data['foco'] ?? 0).toDouble(),
          'disciplina': (data['disciplina'] ?? 0).toDouble(),
          'intelecto': (data['intelecto'] ?? 0).toDouble(),
          'forca': (data['forca'] ?? 0).toDouble(),
          'consistencia': (data['consistencia'] ?? 0).toDouble(),
        };
      } else {
        throw Exception('Falha ao buscar estatísticas: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}