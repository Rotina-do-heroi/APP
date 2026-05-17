import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class InventarioService {
  // Define a URL base dinamicamente, mantendo a regra de plataformas
  static String get baseUrl => 'https://api-autenticacao-production.up.railway.app';

  static Future<Map<String, dynamic>> buscarInventario() async {
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
        return jsonDecode(response.body);
      } else {
        throw Exception('Falha ao buscar inventário: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> equiparTitulo(int idTitulo) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token') ?? '';
      
      final response = await http.put(
        Uri.parse('$baseUrl/inventario/titulo'), 
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode({'tituloEquipadoId': idTitulo}),
      );

      if (response.statusCode != 200 && response.statusCode != 204) throw Exception('Falha ao equipar título');
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> equiparItem(int idItem) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token') ?? '';
      
      final response = await http.put(
        Uri.parse('$baseUrl/inventario/equipar'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode({'itemEquipadoId': idItem}),
      );

      if (response.statusCode != 200 && response.statusCode != 204) throw Exception('Falha ao equipar item');
    } catch (e) {
      rethrow;
    }
  }
}