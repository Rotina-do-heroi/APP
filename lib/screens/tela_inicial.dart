// ---------------------------------------------------
// WIDGET DA TELA INICIAL
// ---------------------------------------------------
// Arquivo: lib/screens/tela_inicial.dart
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/missao.dart';
import '../widgets/hero_perfil.dart';
import '../widgets/card_da_missao.dart';
import '../widgets/mission_card.dart';
import '../main.dart'; // Importa as GlobalKeys do tutorial

// Constante com a URL da API das missões
const String apiMissoesUrl = 'https://api-geral-production.up.railway.app';

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
  Future<void> _adicionarMissao(Missao missao) async {
    // Atualiza o estado global e notifica quem estiver escutando
    missoesNotifier.value = List.from(missoesNotifier.value)..add(missao);
    
    // Enviando os dados (incluindo as sessões) para o banco de dados via API
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token') ?? '';
      
      final url = Uri.parse('$apiMissoesUrl/tarefas');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'titulo': missao.titulo,
          'descricao': missao.descricao,
          'prioridade': missao.prioridade,
          'sessoesNecessarias': missao.sessoesNecessarias,
          'sessoesConcluidas': missao.sessoesConcluidas,
        }),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        // Atualiza a missão local com o ID gerado pelo banco de dados
        missao.id = data['id']?.toString() ?? data['tarefa']?['id']?.toString();
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
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('jwt_token') ?? '';
        
        await http.delete(
          Uri.parse('$apiMissoesUrl/tarefas/${missao.id}'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
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
                                  onMissaoAtualizada: (updated) {
                                    // Atualiza a lista globalmente se uma missão for editada
                                    missoesNotifier.value = List.from(missoesNotifier.value);
                                  },
                                  onDeletarMissao: () => _deletarMissao(missao),
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