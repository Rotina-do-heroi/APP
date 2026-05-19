// Arquivo: lib/screens/tela_hiperfoco.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async'; // <-- IMPORTANTE: Biblioteca para usar o Timer
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '../models/missao.dart';
import 'tela_inicial.dart'; // Importa missoesNotifier
import '../services/missao_service.dart';
import '../main.dart'; // Importa sincronizarProgresso

class TelaHiperfoco extends StatefulWidget {
  const TelaHiperfoco({super.key});

  @override
  State<TelaHiperfoco> createState() => _TelaHiperfocoState();
}

class _TelaHiperfocoState extends State<TelaHiperfoco> {
  // 0 = Foco, 1 = Pausa Curta, 2 = Pausa Longa
  int _modoAtual = 0; 
  bool _isRodando = false;
  int _comboAtual = 0; // Contador de Ofensivas (Streaks)

  // Variáveis do Cronômetro
  Timer? _timer;
  int _segundosRestantes = 25 * 1; // Começa com 25 minutos em segundos
  
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
    final userId = prefs.getString('user_id') ?? '';
    final chaveTutorial = 'primeiro_acesso_hiperfoco_$userId';
    // Puxa se é o primeiro acesso na tela de Hiperfoco
    final bool primeiroAcesso = prefs.getBool(chaveTutorial) ?? true;

