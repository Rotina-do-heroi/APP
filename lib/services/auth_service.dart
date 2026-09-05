import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Exceção customizada para erros de Autenticação
class AuthException implements Exception {
  final String message;
  final int? statusCode;
  AuthException(this.message, {this.statusCode});

  @override
  String toString() => 'AuthException: $message (Status: $statusCode)';
}

class AuthService {
  static String get _baseUrl => dotenv.env['AUTH_API_URL'] ?? '';

  /// Centraliza os headers padrão para requisições de autenticação
  static Map<String, String> _getHeaders() => {
    'Content-Type': 'application/json',
  };

  /// Realiza o login do usuário e persiste o token JWT e dados básicos
  static Future<void> login(String email, String password) async {
    try {
      final url = Uri.parse('$_baseUrl/login');
      final response = await http.post(
        url,
        headers: _getHeaders(),
        body: jsonEncode({'email': email, 'password': password}),
      );

      await _processAuthResponse(response);
    } catch (e) {
      debugPrint('Error in AuthService.login: $e');
      rethrow;
    }
  }

  /// Registra um novo herói na plataforma
  static Future<void> register(String name, String email, String password) async {
    try {
      final url = Uri.parse('$_baseUrl/register');
      final response = await http.post(
        url,
        headers: _getHeaders(),
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      );

      await _processAuthResponse(response);
    } catch (e) {
      debugPrint('Error in AuthService.register: $e');
      rethrow;
    }
  }

  /// Processa a resposta do servidor para Login e Registro
  static Future<void> _processAuthResponse(http.Response response) async {
    final responseData = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final token = responseData['token'];
      if (token == null) throw AuthException('Token não recebido do servidor');

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', token);

      // Mapeamento flexível de Nome e ID para suportar variações do Backend
      final String? userName = responseData['user']?['name'] ?? 
                               responseData['usuario']?['nome'] ?? 
                               responseData['name'];
                               
      final String? userId = responseData['user']?['id']?.toString() ?? 
                             responseData['usuario']?['id']?.toString() ?? 
                             responseData['id']?.toString();

      if (userName != null) await prefs.setString('user_name', userName);
      if (userId != null) await prefs.setString('user_id', userId);
    } else {
      final message = responseData['error'] ?? responseData['message'] ?? 'Erro desconhecido no servidor';
      throw AuthException(message, statusCode: response.statusCode);
    }
  }

  /// Remove as credenciais e encerra a sessão local
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await prefs.remove('user_name');
    await prefs.remove('user_id');
  }

  /// Solicita o código de recuperação de senha por e-mail
  static Future<Map<String, dynamic>> enviarEmailRecuperacao(String email) async {
    try {
      final url = Uri.parse('$_baseUrl/forgot-password');
      final response = await http.post(
        url,
        headers: _getHeaders(),
        body: jsonEncode({'email': email}),
      ).timeout(const Duration(seconds: 30));

      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return data;
      } else {
        throw AuthException(data['message'] ?? 'Falha ao enviar e-mail de recuperação');
      }
    } catch (e) {
      debugPrint('Error in enviarEmailRecuperacao: $e');
      rethrow;
    }
  }

  /// Redefine a senha utilizando o código recebido por e-mail
  static Future<void> redefinirSenha(String email, String code, String newPassword) async {
    try {
      final url = Uri.parse('$_baseUrl/reset-password');
      final response = await http.post(
        url,
        headers: _getHeaders(),
        body: jsonEncode({
          'email': email, 
          'code': code, 
          'newPassword': newPassword
        }),
      );

      final data = jsonDecode(response.body);
      if (data['success'] != true) {
        throw AuthException(data['error'] ?? data['message'] ?? 'Erro ao redefinir senha');
      }
    } catch (e) {
      debugPrint('Error in redefinirSenha: $e');
      rethrow;
    }
  }
}
