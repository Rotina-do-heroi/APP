import 'package:flutter/material.dart';
import '../services/perfil_service.dart';

class TelaEditarPerfil extends StatefulWidget {
  final String nomeAtual;
  final String emailAtual;

  const TelaEditarPerfil({super.key, required this.nomeAtual, required this.emailAtual});
  @override
  State<TelaEditarPerfil> createState() => _TelaEditarPerfilState();
}

class _TelaEditarPerfilState extends State<TelaEditarPerfil> {
  late TextEditingController _nomeController;
  late TextEditingController _emailController;
  final TextEditingController _senhaController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.nomeAtual);
    _emailController = TextEditingController(text: widget.emailAtual);
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _salvarAlteracoes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await PerfilService.atualizarPerfil(
        nome: _nomeController.text.trim(),
        email: _emailController.text.trim(),
        senha: _senhaController.text.isNotEmpty ? _senhaController.text : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil atualizado com sucesso!'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        final mensagemErro = e.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar: $mensagemErro'), backgroundColor: Colors.redAccent),
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
      appBar: AppBar(
        title: const Text('Editar Perfil', style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold)),
        backgroundColor: isDark ? const Color(0xFF1A1A24) : const Color(0xFFF3F4F6),
        elevation: 0,
      ),
      backgroundColor: isDark ? const Color(0xFF1A1A24) : const Color(0xFFF3F4F6),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTextField(
              label: 'Nome de Herói',
              icone: Icons.person_outline,
              obscureText: false,
              isDark: isDark,
              controller: _nomeController,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'E-mail',
              icone: Icons.email_outlined,
              obscureText: false,
              isDark: isDark,
              controller: _emailController,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Nova Senha (opcional)',
              icone: Icons.lock_outline,
              obscureText: true,
              isDark: isDark,
              controller: _senhaController,
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: _isLoading ? null : _salvarAlteracoes,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF6B4EFF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _isLoading
                    ? const Center(child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)))
                    : const Text(
                        'SALVAR ALTERAÇÕES',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
              ),
            ),
          ],
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