import 'package:flutter/material.dart';
import '../main.dart'; // Importa o utilitário showCustomSnackBar
import 'tela_recuperar_senha.dart'; 
import '../services/auth_service.dart'; 

class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  bool _isLogin = true;
  bool _isLoading = false; 

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
          // BUG FIX: Usando utilitário global para evitar empilhamento
          showCustomSnackBar(context, 'Herói criado com sucesso! Faça seu login.', backgroundColor: Colors.green);
          setState(() {
            _isLogin = true; 
            _senhaController.clear(); 
          });
        }
      }
    } catch (e) {
      if (mounted) {
        final mensagemErro = e.toString().replaceAll('Exception: ', '').replaceAll('AuthException: ', '');
        // BUG FIX: Usando utilitário global para evitar empilhamento de erros
        showCustomSnackBar(context, mensagemErro, isError: true);
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
                const Icon(Icons.videogame_asset, size: 80, color: Color(0xFF6B4EFF)),
                const SizedBox(height: 24),
                Text(
                  _isLogin ? 'Bem-vindo de volta, Herói!' : 'Inicie sua Jornada',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87, fontFamily: 'monospace'),
                ),
                const SizedBox(height: 8),
                Text(
                  _isLogin ? 'Faça login para continuar sua evolução.' : 'Crie sua conta e transforme sua rotina em jogo.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 48),

                if (!_isLogin) ...[
                  _buildTextField(label: 'Nome de Herói', icone: Icons.person_outline, obscureText: false, isDark: isDark, controller: _nomeController),
                  const SizedBox(height: 16),
                ],

                _buildTextField(label: 'E-mail', icone: Icons.email_outlined, obscureText: false, isDark: isDark, controller: _emailController),
                const SizedBox(height: 16),

                _buildTextField(label: 'Senha', icone: Icons.lock_outline, obscureText: true, isDark: isDark, controller: _senhaController),
                const SizedBox(height: 32),

                GestureDetector(
                  onTap: _isLoading ? null : _entrar,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6B4EFF),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(color: const Color(0xFF6B4EFF).withAlpha(102), blurRadius: 12, spreadRadius: 2),
                      ],
                    ),
                    child: _isLoading
                        ? const Center(child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)))
                        : Text(
                            _isLogin ? 'ENTRAR' : 'CRIAR CONTA',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.5),
                          ),
                  ),
                ),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_isLogin ? 'Não tem uma conta? ' : 'Já é um herói? ', style: const TextStyle(color: Colors.grey)),
                    GestureDetector(
                      onTap: () => setState(() => _isLogin = !_isLogin),
                      child: const Text('Cadastre-se', style: TextStyle(color: Color(0xFF4ADE80), fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                
                if (_isLogin) ...[
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => const TelaRecuperarSenha()));
                    },
                    child: const Text(
                      'Esqueci minha senha',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500, decoration: TextDecoration.underline),
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
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? const Color(0xFF252536) : Colors.grey.shade300, width: 1.5)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF6B4EFF), width: 1.5)),
      ),
    );
  }
}
