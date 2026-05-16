import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart'; // Para navegar até a TelaPrincipal após o login
import 'tela_recuperar_senha.dart'; // Para navegar até a tela de recuperação de senha

class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  // Variável para alternar entre "Login" e "Cadastro"
  bool _isLogin = true;
  bool _isLoading = false; // Para controlar o estado de carregamento

  // Controladores para capturar os textos dos campos
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    // Define a URL base dinamicamente (10.0.2.2 para emulador Android, localhost para web/desktop)
    String baseUrl = 'https://api-autenticacao-production.up.railway.app';
    if (!kIsWeb && Platform.isAndroid) {
      baseUrl = 'http://10.0.2.2:3000';
    }

    final url = Uri.parse(_isLogin ? '$baseUrl/login' : '$baseUrl/register');
    
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          // Os nomes aqui precisam ser EXATAMENTE iguais ao que o Node espera:
          if (!_isLogin) 'name': _nomeController.text, 
          'email': _emailController.text,
          'password': _senhaController.text, 
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Extrai e salva o Token JWT localmente
        final responseData = jsonDecode(response.body);
        final token = responseData['token'];
        if (token != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('jwt_token', token);

          // Extrai e salva o Nome do usuário para uso offline/fallback
          String? userName = responseData['user']?['name'];
          if (userName == null && responseData['user'] != null) userName = responseData['user']['name'] ?? responseData['user']['nome'];
          if (userName == null && responseData['usuario'] != null) userName = responseData['usuario']['nome'] ?? responseData['usuario']['name'];
          if (userName != null) {
            await prefs.setString('user_name', userName);
           await prefs.setString('user_id', responseData['user']?['id'].toString() ?? '');
          }
        }

        if (_isLogin) {
          // Login com sucesso, vai para o app
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const TelaPrincipal()),
            );
          }
        } else {
          // Cadastro com sucesso, volta para o login para o usuário gerar seu token
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Herói criado com sucesso! Faça seu login.'), backgroundColor: Colors.green),
            );
            setState(() {
              _isLogin = true; // Muda a visualização para Login
              _senhaController.clear(); // Limpa a senha por segurança
            });
          }
        }
      } else {
        // Tenta pegar a mensagem de erro específica do backend
        final responseData = jsonDecode(response.body);
        // Capta o erro corretamente, e se for erro 500 do Node.js, avisa na tela.
        final errorMessage = responseData['error'] ?? responseData['message'] ?? 'Erro do Servidor. Código: ${response.statusCode}';
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage), backgroundColor: Colors.redAccent),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao conectar com a API: $e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A24) : const Color(0xFFF3F4F6),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Ícone / Logo do app
                const Icon(
                  Icons.videogame_asset,
                  size: 80,
                  color: Color(0xFF6B4EFF),
                ),
                const SizedBox(height: 24),
                
                // Título Gamificado
                Text(
                  _isLogin ? 'Bem-vindo de volta, Herói!' : 'Inicie sua Jornada',
                  textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isLogin 
                      ? 'Faça login para continuar sua evolução.' 
                      : 'Crie sua conta e transforme sua rotina em jogo.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 48),

                // Campo de Nome (Apenas no Cadastro)
                if (!_isLogin) ...[
                  _buildTextField(
                    label: 'Nome de Herói',
                    icone: Icons.person_outline,
                    obscureText: false,
                    isDark: isDark,
                    controller: _nomeController,
                  ),
                  const SizedBox(height: 16),
                ],

                // Campo de E-mail
                _buildTextField(
                  label: 'E-mail',
                  icone: Icons.email_outlined,
                  obscureText: false,
                  isDark: isDark,
                  controller: _emailController,
                ),
                const SizedBox(height: 16),

                // Campo de Senha
                _buildTextField(
                  label: 'Senha',
                  icone: Icons.lock_outline,
                  obscureText: true,
                  isDark: isDark,
                  controller: _senhaController,
                ),
                const SizedBox(height: 32),

                // Botão de Ação Principal
                GestureDetector(
                  onTap: _isLoading ? null : _entrar, // Desabilita o clique durante o carregamento
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6B4EFF),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6B4EFF).withOpacity(0.4),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: _isLoading
                        ? const Center(
                            child: SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                            ),
                          )
                        : Text(
                            _isLogin ? 'ENTRAR' : 'CRIAR CONTA',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.5,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),

                // Alternar entre Login e Cadastro
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isLogin ? 'Não tem uma conta? ' : 'Já é um herói? ',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isLogin = !_isLogin;
                        });
                      },
                      child: Text(
                        _isLogin ? 'Cadastre-se' : 'Entrar',
                        style: const TextStyle(
                          color: Color(0xFF4ADE80), // Verde de destaque
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                
                // Botão "Esqueci minha senha"
                if (_isLogin) ...[
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const TelaRecuperarSenha()),
                      );
                    },
                    child: const Text(
                      'Esqueci minha senha',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Função construtora padronizada para os Inputs (estilo dark)
  Widget _buildTextField({required String label, required IconData icone, required bool obscureText, required bool isDark, TextEditingController? controller}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icone, color: Colors.grey),
        filled: true,
        fillColor: isDark ? const Color(0xFF1E1E2A) : Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? const Color(0xFF252536) : Colors.grey.shade300, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6B4EFF), width: 1.5),
        ),
      ),
    );
  }
}