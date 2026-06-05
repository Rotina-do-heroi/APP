import 'package:flutter/material.dart';
import '../models/missao.dart';

class TarefaCardWidget extends StatelessWidget {
  final Missao missao;
  final bool isSelecionada;
  final bool isDark;
  final VoidCallback onTap;

  const TarefaCardWidget({
    super.key,
    required this.missao,
    required this.isSelecionada,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isConcluida = missao.concluida;
    final corFundoSub = isDark ? const Color(0xFF13131A) : Colors.grey.shade100;
    final corBorda = isDark ? const Color(0xFF252536) : Colors.grey.shade300;
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isConcluida ? const Color.fromRGBO(29, 59, 49, 0.3) : (isSelecionada ? const Color(0xFF6B4EFF).withOpacity(0.1) : corFundoSub),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isConcluida ? const Color(0xFF4ADE80) : (isSelecionada ? const Color(0xFF6B4EFF) : corBorda),
            width: isSelecionada ? 2.0 : 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: isConcluida ? const Color(0xFF4ADE80) : (isSelecionada ? const Color(0xFF6B4EFF) : Colors.transparent),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isConcluida ? const Color(0xFF4ADE80) : (isSelecionada ? const Color(0xFF6B4EFF) : corBorda),
                )
              ),
              child: Icon(
                isConcluida ? Icons.check : (isSelecionada ? Icons.my_location : Icons.crop_square),
                color: isConcluida || isSelecionada ? (isDark ? const Color(0xFF1E1E2A) : Colors.white) : corBorda,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    missao.titulo,
                    style: TextStyle(
                      color: isConcluida ? Colors.grey : (isDark ? Colors.white : Colors.black87),
                      fontWeight: isSelecionada ? FontWeight.bold : FontWeight.w500,
                      decoration: isConcluida ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  if (!isConcluida) ...[
                    const SizedBox(height: 4),
                    Text('Sessões: ${missao.sessoesConcluidas} / ${missao.sessoesNecessarias}', style: TextStyle(fontSize: 12, color: isSelecionada ? const Color(0xFF6B4EFF) : Colors.grey)),
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}