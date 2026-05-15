// Arquivo: lib/widgets/card_tarefa.dart
import 'package:flutter/material.dart';

class CardTarefa extends StatefulWidget {
  final String titulo;
  final int xp;
  final String progresso;

  const CardTarefa({
    super.key,
    required this.titulo,
    required this.xp,
    required this.progresso,
  });

  @override
  State<CardTarefa> createState() => _CardTarefaState();
}

class _CardTarefaState extends State<CardTarefa> {
  // Variável para controlar se a tarefa está concluída no visual
  bool _isConcluida = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252536) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        // A borda muda de cor se a tarefa estiver concluída!
        border: Border(
          left: BorderSide(
            color: _isConcluida ? Colors.greenAccent : const Color(0xFF6B4EFF), 
            width: 4,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Lado esquerdo: Botão Check + Textos
          Expanded(
            child: Row(
              children: [
                // O botão de Check interagível
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isConcluida = !_isConcluida; // Inverte o status
                    });
                  },
                  child: Icon(
                    _isConcluida ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: _isConcluida ? Colors.greenAccent : Colors.grey,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                // Textos
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.titulo, // Como é stateful, acessamos os dados com 'widget.'
                        style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          // Risca o texto se estiver concluído
                          decoration: _isConcluida ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.progresso,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Badge de XP do lado direito
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(107, 78, 255, 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '+${widget.xp} XP',
              style: const TextStyle(
                color: Color(0xFF6B4EFF),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}