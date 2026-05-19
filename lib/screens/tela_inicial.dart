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

  Future<void> _deletarMissao(Missao missao) async {
    // Remove a missão da lista local instantaneamente (Optimistic Update)
    final listaAtualizada = List<Missao>.from(missoesNotifier.value);
    listaAtualizada.remove(missao);
    missoesNotifier.value = listaAtualizada;

    // Se a missão estava selecionada no timer do Foco Rápido, remove a seleção
    if (missaoSelecionadaNotifier.value == missao) {
      missaoSelecionadaNotifier.value = null;
    }

    // Deleta do banco de dados (API)
    if (missao.id != null) {
      try {
        await MissaoService.deletarMissao(missao.id!);
      } catch (e) {
        debugPrint('Erro ao deletar na API: $e');
      }
    }
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
            Expanded(
              child: ValueListenableBuilder<List<Missao>>(
                valueListenable: missoesNotifier,
                builder: (context, missoesAtuais, _) {
                  return SingleChildScrollView(
                    child: Column(
                      children: missoesAtuais.isEmpty
                          ? [
                              const Padding(
                                padding: EdgeInsets.only(top: 16.0),
                                child: Text(
                                  'Nenhuma missão criada ainda. Clique em Nova missão para adicionar.',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            ]
                          : missoesAtuais
                              .map(
                                (missao) => MissionCard(
                                  missao: missao,
                              onMissaoAtualizada: (updated) async {
                                    // Atualiza a lista globalmente se uma missão for editada
                                    missoesNotifier.value = List.from(missoesNotifier.value);
                                // Atualiza a API para computar o XP de verdade!
                                if (updated.id != null) {
                                  await MissaoService.atualizarProgressoMissao(
                                    updated.id!, updated.sessoesConcluidas, updated.concluida, tags: updated.tags
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