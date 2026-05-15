import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TelaRecuperarSenha extends StatefulWidget {
  const TelaRecuperarSenha({super.key});

  @override
  State<TelaRecuperarSenha> createState() => _TelaRecuperarSenhaState();
}

class _TelaRecuperarSenhaState extends State<TelaRecuperarSenha> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  int _passoAtual = 0; // 0 = Email, 1 = Código, 2 = Nova Senha
  bool _isLoading = false;
  final String _apiUrl = 'http://localhost:3000'; // Altere conforme necessário

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _enviarEmail() async {
    if (_emailController.text.isEmpty) {
      _showSnackBar('Por favor, informe seu email', Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      print('🔵 Enviando email para: ${_emailController.text}');
      print('🔵 URL: $_apiUrl/forgot-password');
      
      final response = await http.post(
        Uri.parse('$_apiUrl/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': _emailController.text}),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Timeout: Servidor não respondeu');
        },
      );

      print('🟢 Status: ${response.statusCode}');
      print('🟢 Body: ${response.body}');

      if (!mounted) return;

      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        _showSnackBar('✅ Código enviado para seu email!', Colors.green);
        // Se estiver em modo de desenvolvimento, mostrar o código
        if (data['devMode'] == true) {
          _showSnackBar('[DEV] Código: ${data['code']}', Colors.blue);
        }
        setState(() => _passoAtual = 1); // Passa para a interface do Código
      } else {
        _showSnackBar('❌ ${data['message'] ?? 'Erro ao enviar código'}', Colors.red);
      }
    } catch (e) {
      print('🔴 Erro: $e');
      _showSnackBar('❌ Erro: $e', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }


  Future<void> _redefinirSenha() async {
    if (_passwordController.text.isEmpty || _confirmPasswordController.text.isEmpty) {
      _showSnackBar('Por favor, preencha todos os campos', Colors.red);
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showSnackBar('As senhas não coincidem', Colors.red);
      return;
    }

    if (_passwordController.text.length < 6) {
      _showSnackBar('A senha deve ter no mínimo 6 caracteres', Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('$_apiUrl/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text,
          'code': _codeController.text,
          'newPassword': _passwordController.text,
        }),
      );

      if (!mounted) return;

      final data = jsonDecode(response.body);

      if (data['success']) {
        _showSnackBar('Senha redefinida com sucesso!', Colors.green);
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pop(context);
          }
        });
      } else {
        _showSnackBar(data['error'] ?? 'Erro ao redefinir senha', Colors.red);
      }
    } catch (e) {
      _showSnackBar('Erro: $e', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A24) : const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black87),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_passoAtual > 0) {
              setState(() => _passoAtual--); // Volta para a etapa anterior
            } else {
              Navigator.pop(context); // Fecha a tela de recuperação
            }
          },
        ),
        title: Text(
          'Recuperar Senha',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            // Transição condicional inteligente baseada no passo atual
            child: _passoAtual == 0
                ? _buildPassoEmail(isDark)
                : _passoAtual == 1
                    ? _buildPassoCodigo(isDark)
                    : _buildPassoNovaSenha(isDark),
          ),
        ),
      ),
    );
  }

  // --- ETAPA 1: SOLICITAR E-MAIL ---
  Widget _buildPassoEmail(bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.lock_reset, size: 80, color: Color(0xFF6B4EFF)),
        const SizedBox(height: 24),
        Text(
          'Esqueceu sua senha?',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
        ),
        const SizedBox(height: 8),
        const Text(
          'Informe seu e-mail para receber as instruções de redefinição de senha.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 32),
        _buildTextField(
          label: 'E-mail',
          icone: Icons.email_outlined,
          isDark: isDark,
          controller: _emailController,
        ),
        const SizedBox(height: 32),
        _buildBotao(texto: 'ENVIAR CÓDIGO', onTap: _enviarEmail),
      ],
    );
  }

  // --- ETAPA 2: DIGITAR O CÓDIGO ---
  Widget _buildPassoCodigo(bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.vpn_key_outlined, size: 80, color: Color(0xFF6B4EFF)),
        const SizedBox(height: 24),
        Text(
          'Código de Resgate',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
        ),
        const SizedBox(height: 8),
        Text(
          'Insira o código de 6 dígitos que enviamos para\n${_emailController.text}',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 32),
        _buildTextField(
          label: 'Código de Verificação',
          icone: Icons.numbers,
          isDark: isDark,
          controller: _codeController,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 6,
        ),
        const SizedBox(height: 32),
        _buildBotao(
          texto: 'VERIFICAR CÓDIGO',
          onTap: () {
            if (_codeController.text.length < 6) {
              _showSnackBar('Insira o código completo de 6 dígitos', Colors.redAccent);
              return;
            }
            setState(() => _passoAtual = 2); // Passa para a próxima aba de senha!
          },
        ),
      ],
    );
  }

  // --- ETAPA 3: FORJAR NOVA SENHA ---
  Widget _buildPassoNovaSenha(bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.shield_outlined, size: 80, color: Color(0xFF6B4EFF)),
        const SizedBox(height: 24),
        Text(
          'Forjar Nova Senha',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
        ),
        const SizedBox(height: 8),
        const Text(
          'Crie uma senha forte para proteger seu herói.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 32),
        _buildTextField(
          label: 'Nova Senha',
          icone: Icons.lock_outline,
          isDark: isDark,
          controller: _passwordController,
          obscureText: true,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'Confirmar Nova Senha',
          icone: Icons.lock_reset,
          isDark: isDark,
          controller: _confirmPasswordController,
          obscureText: true,
        ),
        const SizedBox(height: 32),
        _buildBotao(texto: 'SALVAR NOVA SENHA', onTap: _redefinirSenha),
      ],
    );
  }

  // --- WIDGETS REUTILIZÁVEIS ---
  Widget _buildBotao({required String texto, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: _isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF6B4EFF),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: const Color(0xFF6B4EFF).withOpacity(0.4), blurRadius: 12, spreadRadius: 2),
          ],
        ),
        child: _isLoading
            ? const SizedBox(height: 24, width: 24, child: Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white), strokeWidth: 2)))
            : Text(texto, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.5)),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icone,
    required bool isDark,
    TextEditingController? controller,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    TextAlign textAlign = TextAlign.start,
    int? maxLength,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textAlign: textAlign,
      maxLength: maxLength,
      style: TextStyle(
        color: isDark ? Colors.white : Colors.black87,
        letterSpacing: textAlign == TextAlign.center ? 8 : null,
        fontSize: textAlign == TextAlign.center ? 18 : null,
        fontWeight: textAlign == TextAlign.center ? FontWeight.bold : null,
      ),
      decoration: InputDecoration(
        counterText: '', // Oculta o contador de caracteres nativo (0/6)
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey, letterSpacing: 0, fontWeight: FontWeight.normal),
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