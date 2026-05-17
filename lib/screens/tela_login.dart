import 'package:flutter/material.dart';
import '../main.dart'; // Para navegar até a TelaPrincipal após o login
import 'tela_recuperar_senha.dart'; // Para navegar até a tela de recuperação de senha
import '../services/auth_service.dart'; // Importa o novo serviço de autenticação

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

    try {
      if (_isLogin) {
        await AuthService.login(
          _emailController.text.trim(),
          _senhaController.text,
        );
        
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const TelaPrincipal()),
          );
        }
      } else {
        await AuthService.register(
          _nomeController.text.trim(),
          _emailController.text.trim(),
          _senhaController.text,
        );

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
    } catch (e) {
      if (mounted) {
        // Remove o prefixo padrão da classe Exception antes de mostrar na tela
        final mensagemErro = e.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mensagemErro), backgroundColor: Colors.redAccent),
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