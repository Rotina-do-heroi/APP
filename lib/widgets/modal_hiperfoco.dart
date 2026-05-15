import 'package:flutter/material.dart';
import 'dart:async';

class ModalHiperfoco extends StatefulWidget {
  const ModalHiperfoco({super.key});

  @override
  State<ModalHiperfoco> createState() => _ModalHiperfocoState();
}

class _ModalHiperfocoState extends State<ModalHiperfoco> {
  bool _isRodando = false;
  Timer? _timer;
  int _segundosRestantes = 25 * 60; // 25 minutos

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _iniciarPausarTimer() {
    if (_isRodando) {
      _timer?.cancel();
      setState(() {
        _isRodando = false;
      });
    } else {
      setState(() {
        _isRodando = true;
      });
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (_segundosRestantes > 0) {
            _segundosRestantes--;
          } else {
            _timer?.cancel();
            _isRodando = false;
            // Tocar um alarme aqui futuramente
          }
        });
      });
    }
  }

  void _resetarTimer() {
    _timer?.cancel();
    setState(() {
      _isRodando = false;
      _segundosRestantes = 25 * 60;
    });
  }

  String get _tempoFormatado {
    int minutos = _segundosRestantes ~/ 60;
    int segundos = _segundosRestantes % 60;
    return '${minutos.toString().padLeft(2, '0')}:${segundos.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final corCard = isDark ? const Color(0xFF1E1E2A) : Colors.white;
    final corBorda = isDark ? const Color(0xFF252536) : Colors.grey.shade300;
    final corFundoSub = isDark ? const Color(0xFF13131A) : Colors.grey.shade100;
    final corTextoPrincipal = isDark ? Colors.white : Colors.black87;

    return Dialog(
      backgroundColor: corCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Ajusta o tamanho da janela ao conteúdo
          children: [
            // Cabeçalho do Pop-up
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.center_focus_strong, color: Color(0xFFA855F7), size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'Foco Rápido',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: corTextoPrincipal,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.of(context).pop(), // Fecha a janela
                )
              ],
            ),
            const SizedBox(height: 24),
            
            // Círculo do Cronômetro
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: corFundoSub,
                border: Border.all(color: corBorda, width: 8),
              ),
              child: Center(
                child: Text(
                  _tempoFormatado,
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: corTextoPrincipal,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Mostra qual tarefa o usuário vai focar agora
            const Text('Tarefa em Andamento:', style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 4),
            Text(
              'Primeira Tarefa da Lista', // Texto simulando a tarefa atual
              style: TextStyle(color: corTextoPrincipal, fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // Botões de Ação
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: _resetarTimer,
                  icon: const Icon(Icons.refresh, color: Colors.grey),
                  style: IconButton.styleFrom(backgroundColor: corFundoSub, padding: const EdgeInsets.all(12)),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: _iniciarPausarTimer,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    decoration: BoxDecoration(color: const Color(0xFFA855F7), borderRadius: BorderRadius.circular(30)),
                    child: Row(
                      children: [
                        Icon(_isRodando ? Icons.pause : Icons.play_arrow, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(_isRodando ? 'Pausar' : 'Iniciar', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}