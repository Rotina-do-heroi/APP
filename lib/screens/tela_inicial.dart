// ---------------------------------------------------
// WIDGET DA TELA INICIAL
// ---------------------------------------------------
// Arquivo: lib/screens/tela_inicial.dart
import 'package:flutter/material.dart';
import '../models/missao.dart';
import '../widgets/hero_perfil.dart';
import '../widgets/card_da_missao.dart';
import '../widgets/mission_card.dart';

class TelaInicialTarefas extends StatefulWidget {
  const TelaInicialTarefas({super.key});

  @override
  State<TelaInicialTarefas> createState() => _TelaInicialTarefasState();
}

class _TelaInicialTarefasState extends State<TelaInicialTarefas> {
  final List<Missao> _missoes = [];

  void _adicionarMissao(Missao missao) {
    setState(() {
      _missoes.add(missao);
    });
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
            HeroPerfil(),
            SizedBox(height: 32),
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
                CardDaMissao(onCriarMissao: _adicionarMissao),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: _missoes.isEmpty
                      ? [
                          const Padding(
                            padding: EdgeInsets.only(top: 16.0),
                            child: Text(
                              'Nenhuma missão criada ainda. Clique em Nova missão para adicionar.',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ]
                      : _missoes
                          .map(
                            (missao) => MissionCard(
                              missao: missao,
                              onMissaoAtualizada: (updated) {
                                setState(() {});
                              },
                            ),
                          )
                          .toList(),
                ),
              ),
            ),
            // Fim da lista
            
          ],
        ),
      ),
    );
  }
}