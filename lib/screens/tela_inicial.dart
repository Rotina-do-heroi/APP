// ---------------------------------------------------
// WIDGET DA TELA INICIAL
// ---------------------------------------------------
// Arquivo: lib/screens/tela_inicial.dart
import 'package:flutter/material.dart';
import '../models/missao.dart';
import '../widgets/hero_perfil.dart';
import '../widgets/card_da_missao.dart';
import '../widgets/mission_card.dart';
import '../services/missao_service.dart';
import '../main.dart'; // Importa as GlobalKeys do tutorial

// Notifier global para compartilhar o estado das missões com a TelaHiperfoco e outras
final ValueNotifier<List<Missao>> missoesNotifier = ValueNotifier([]);

// Controladores globais para o botão de Foco Rápido
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
    // Atualiza o estado global e notifica quem estiver escutando
    missoesNotifier.value = List.from(missoesNotifier.value)..add(missao);
    
    try {
      final novoId = await MissaoService.adicionarMissao(missao);
      if (novoId != null) {
        missao.id = novoId; // Atualiza a missão local com o ID gerado pelo banco
      }
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
          title: Row(
            children: [
              const Icon(Icons.delete_outline, color: Colors.redAccent),
              const SizedBox(width: 8),
              Text('Excluir Missão', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
            ],
          ),
          content: Text(
            'Tem certeza que deseja excluir a missão "${missao.titulo}"?\n\nEsta ação não pode ser desfeita.',
            style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                
                // Remove a missão da lista local instantaneamente
                final listaAtualizada = List<Missao>.from(missoesNotifier.value);
                listaAtualizada.remove(missao);
                missoesNotifier.value = listaAtualizada;

                if (missaoSelecionadaNotifier.value == missao) {
                  missaoSelecionadaNotifier.value = null;
                }

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Missão excluída com sucesso!'), backgroundColor: Colors.redAccent),
                  );
                }

                // Deleta do banco de dados (API)
                if (missao.id != null) {
                  try {
                    await MissaoService.deletarMissao(missao.id!);
                  } catch (e) {
                    debugPrint('Erro ao deletar na API: $e');
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              child: const Text('Excluir', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      }
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
            Container(
              key: keyPerfil,
              child: const HeroPerfil(),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Quadro de Missões',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Container(
                  key: keyNovaMissao,
                  child: CardDaMissao(onCriarMissao: _adicionarMissao),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // --- CALENDÁRIO SEMANAL ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (index) {
                final dia = index + 1;
                final isSelected = _diaSelecionado == dia;
                final hoje = DateTime.now();
                final isHoje = hoje.weekday == dia;
                
                // Calcula a data exata para este dia na semana atual
                final inicioDaSemana = hoje.subtract(Duration(days: hoje.weekday - 1));
                final dataDoDia = inicioDaSemana.add(Duration(days: index));

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _diaSelecionado = dia;
                    });
                  },
                  child: Container(
                    width: 46,
                    height: 56,
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF6B4EFF) : (isDark ? const Color(0xFF252536) : Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(12),
                      border: isHoje && !isSelected ? Border.all(color: const Color(0xFF6B4EFF), width: 1.5) : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _diasDaSemana[index],
                          style: TextStyle(
                            fontSize: 10,
                            color: isSelected ? Colors.white.withOpacity(0.8) : (isDark ? Colors.white54 : Colors.black54),
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${dataDoDia.day}',
                          style: TextStyle(
                            fontSize: 14,
                            color: isSelected ? Colors.white : (isDark ? Colors.white : Colors.black87),
                            fontWeight: isSelected || isHoje ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ValueListenableBuilder<List<Missao>>(
                valueListenable: missoesNotifier,
                builder: (context, missoesAtuais, _) {
                  
                  final missoesDoDia = missoesAtuais.where((missao) {
                    final bool isRecurring = missao.diasRepeticao.isNotEmpty;

                    if (!isRecurring) {
                      // Mostrar missões únicas apenas no dia de "Hoje"
                      return _diaSelecionado == DateTime.now().weekday;
                    }
                    // Se a missão FOR recorrente, ela deve aparecer se o dia selecionado corresponder.
                    return missao.diasRepeticao.contains(_diaSelecionado);
                  }).toList();

                  return SingleChildScrollView(
                    child: Column(
                      children: missoesDoDia.isEmpty
                          ? [
                              Padding(
                                padding: const EdgeInsets.only(top: 16.0),
                                child: Text(
                                  _diaSelecionado == DateTime.now().weekday
                                      ? 'Nenhuma missão para hoje. Aproveite o descanso ou crie uma nova!'
                                      : 'Nenhuma missão agendada para este dia.',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ),
                            ]
                          : missoesDoDia
                              .map(
                                (missao) => MissionCard(
                                  missao: missao,
                              onMissaoAtualizada: (updated) async {
                                    // Atualiza a lista globalmente se uma missão for editada
                                    missoesNotifier.value = List.from(missoesNotifier.value);
                                // Atualiza a API para computar o XP de verdade!
                                if (updated.id != null) {
                                  await MissaoService.atualizarProgressoMissao(
                                    updated.id!, 
                                    updated.sessoesConcluidas, 
                                    updated.concluida, 
                                    tags: updated.tags,
                                    prioridade: updated.prioridade,
                                  );
                                  if (mounted) await sincronizarProgresso(context); // Chama o XP Global
                                }
                                  },
                                  onDeletarMissao: () => _deletarMissao(missao),
                                  onFocoRapido: () {
                                    if (missao.concluida) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Esta missão já foi concluída!'), backgroundColor: Colors.orange),
                                      );
                                      return;
                                    }
                                    if (_diaSelecionado != DateTime.now().weekday) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Você só pode iniciar o foco nas missões de hoje!'), backgroundColor: Colors.orange),
                                      );
                                      return;
                                    }
                                    missaoSelecionadaNotifier.value = missao;
                                    autoStartTimerNotifier.value = true;
                                    abaAtualNotifier.value = 1; // Navega para a aba de Foco
                                  },
                                ),
                              )
                              .toList(),
                    ),
                  );
                },
              ),
            ),
            // Fim da lista
            
          ],
        ),
      ),
    );
  }
}