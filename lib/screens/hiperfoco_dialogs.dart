import 'package:flutter/material.dart';
import '../models/missao.dart';

class HiperfocoDialogs {
  static void mostrarParabens(BuildContext context, Missao missao, bool ganhouConsistencia) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E2A) : Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.workspace_premium, color: Colors.amber, size: 80),
                const SizedBox(height: 16),
                const Text(
                  'MISSÃO CONCLUÍDA!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.amber),
                ),
                const SizedBox(height: 8),
                Text(
                  missao.titulo,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87),
                ),
                const SizedBox(height: 16),
                Builder(
                  builder: (context) {
                    List<String> recompensas = ['XP'];
                    if (missao.tags.isNotEmpty) recompensas.add('+1 ${missao.tags.first}');
                    if (missao.prioridade.toUpperCase() == 'ALTA') recompensas.add('+1 Coragem');
                    if (ganhouConsistencia) recompensas.add('+1 Consistência');
                    
                    String textoRecompensas;
                    if (recompensas.length > 1) {
                      final ultimos = recompensas.removeLast();
                      textoRecompensas = 'Recompensas: ${recompensas.join(', ')} e $ultimos!';
                    } else {
                      textoRecompensas = 'Recompensas: ${recompensas.first}!';
                    }
                    
                    return Text(
                      textoRecompensas,
                      textAlign: TextAlign.center, 
                      style: const TextStyle(color: Colors.grey, height: 1.5),
                    );
                  }
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6B4EFF), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12)),
                  child: const Text('Continuar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  static void confirmarConclusaoAntecipada({
    required BuildContext context,
    required int quintosCompletados,
    required int xpPeloTempo,
    required int xpGanho,
    required int xpTotalPrevisto,
    required VoidCallback onConfirm,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E1E2A) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.flag, color: quintosCompletados > 0 ? Colors.blueAccent : Colors.redAccent),
              const SizedBox(width: 8),
              Text('Concluir Sessão', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
            ],
          ),
          content: Text(
            quintosCompletados == 0
                ? 'Você completou menos de 20% do tempo e NÃO receberá XP se finalizar agora.\n\nTem certeza que deseja abortar a sessão?'
                : 'Você completou $quintosCompletados/5 do tempo da sessão.\n\nRecompensa:\n• $xpPeloTempo XP pelo tempo focado\n• $xpGanho XP bônus da missão\nTotal: $xpTotalPrevisto XP.\n\nDeseja concluir antecipadamente?',
            style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                onConfirm(); // Chama a lógica do controller que finaliza a sessão
              },
              style: ElevatedButton.styleFrom(backgroundColor: quintosCompletados > 0 ? Colors.blueAccent : Colors.redAccent),
              child: Text(quintosCompletados > 0 ? 'Concluir' : 'Abortar', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      }
    );
  }
}