    if (primeiroAcesso) {
      Future.delayed(const Duration(milliseconds: 800), () {
        if (!mounted) return;
        _showHiperfocoTutorial(context);
      });
      // Salva que o usuário já viu o tutorial dessa tela
      await prefs.setBool(chaveTutorial, false);
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
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  final contexto = _keyAbas.currentContext;
                  if (contexto != null) {
                    Scrollable.ensureVisible(contexto,
                        duration: const Duration(milliseconds: 300), alignment: 0.5);
                  }
                });
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
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  final contexto = _keyTimer.currentContext;
                  if (contexto != null) {
                    Scrollable.ensureVisible(contexto,
                        duration: const Duration(milliseconds: 300), alignment: 0.5);
                  }
                });
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
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  final contexto = _keyControles.currentContext;
                  if (contexto != null) {
                    Scrollable.ensureVisible(contexto,
                        duration: const Duration(milliseconds: 300), alignment: 0.5);
                  }
                });
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
            
            setState(() {
              _isRodando = false;
              if (_modoAtual == 0) {
                if (_comboAtual < 3) _comboAtual++; // Aumenta o combo até o máximo de 3
              }
            });
            
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
            tags: missao.tags,
          );
        } catch (e) {
          debugPrint('Erro ao atualizar progresso na API: $e');
        }
          
          if (mounted) await sincronizarProgresso(context); // Sincroniza e checa Level Up
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
      int bonusXp = _calcularBonusCombo();
      // O tempo do ciclo principal de hiperfoco é 25 minutos
      await MissaoService.salvarSessaoHiperfoco(25, xpBonus: bonusXp);
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(bonusXp > 0 ? '+ XP! Combo Ativado (+$bonusXp XP Bônus)!' : '+ XP! Sessão de Foco salva com sucesso!'), backgroundColor: Colors.green),
      );
      
      await sincronizarProgresso(context); // Sincroniza o XP e checa Level Up
    } catch (e) {
      debugPrint('Erro ao salvar sessão de foco: $e');
    }
  }

  void _resetarTimer({bool abortouFoco = false}) {
    // Se o usuário resetar ou pular o timer ENQUANTO o foco estiver rodando, ele perde a ofensiva
    if (abortouFoco && _comboAtual > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ofensiva perdida! Você interrompeu o foco.'), backgroundColor: Colors.orangeAccent),
      );
    }

    _timer?.cancel(); // Para o cronômetro
    setState(() {
      if (abortouFoco) _comboAtual = 0; // Zera a streak
      _isRodando = false;
      // Define o tempo de volta para o padrão da aba selecionada
      if (_modoAtual == 0) _segundosRestantes = 25 * 60;
      if (_modoAtual == 1) _segundosRestantes = 5 * 60;
      if (_modoAtual == 2) _segundosRestantes = 15 * 60;
    });
  }

  void _confirmarConclusaoAntecipada() {
    // Tempo total da sessão de Foco (25 minutos = 1500 segundos)
    int tempoTotal = 25 * 60;
    int tempoDecorrido = tempoTotal - _segundosRestantes;
    
    // Cada 1/5 do tempo equivale a 300 segundos (5 minutos)
    int fracaoTempo = tempoTotal ~/ 5; 
    int quintosCompletados = tempoDecorrido ~/ fracaoTempo;
    
    // Define o valor total da prioridade (Padrão = 10 para Baixa/Sem missão selecionada)
    int xpBasePrioridade = 10; 
    if (missaoSelecionadaNotifier.value != null) {
      String prio = missaoSelecionadaNotifier.value!.prioridade.toLowerCase();
      if (prio == 'alta') xpBasePrioridade = 30;
      else if (prio == 'media') xpBasePrioridade = 20;
      else if (prio == 'baixa') xpBasePrioridade = 10;
    }
    
    // XP ganho é 1/5 do xpBasePrioridade para cada 1/5 de tempo completado
    int xpGanho = quintosCompletados * (xpBasePrioridade ~/ 5);
    
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
                : 'Você completou $quintosCompletados/5 do tempo da sessão.\n\nSe finalizar agora, você receberá $xpGanho XP pela prioridade da tarefa.\n\nDeseja concluir a sessão antecipadamente?',
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
                _finalizarSessaoAntecipada(quintosCompletados, xpGanho, tempoDecorrido);
              },
              style: ElevatedButton.styleFrom(backgroundColor: quintosCompletados > 0 ? Colors.blueAccent : Colors.redAccent),
              child: Text(quintosCompletados > 0 ? 'Concluir' : 'Abortar', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      }
    );
  }

  Future<void> _finalizarSessaoAntecipada(int quintos, int xpGanho, int tempoDecorrido) async {
    _timer?.cancel();
    setState(() {
       _isRodando = false;
    });

    if (quintos > 0) {
       try {
          int minutosDecorridos = (tempoDecorrido / 60).round();
          if (minutosDecorridos < 1) minutosDecorridos = 1;

          // Salva no backend com o bônus de XP calculado
          await MissaoService.salvarSessaoHiperfoco(minutosDecorridos, xpBonus: xpGanho);
          
          if (mounted) {
             ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(content: Text('+ XP! Sessão concluída antecipadamente! (+$xpGanho XP)'), backgroundColor: Colors.green),
             );
          }
          
          // Computa a sessão para a missão atual
          await _processarFimDeSessaoDaMissao();
          if (mounted) await sincronizarProgresso(context);

       } catch(e) {
          debugPrint('Erro ao salvar sessão parcial: $e');
       }
       
       // Avança para a Pausa Curta (como um fluxo normal de fim de sessão)
       setState(() {
          _modoAtual = 1;
       });
       _resetarTimer(abortouFoco: false); 
       
    } else {
       // Completou 0 quintos (menos de 5 minutos). Aborta sem XP e perde o combo.
       if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('Sessão abortada sem recompensas.'), backgroundColor: Colors.orange),
           );
       }
       _resetarTimer(abortouFoco: true);
    }
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

  // Calcula a quantidade de XP extra baseada no combo e prioridade
  int _calcularBonusCombo() {
    if (_comboAtual < 2) return 0; // Só ganha bônus a partir de 2 sessões seguidas
    
    if (missaoSelecionadaNotifier.value != null) {
      String prioridade = missaoSelecionadaNotifier.value!.prioridade.toLowerCase();
      // Valor extra equivalente à metade do XP da missão (Ex: Alta = 30 -> 15)
      if (prioridade == 'alta') return 15;
      if (prioridade == 'media') return 10;
      if (prioridade == 'baixa') return 5;
    }
    return 2; // Bônus básico de streak se estiver focado sem missão selecionada
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
              child: Column(
                children: [
                  Container(
                    key: _keyAbas,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: corFundoSub,
                      borderRadius: BorderRadius.circular(30),
                    ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildAba(0, 'Foco', Icons.my_location),
                        _buildAba(1, 'Pausa Curta', Icons.coffee),
                        _buildAba(2, 'Pausa Longa', Icons.nightlight_round),
                      ],
                    ),
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
                      ...List.generate(3, (index) {
                        bool isAtivo = index < _comboAtual;
                        return Container(
                          width: 16, 
                          height: 16,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color: isAtivo ? Colors.amber : (isDark ? const Color(0xFF252536) : Colors.grey.shade300), 
                            borderRadius: BorderRadius.circular(4)
                          ),
                        );
                      }),
                      const SizedBox(width: 8),
                      Text('+${_calcularBonusCombo()} XP', style: TextStyle(color: _comboAtual >= 2 ? Colors.amber : Colors.grey, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _comboAtual >= 3 ? 'Combo Máximo Atingido! 🔥' : '${3 - _comboAtual} sessão(ões) para combo máximo', 
                    style: TextStyle(color: _comboAtual >= 3 ? Colors.amber : Colors.grey, fontSize: 12, fontWeight: _comboAtual >= 3 ? FontWeight.bold : FontWeight.normal)
                  ),
                  const SizedBox(height: 32),

                  Row(
                    key: _keyControles,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Botão Resetar (Agora tem função!)
                      IconButton(
                        onPressed: () => _resetarTimer(abortouFoco: _isRodando && _modoAtual == 0), 
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
                          if (_modoAtual == 0) {
                            _confirmarConclusaoAntecipada();
                          } else {
                            // Em caso de pausas, funciona como um botão de "Pular" convencional
                            setState(() {
                              _modoAtual = (_modoAtual + 1) % 3;
                            });
                            _resetarTimer(abortouFoco: false);
                          }
                        },
                        icon: Icon(_modoAtual == 0 ? Icons.task_alt : Icons.skip_next, color: Colors.grey),
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
        bool abortou = _isRodando && _modoAtual == 0;
        setState(() {
          _modoAtual = indice;
        });
        _resetarTimer(abortouFoco: abortou); // <-- Toda vez que muda de aba, ele reseta para o tempo certo!
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
          color: isConcluida ? const Color.fromRGBO(29, 59, 49, 0.3) : (isSelecionada ? const Color(0xFF6B4EFF).withValues(alpha: 0.1) : corFundoSub),
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