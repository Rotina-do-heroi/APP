// Arquivo: lib/screens/tela_hiperfoco.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async'; // <-- IMPORTANTE: Biblioteca para usar o Timer
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '../models/missao.dart';
import 'tela_inicial.dart'; // Importa missoesNotifier
import '../services/missao_service.dart';

class TelaHiperfoco extends StatefulWidget {
  const TelaHiperfoco({super.key});

  @override
  State<TelaHiperfoco> createState() => _TelaHiperfocoState();
}

class _TelaHiperfocoState extends State<TelaHiperfoco> {
  // 0 = Foco, 1 = Pausa Curta, 2 = Pausa Longa
  int _modoAtual = 0; 
  bool _isRodando = false;

  // Variáveis do Cronômetro
  Timer? _timer;
  int _segundosRestantes = 25 * 60; // Começa com 25 minutos em segundos
  
  // Chaves para o Tutorial
  final GlobalKey _keyAbas = GlobalKey();
  final GlobalKey _keyTimer = GlobalKey();
  final GlobalKey _keyControles = GlobalKey();

  // Limpa o timer da memória quando a tela for fechada (Boa prática de performance)
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Verifica se o usuário veio do botão de Foco Rápido
    if (autoStartTimerNotifier.value) {
      autoStartTimerNotifier.value = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _iniciarPausarTimer(); // Dá play automático no timer
      });
    }
    _verificarTutorial();
  }

  Future<void> _verificarTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    // Puxa se é o primeiro acesso na tela de Hiperfoco
    final bool primeiroAcesso = prefs.getBool('primeiro_acesso_hiperfoco') ?? true;

    if (primeiroAcesso) {
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) _showHiperfocoTutorial(context);
      });
      // Salva que o usuário já viu o tutorial dessa tela
      await prefs.setBool('primeiro_acesso_hiperfoco', false);
    }
  }

  void _showHiperfocoTutorial(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    TutorialCoachMark(
      targets: [
        TargetFocus(
          identify: "abas",
          keyTarget: _keyAbas,
          contents: [
            TargetContent(
              align: ContentAlign.bottom,
              builder: (context, controller) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF252536) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF6B4EFF), width: 2),
                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Modos de Tempo ⏳", style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Text("Alterne entre Foco, Pausa Curta e Pausa Longa. O cronômetro ajusta automaticamente.", style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 16)),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        TargetFocus(
          identify: "timer",
          keyTarget: _keyTimer,
          contents: [
            TargetContent(
              align: ContentAlign.bottom,
              builder: (context, controller) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF252536) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF6B4EFF), width: 2),
                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Cronômetro ⏱️", style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Text("Acompanhe seu tempo aqui. Cumpra o foco até o relógio zerar para computar a sessão e ganhar XP!", style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 16)),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        TargetFocus(
          identify: "controles",
          keyTarget: _keyControles,
          contents: [
            TargetContent(
              align: ContentAlign.top,
              builder: (context, controller) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF252536) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF6B4EFF), width: 2),
                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Controles ⏯️", style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Text("Inicie ou pause sua sessão. Você também pode resetar caso se perca, ou pular de fase se terminar rápido.", style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 16)),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ],
      colorShadow: Colors.black,
      textSkip: "PULAR TUTORIAL",
      textStyleSkip: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontFamily: 'monospace',
        letterSpacing: 1.5,
      ),
      paddingFocus: 10,
      opacityShadow: 0.85,
    ).show(context: context);
  }

  // --- LÓGICA DO CRONÔMETRO ---

  void _iniciarPausarTimer() {
    if (_isRodando) {
      // Se está rodando, vamos PAUSAR
      _timer?.cancel();
      setState(() {
        _isRodando = false;
      });
    } else {
      // Se está pausado, vamos INICIAR
      setState(() {
        _isRodando = true;
      });
      // O Timer roda esse bloco de código a cada 1 segundo
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (_segundosRestantes > 0) {
            _segundosRestantes--; // Diminui 1 segundo
          } else {
            // O tempo acabou!
            _timer?.cancel();
            _isRodando = false;
            // Aqui futuramente você pode colocar um som de alarme!
            
            if (_modoAtual == 0) {
              _salvarSessaoFoco(); // Salva a sessão de estudo no back-end
              _processarFimDeSessaoDaMissao();
            }
          }
        });
      });
    }
  }

  Future<void> _processarFimDeSessaoDaMissao() async {
    if (missaoSelecionadaNotifier.value != null && !missaoSelecionadaNotifier.value!.concluida) {
      final missao = missaoSelecionadaNotifier.value!;
      missao.sessoesConcluidas++;
      
      if (missao.sessoesConcluidas >= missao.sessoesNecessarias) {
        missao.concluida = true;
        if (mounted) {
          _mostrarParabens(missao);
        }
        missaoSelecionadaNotifier.value = null; // Tira a seleção
      }
      
      // Atualiza a lista globalmente para refletir na tela inicial
      missoesNotifier.value = List.from(missoesNotifier.value);

      // --- ATUALIZA O PROGRESSO NO BANCO DE DADOS (API) ---
      if (missao.id != null) {
        try {
          await MissaoService.atualizarProgressoMissao(
            missao.id!,
            missao.sessoesConcluidas,
            missao.concluida,
          );
        } catch (e) {
          debugPrint('Erro ao atualizar progresso na API: $e');
        }
      }
    }
  }

  void _mostrarParabens(Missao missao) {
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
                const Text('Você ganhou XP e está mais forte!', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
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

  Future<void> _salvarSessaoFoco() async {
    try {
      // O tempo do ciclo principal de hiperfoco é 25 minutos
      await MissaoService.salvarSessaoHiperfoco(25);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('+ XP! Sessão de Foco salva com sucesso!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      debugPrint('Erro ao salvar sessão de foco: $e');
    }
  }

  void _resetarTimer() {
    _timer?.cancel(); // Para o cronômetro
    setState(() {
      _isRodando = false;
      // Define o tempo de volta para o padrão da aba selecionada
      if (_modoAtual == 0) _segundosRestantes = 25 * 60;
      if (_modoAtual == 1) _segundosRestantes = 5 * 60;
      if (_modoAtual == 2) _segundosRestantes = 15 * 60;
    });
  }

  // Pega os segundos totais e transforma no formato "MM:SS"
  String get _tempoFormatado {
    int minutos = _segundosRestantes ~/ 60; // Pega a parte inteira dos minutos
    int segundos = _segundosRestantes % 60; // Pega o resto dos segundos
    // O padLeft garante que sempre tenha 2 dígitos (ex: "05" em vez de "5")
    String minStr = minutos.toString().padLeft(2, '0');
    String segStr = segundos.toString().padLeft(2, '0');
    return '$minStr:$segStr';
  }

  // Função auxiliar para retornar a cor baseada no modo atual
  Color get _corAtual {
    if (_modoAtual == 0) return const Color(0xFFA855F7); // Roxo
    if (_modoAtual == 1) return const Color(0xFF4ADE80); // Verde
    return const Color(0xFFFBBF24); // Amarelo
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
                  onPressed: () => _showHiperfocoTutorial(context),
                  tooltip: 'Ver Tutorial',
                ),
              ],
            ),
            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
              decoration: BoxDecoration(
                color: corCard, 
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Container(
                    key: _keyAbas,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: corFundoSub,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildAba(0, 'Foco', Icons.my_location),
                        _buildAba(1, 'Pausa Curta', Icons.coffee),
                        _buildAba(2, 'Pausa Longa', Icons.nightlight_round),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),

                  Container(
                    key: _keyTimer,
                    width: 240,
                    height: 240,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: corFundoSub,
                      border: Border.all(
                        color: corBorda,
                        width: 12,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _tempoFormatado, // <-- Agora usa o tempo real!
                            style: TextStyle(
                              fontSize: 64,
                              fontWeight: FontWeight.w900,
                              color: corTextoPrincipal,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _modoAtual == 0 ? Icons.my_location : _modoAtual == 1 ? Icons.coffee : Icons.nightlight_round,
                                color: _corAtual,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _modoAtual == 0 ? 'Modo Foco' : _modoAtual == 1 ? 'Descanse' : 'Pausa Longa',
                                style: TextStyle(
                                  color: _corAtual,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
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
                      Container(width: 16, height: 16, decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(4))),
                      const SizedBox(width: 4),
                      Container(width: 16, height: 16, decoration: BoxDecoration(color: const Color(0xFF252536), borderRadius: BorderRadius.circular(4))),
                      const SizedBox(width: 4),
                      Container(width: 16, height: 16, decoration: BoxDecoration(color: const Color(0xFF252536), borderRadius: BorderRadius.circular(4))),
                      const SizedBox(width: 8),
                      const Text('+2 XP', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('2 sessão(ões) para combo máximo', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 32),

                  Row(
                    key: _keyControles,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Botão Resetar (Agora tem função!)
                      IconButton(
                        onPressed: _resetarTimer, 
                        icon: const Icon(Icons.refresh, color: Colors.grey),
                        style: IconButton.styleFrom(
                        backgroundColor: corFundoSub,
                          padding: const EdgeInsets.all(16),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Botão Iniciar/Pausar (Agora tem função!)
                      GestureDetector(
                        onTap: _iniciarPausarTimer,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                          decoration: BoxDecoration(
                            color: _corAtual,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: _corAtual.withAlpha((0.4 * 255).round()),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _isRodando ? Icons.pause : Icons.play_arrow,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _isRodando ? 'Pausar' : 'Iniciar',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        onPressed: () {
                          // Alterna para o próximo modo (Foco -> Pausa Curta -> Pausa Longa -> Foco)
                          setState(() {
                            _modoAtual = (_modoAtual + 1) % 3;
                          });
                          _resetarTimer(); // Reseta o tempo e pausa de acordo com o novo modo
                        },
                        icon: const Icon(Icons.skip_next, color: Colors.grey),
                        style: IconButton.styleFrom(
                        backgroundColor: corFundoSub,
                          padding: const EdgeInsets.all(16),
                        ),
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
                          Text(
                            'Lista de Tarefas',
                            style: TextStyle(
                              color: corTextoPrincipal,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
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
                      // Exibe a lista global de missões que vem da tela_inicial
                      return Column(
                        children: missoesAtuais.map((missao) => _buildTarefa(missao, isDark)).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAba(int indice, String titulo, IconData icone) {
    bool isSelecionado = _modoAtual == indice;
    return GestureDetector(
      onTap: () {
        setState(() {
          _modoAtual = indice;
        });
        _resetarTimer(); // <-- Toda vez que muda de aba, ele reseta para o tempo certo!
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelecionado ? _corAtual : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              icone,
              size: 16,
              color: isSelecionado ? Colors.white : Colors.grey,
            ),
            const SizedBox(width: 6),
            Text(
              titulo,
              style: TextStyle(
                color: isSelecionado ? Colors.white : Colors.grey,
                fontWeight: isSelecionado ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selecionarTarefa(Missao missao) {
    if (missao.concluida) return; // Não faz nada se já estiver concluída

    setState(() {
      if (missaoSelecionadaNotifier.value == missao) {
        missaoSelecionadaNotifier.value = null; // Desmarca
      } else {
        missaoSelecionadaNotifier.value = missao; // Seleciona
      }
    });
  }

  Widget _buildTarefa(Missao missao, bool isDark) {
    bool isConcluida = missao.concluida;
    bool isSelecionada = missaoSelecionadaNotifier.value == missao;
    String titulo = missao.titulo;

    final corFundoSub = isDark ? const Color(0xFF13131A) : Colors.grey.shade100;
    final corBorda = isDark ? const Color(0xFF252536) : Colors.grey.shade300;
    
    return GestureDetector(
      onTap: () => _selecionarTarefa(missao),
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
                    titulo,
                    style: TextStyle(
                      color: isConcluida ? Colors.grey : (isDark ? Colors.white : Colors.black87),
                      fontWeight: isSelecionada ? FontWeight.bold : FontWeight.w500,
                      decoration: isConcluida ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  if (!isConcluida) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Sessões: ${missao.sessoesConcluidas} / ${missao.sessoesNecessarias}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelecionada ? const Color(0xFF6B4EFF) : Colors.grey,
                      ),
                    ),
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