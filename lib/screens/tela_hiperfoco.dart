import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/missao.dart';
import 'tela_inicial.dart';
import '../main.dart';
import '../controllers/hiperfoco_controller.dart';
import '../widgets/aba_modo_widget.dart';
import '../widgets/tarefa_card_widget.dart';
import 'hiperfoco_dialogs.dart';
import 'hiperfoco_tutorial.dart';

class TelaHiperfoco extends StatefulWidget {
  const TelaHiperfoco({super.key});

  @override
  State<TelaHiperfoco> createState() => _TelaHiperfocoState();
}

class _TelaHiperfocoState extends State<TelaHiperfoco> {
  late HiperfocoController _controller;

  final GlobalKey _keyAbas = GlobalKey();
  final GlobalKey _keyTimer = GlobalKey();
  final GlobalKey _keyControles = GlobalKey();

  @override
  void initState() {
    super.initState();
    _controller = HiperfocoController(
      onShowSnackbar: (message, isSuccess) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: isSuccess ? Colors.green : Colors.orangeAccent),
        );
      },
      onMissaoConcluida: (missao, ganhouConsistencia) {
        if (!mounted) return;
        HiperfocoDialogs.mostrarParabens(context, missao, ganhouConsistencia);
      },
      onSincronizarProgresso: () async {
        if (!mounted) return;
        await sincronizarProgresso(context);
      },
      onShowConfirmacaoAntecipada: (quintos, xpPeloTempo, xpGanho, xpTotal, onConfirm) {
        if (!mounted) return;
        HiperfocoDialogs.confirmarConclusaoAntecipada(
          context: context, quintosCompletados: quintos, xpPeloTempo: xpPeloTempo, xpGanho: xpGanho, xpTotalPrevisto: xpTotal, onConfirm: onConfirm,
        );
      },
    );

    _controller.init();
    _verificarTutorial();
  }

  @override
  void dispose() {
    _controller.dispose(); // Delega a limpeza do Timer e Observers para a própria classe de controle
    super.dispose();
  }

  Future<void> _verificarTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id') ?? '';
    final chaveTutorial = 'primeiro_acesso_hiperfoco_$userId';
    // Puxa se é o primeiro acesso na tela de Hiperfoco
    final bool primeiroAcesso = prefs.getBool(chaveTutorial) ?? true;

    if (primeiroAcesso) {
      Future.delayed(const Duration(milliseconds: 800), () {
        if (!mounted) return;
        HiperfocoTutorial.showTutorial(context, keyAbas: _keyAbas, keyTimer: _keyTimer, keyControles: _keyControles);
      });
      await prefs.setBool(chaveTutorial, false);
    }
  }

  // --- INTERFACE VISUAL ---

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final corCard = isDark ? const Color(0xFF1E1E2A) : Colors.white;
    final corBorda = isDark ? const Color(0xFF252536) : Colors.grey.shade300;
    final corFundoSub = isDark ? const Color(0xFF13131A) : Colors.grey.shade100;
    final corTextoPrincipal = isDark ? Colors.white : Colors.black87;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.timer_outlined, color: corTextoPrincipal, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Modo Hiperfoco',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: corTextoPrincipal,
                        fontFamily: 'monospace', 
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.help_outline, color: isDark ? Colors.blueAccent : Colors.blue),
                    onPressed: () => HiperfocoTutorial.showTutorial(context, keyAbas: _keyAbas, keyTimer: _keyTimer, keyControles: _keyControles),
                  tooltip: 'Ver Tutorial',
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Barra de XP Dinâmica e Global
            AnimatedBuilder(
              animation: Listenable.merge([xpNotifier, nivelNotifier]),
              builder: (context, _) {
                final int nvl = nivelNotifier.value;
                final int xp = xpNotifier.value;
                return Row(
                  children: [
                    Text('Nvl $nvl', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.all(Radius.circular(4)),
                        child: LinearProgressIndicator(
                          value: (xp % 100) / 100, // Calcula a porcentagem da barra
                          backgroundColor: isDark ? const Color(0xFF13131A) : Colors.grey.shade300,
                          color: Colors.amber,
                          minHeight: 8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('Nvl ${nvl + 1}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
              decoration: BoxDecoration(
                color: corCard, 
                borderRadius: BorderRadius.circular(24),
              ),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return Column(
                    children: [
                      Container(
                        key: _keyAbas,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(color: corFundoSub, borderRadius: BorderRadius.circular(30)),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              AbaModoWidget(indice: 0, titulo: 'Foco', icone: Icons.my_location, isSelecionado: _controller.modoAtual == 0, corAtual: _controller.corAtual, onTap: () => _controller.mudarModo(0)),
                              AbaModoWidget(indice: 1, titulo: 'Pausa Curta', icone: Icons.coffee, isSelecionado: _controller.modoAtual == 1, corAtual: _controller.corAtual, onTap: () => _controller.mudarModo(1)),
                              AbaModoWidget(indice: 2, titulo: 'Pausa Longa', icone: Icons.nightlight_round, isSelecionado: _controller.modoAtual == 2, corAtual: _controller.corAtual, onTap: () => _controller.mudarModo(2)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),

                      Container(
                        key: _keyTimer,
                        width: 240,
                        height: 240,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: corFundoSub, border: Border.all(color: corBorda, width: 12)),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _controller.tempoFormatado,
                                style: TextStyle(fontSize: 64, fontWeight: FontWeight.w900, color: corTextoPrincipal, letterSpacing: 2),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(_controller.modoAtual == 0 ? Icons.my_location : _controller.modoAtual == 1 ? Icons.coffee : Icons.nightlight_round, color: _controller.corAtual, size: 16),
                                  const SizedBox(width: 4),
                                  Text(_controller.modoAtual == 0 ? 'Modo Foco' : _controller.modoAtual == 1 ? 'Descanse' : 'Pausa Longa', style: TextStyle(color: _controller.corAtual, fontWeight: FontWeight.bold)),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Combo Hiperfoco ', style: TextStyle(color: Colors.grey)),
                          ...List.generate(3, (index) {
                            bool isAtivo = index < _controller.comboAtual;
                            return Container(
                              width: 16, height: 16, margin: const EdgeInsets.symmetric(horizontal: 2),
                              decoration: BoxDecoration(color: isAtivo ? Colors.amber : (isDark ? const Color(0xFF252536) : Colors.grey.shade300), borderRadius: BorderRadius.circular(4)),
                            );
                          }),
                          const SizedBox(width: 8),
                          Text('+${_controller.calcularBonusCombo()} XP', style: TextStyle(color: _controller.comboAtual >= 2 ? Colors.amber : Colors.grey, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _controller.comboAtual >= 3 ? 'Combo Máximo Atingido! 🔥' : '${3 - _controller.comboAtual} sessão(ões) para combo máximo', 
                        style: TextStyle(color: _controller.comboAtual >= 3 ? Colors.amber : Colors.grey, fontSize: 12, fontWeight: _controller.comboAtual >= 3 ? FontWeight.bold : FontWeight.normal)
                      ),
                      const SizedBox(height: 32),

                      Row(
                        key: _keyControles,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () => _controller.resetarTimer(abortouFoco: _controller.isRodando && _controller.modoAtual == 0), 
                            icon: const Icon(Icons.refresh, color: Colors.grey),
                            style: IconButton.styleFrom(backgroundColor: corFundoSub, padding: const EdgeInsets.all(16)),
                          ),
                          const SizedBox(width: 16),
                          GestureDetector(
                            onTap: _controller.iniciarPausarTimer,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                              decoration: BoxDecoration(
                                color: _controller.corAtual, borderRadius: BorderRadius.circular(30),
                                boxShadow: [BoxShadow(color: _controller.corAtual.withOpacity(0.4), blurRadius: 20, spreadRadius: 2)],
                              ),
                              child: Row(
                                children: [
                                  Icon(_controller.isRodando ? Icons.pause : Icons.play_arrow, color: Colors.white),
                                  const SizedBox(width: 8),
                                  Text(_controller.isRodando ? 'Pausar' : 'Iniciar', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          IconButton(
                            onPressed: _controller.pularOuConfirmarAntecipado,
                            icon: Icon(_controller.modoAtual == 0 ? Icons.task_alt : Icons.skip_next, color: Colors.grey),
                            style: IconButton.styleFrom(backgroundColor: corFundoSub, padding: const EdgeInsets.all(16)),
                          ),
                        ],
                      ),
                      
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Divider(color: corBorda, thickness: 2),
                      ),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.receipt_long, color: corTextoPrincipal, size: 20),
                              const SizedBox(width: 8),
                              Text('Lista de Tarefas', style: TextStyle(color: corTextoPrincipal, fontWeight: FontWeight.bold, fontSize: 16)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      ValueListenableBuilder<List<Missao>>(
                        valueListenable: missoesNotifier,
                        builder: (context, missoesAtuais, _) {
                          if (missoesAtuais.isEmpty) {
                            return const Center(child: Padding(padding: EdgeInsets.all(16), child: Text('Nenhuma tarefa pendente.', style: TextStyle(color: Colors.grey))));
                          }
                          
                          return ValueListenableBuilder<Missao?>(
                            valueListenable: missaoSelecionadaNotifier,
                            builder: (context, missaoSelecionada, _) {
                              return Column(
                                children: missoesAtuais.map((missao) => TarefaCardWidget(
                                  missao: missao,
                                  isSelecionada: missaoSelecionada == missao,
                                  isDark: isDark,
                                  onTap: () => _controller.selecionarTarefa(missao),
                                )).toList(),
                              );
                            }
                          );
                        },
                      ),
                    ],
                  );
                }
              ),
            ),
          ],
        ),
      ),
    );
  }
}