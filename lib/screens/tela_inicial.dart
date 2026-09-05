import 'package:flutter/material.dart';
import '../models/missao.dart';
import '../widgets/hero_perfil.dart';
import '../widgets/card_da_missao.dart';
import '../widgets/mission_card.dart';
import '../services/missao_service.dart';
import '../main.dart'; // Importa os Notifiers Globais

final ValueNotifier<List<Missao>> missoesNotifier = ValueNotifier([]);
final ValueNotifier<Missao?> missaoSelecionadaNotifier = ValueNotifier(null);
final ValueNotifier<bool> autoStartTimerNotifier = ValueNotifier(false);

class TelaInicialTarefas extends StatefulWidget {
  const TelaInicialTarefas({super.key});

  @override
  State<TelaInicialTarefas> createState() => _TelaInicialTarefasState();
}

class _TelaInicialTarefasState extends State<TelaInicialTarefas> {
  int _diaSelecionado = DateTime.now().weekday;
  final List<String> _diasDaSemana = ['SEG', 'TER', 'QUA', 'QUI', 'SEX', 'SAB', 'DOM'];

  @override
  void initState() {
    super.initState();
    _carregarMissoes();
  }

  Future<void> _carregarMissoes() async {
    try {
      final missoes = await MissaoService.obterMissoes();
      missoesNotifier.value = missoes;
    } catch (e) {
      debugPrint('Erro ao carregar missões: $e');
    }
  }

  Future<void> _adicionarMissao(Missao missao) async {
    missoesNotifier.value = List.from(missoesNotifier.value)..add(missao);
    try {
      final novoId = await MissaoService.adicionarMissao(missao);
      if (novoId != null) missao.id = novoId;
    } catch (e) {
      debugPrint('Erro ao salvar na API: $e');
    }
  }

  void _deletarMissao(Missao missao) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E1E2A) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Excluir Missão'),
          content: Text('Tem certeza que deseja excluir "${missao.titulo}"?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                missoesNotifier.value = List.from(missoesNotifier.value)..remove(missao);
                if (missaoSelecionadaNotifier.value == missao) missaoSelecionadaNotifier.value = null;
                if (missao.id != null) await MissaoService.deletarMissao(missao.id!);
              },
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HeroPerfil(),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Quadro de Missões', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                CardDaMissao(onCriarMissao: _adicionarMissao),
              ],
            ),
            const SizedBox(height: 16),
            // Calendário (Simplificado para brevidade)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(7, (index) {
                  final dia = index + 1;
                  final isSelected = _diaSelecionado == dia;
                  return GestureDetector(
                    onTap: () => setState(() => _diaSelecionado = dia),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF6B4EFF) : (isDark ? const Color(0xFF252536) : Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(_diasDaSemana[index], style: TextStyle(color: isSelected ? Colors.white : null)),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ValueListenableBuilder<List<Missao>>(
                valueListenable: missoesNotifier,
                builder: (context, missoesAtuais, _) {
                  final missoesDoDia = missoesAtuais.where((m) => m.diasRepeticao.isEmpty ? _diaSelecionado == DateTime.now().weekday : m.diasRepeticao.contains(_diaSelecionado)).toList();

                  return ListView.builder(
                    itemCount: missoesDoDia.length,
                    itemBuilder: (context, index) {
                      final missao = missoesDoDia[index];
                      return MissionCard(
                        missao: missao,
                        onMissaoAtualizada: (updated) async {
                          missoesNotifier.value = List.from(missoesNotifier.value);
                          if (updated.id != null) {
                            await MissaoService.atualizarProgressoMissao(updated.id!, updated.sessoesConcluidas, updated.concluida);
                            if (mounted) await sincronizarProgresso(context);
                          }
                        },
                        onDeletarMissao: () => _deletarMissao(missao),
                        onFocoRapido: () {
                          // TRAVA DE SEGURANÇA: Verifica se o timer global está ocupado ou não resetado
                          if (isTimerRodandoGlobal.value) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Já existe um hiperfoco em andamento! Finalize-o primeiro.'), backgroundColor: Colors.redAccent),
                            );
                            return;
                          }

                          if (segundosRestantesGlobal.value < (25 * 60)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('O timer ainda não foi resetado. Volte para a aba Foco.'), backgroundColor: Colors.orange),
                            );
                            return;
                          }

                          if (missao.concluida) return;
                          
                          missaoSelecionadaNotifier.value = missao;
                          autoStartTimerNotifier.value = true;
                          abaAtualNotifier.value = 1; // Navega para Foco
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
