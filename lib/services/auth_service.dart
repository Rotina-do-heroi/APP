import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'https://api-autenticacao-production.up.railway.app';

  static Future<void> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');
    
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    await _processResponse(response);
  }

  static Future<void> register(String name, String email, String password) async {
    final url = Uri.parse('$baseUrl/register');
    
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );

    await _processResponse(response);
  }

  static Future<void> _processResponse(http.Response response) async {
    final responseData = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final token = responseData['token'];
      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);

        String? userName = responseData['user']?['name'] ?? responseData['user']?['nome'] ?? responseData['usuario']?['nome'] ?? responseData['usuario']?['name'];
        if (userName != null) {
          await prefs.setString('user_name', userName);
          await prefs.setString('user_id', responseData['user']?['id']?.toString() ?? '');
        }
      }
    } else {
      final errorMessage = responseData['error'] ?? responseData['message'] ?? 'Erro do Servidor. Código: ${response.statusCode}';
      throw Exception(errorMessage);
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await prefs.remove('user_name');
    await prefs.remove('user_id');
  }

  static Future<Map<String, dynamic>> enviarEmailRecuperacao(String email) async {
    final url = Uri.parse('$baseUrl/forgot-password');
    
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    ).timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        throw Exception('Timeout: Servidor não respondeu');
      },
    );

    final data = jsonDecode(response.body);
    if (data['success'] == true) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Erro ao enviar código');
    }
  }

  static Future<void> redefinirSenha(String email, String code, String newPassword) async {
    final url = Uri.parse('$baseUrl/reset-password');
    
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'code': code, 'newPassword': newPassword}),
    );

    final data = jsonDecode(response.body);
    if (data['success'] != true) {
      throw Exception(data['error'] ?? data['message'] ?? 'Erro ao redefinir senha');
    }
  }
}