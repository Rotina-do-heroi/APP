import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../models/missao.dart';
import '../../screens/tela_inicial.dart';
import '../../services/missao_service.dart';
import '../../services/time_storage_service.dart';
import '../../services/notification_service.dart';

class HiperfocoController extends ChangeNotifier with WidgetsBindingObserver {
  int _modoAtual = 0; 
  bool _isRodando = false;
  int _comboAtual = 0;

  Timer? _timer;
  late List<int> _temposPadrao;
  late List<int> _segundosRestantesPorModo;

  int get modoAtual => _modoAtual;
  bool get isRodando => _isRodando;
  int get comboAtual => _comboAtual;
  int get segundosRestantes => _segundosRestantesPorModo[_modoAtual];

  // Injeção de Callbacks (Comunicação indireta com a View)
  final void Function(String message, bool isSuccess) onShowSnackbar;
  final void Function(Missao missao, bool ganhouConsistencia) onMissaoConcluida;
  final Future<void> Function() onSincronizarProgresso;
  final void Function(int quintosCompletados, int xpPeloTempo, int xpGanho, int xpTotalPrevisto, VoidCallback onConfirm) onShowConfirmacaoAntecipada;

  HiperfocoController({
    required this.onShowSnackbar,
    required this.onMissaoConcluida,
    required this.onSincronizarProgresso,
    required this.onShowConfirmacaoAntecipada,
  }) {
    _temposPadrao = [25 * 60, 5 * 60, 15 * 60];
    _segundosRestantesPorModo = List.from(_temposPadrao);
  }

  void init() {
    WidgetsBinding.instance.addObserver(this);
    if (autoStartTimerNotifier.value) {
      autoStartTimerNotifier.value = false;
      iniciarPausarTimer();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    WakelockPlus.disable();
    super.dispose();
  }

  // --- CICLO DE VIDA E BACKGROUND ---
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _lidarComAppEmSegundoPlano();
    } else if (state == AppLifecycleState.resumed) {
      _lidarComAppEmPrimeiroPlano();
    }
  }

  void _lidarComAppEmSegundoPlano() {
    if (!_isRodando) return;
    TimeStorageService().salvarTimestamp(DateTime.now());

    if (segundosRestantes > 0) {
      NotificationService().agendarNotificacaoFimTimer(
        id: 100,
        titulo: 'Tempo Esgotado! ⏳',
        corpo: 'Sua sessão terminou. Abra o app para resgatar seu XP!',
        segundosRestantes: segundosRestantes,
      );
    }
  }

  Future<void> _lidarComAppEmPrimeiroPlano() async {
    NotificationService().cancelarNotificacao(100);
    if (!_isRodando) return;

    final tempoSalvo = await TimeStorageService().recuperarTimestamp();
    if (tempoSalvo == null) return;

    await TimeStorageService().limparTimestamp();

    final diferencaEmSegundos = DateTime.now().difference(tempoSalvo).inSeconds;
    if (diferencaEmSegundos <= 0) return;

    if (segundosRestantes >= 0) {
      if (diferencaEmSegundos >= _segundosRestantesPorModo[_modoAtual]) {
        _segundosRestantesPorModo[_modoAtual] = 0;
        _finalizarSessaoAtual();
      } else {
        _segundosRestantesPorModo[_modoAtual] -= diferencaEmSegundos;
      }
      notifyListeners();
    }
  }

  // --- REGRAS DO TIMER ---
  void iniciarPausarTimer() {
    if (_isRodando) {
      _timer?.cancel();
      WakelockPlus.disable();
      _isRodando = false;
      notifyListeners();
    } else {
      if (_modoAtual == 0 && missaoSelecionadaNotifier.value == null) {
        onShowSnackbar('Selecione uma tarefa na lista abaixo para focar! 🎯', false);
        return;
      }
      WakelockPlus.enable();
      _isRodando = true;
      notifyListeners();

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_segundosRestantesPorModo[_modoAtual] > 0) {
          _segundosRestantesPorModo[_modoAtual]--;
        } else {
          _finalizarSessaoAtual();
        }
        notifyListeners();
      });
    }
  }

  void _finalizarSessaoAtual() {
    _timer?.cancel();
    WakelockPlus.disable();
    
    _isRodando = false;
    if (_modoAtual == 0 && _comboAtual < 3) _comboAtual++;
    notifyListeners();
    
    if (_modoAtual == 0) {
      _salvarSessaoFoco();
      _processarFimDeSessaoDaMissao();
    }
  }

  void resetarTimer({bool abortouFoco = false}) {
    if (abortouFoco && _comboAtual > 0) {
      onShowSnackbar('Ofensiva perdida! Você interrompeu o foco.', false);
    }
    _timer?.cancel();
    WakelockPlus.disable();
    if (abortouFoco) _comboAtual = 0;
    _isRodando = false;
    _segundosRestantesPorModo[_modoAtual] = _temposPadrao[_modoAtual];
    notifyListeners();
  }

  void mudarModo(int novoModo) {
    _timer?.cancel();
    WakelockPlus.disable();
    _isRodando = false;
    _modoAtual = novoModo;
    notifyListeners();
  }

  // --- REGRAS DE CONEXÃO COM A MISSÃO (API) ---
  Future<void> _salvarSessaoFoco() async {
    try {
      int bonusXp = calcularBonusCombo();
      await MissaoService.salvarSessaoHiperfoco(25, xpBonus: bonusXp, sessaoCompleta: true);
      int xpTotal = (25 * 10) + bonusXp;
      onShowSnackbar('+$xpTotal XP e +1 Foco! Sessão concluída! ${bonusXp > 0 ? '(+$bonusXp de Bônus)' : ''}', true);
      await onSincronizarProgresso();
    } catch (e) {
      debugPrint('Erro ao salvar sessão de foco: $e');
    }
  }

  Future<void> _processarFimDeSessaoDaMissao() async {
    if (missaoSelecionadaNotifier.value != null && !missaoSelecionadaNotifier.value!.concluida) {
      final missao = missaoSelecionadaNotifier.value!;
      missao.sessoesConcluidas++;
      
      bool recemConcluida = false;
      bool ganhouConsistencia = false;

      if (missao.sessoesConcluidas >= missao.sessoesNecessarias) {
        missao.concluida = true;
        recemConcluida = true;
        missaoSelecionadaNotifier.value = null;
      }
      
      missoesNotifier.value = List.from(missoesNotifier.value);

      if (missao.id != null) {
        try {
          ganhouConsistencia = await MissaoService.atualizarProgressoMissao(
            missao.id!, missao.sessoesConcluidas, missao.concluida, tags: missao.tags, prioridade: missao.prioridade,
          );
        } catch (e) {
          debugPrint('Erro API: $e');
        }
        await onSincronizarProgresso();
      }

      if (recemConcluida) onMissaoConcluida(missao, ganhouConsistencia);
    }
  }

  // -- Lógicas de Pulo Antecipado, Formatação e UI Helpers foram omitidas da prévia visual, mas estão codificadas no diff final (mesma lógica anterior) --
  void selecionarTarefa(Missao missao) {
    if (missao.concluida) return;
    missaoSelecionadaNotifier.value = (missaoSelecionadaNotifier.value == missao) ? null : missao;
  }

  // --- FORMATAÇÕES E CÁLCULOS UI ---
  String get tempoFormatado {
    int minutos = _segundosRestantesPorModo[_modoAtual] ~/ 60;
    int segundos = _segundosRestantesPorModo[_modoAtual] % 60;
    return '${minutos.toString().padLeft(2, '0')}:${segundos.toString().padLeft(2, '0')}';
  }

  Color get corAtual {
    if (_modoAtual == 0) return const Color(0xFFA855F7); // Roxo (Foco)
    if (_modoAtual == 1) return const Color(0xFF4ADE80); // Verde (Curta)
    return const Color(0xFFFBBF24); // Amarelo (Longa)
  }

  int calcularBonusCombo() {
    if (_comboAtual < 2) return 0;
    if (missaoSelecionadaNotifier.value != null) {
      String prioridade = missaoSelecionadaNotifier.value!.prioridade.toLowerCase();
      if (prioridade == 'alta') return 15;
      if (prioridade == 'media') return 10;
      if (prioridade == 'baixa') return 5;
    }
    return 2;
  }

  // --- FLUXO DE CONCLUSÃO ANTECIPADA ---
  void pularOuConfirmarAntecipado() {
    if (_modoAtual == 0) {
      _iniciarFluxoConclusaoAntecipada();
    } else {
      mudarModo((_modoAtual + 1) % 3);
    }
  }

  void _iniciarFluxoConclusaoAntecipada() {
    int tempoTotal = 25 * 60;
    int tempoDecorrido = tempoTotal - _segundosRestantesPorModo[_modoAtual];
    int quintosCompletados = tempoDecorrido ~/ (tempoTotal ~/ 5);
    
    int xpBasePrioridade = 10; 
    if (missaoSelecionadaNotifier.value != null) {
      String prio = missaoSelecionadaNotifier.value!.prioridade.toLowerCase();
      if (prio == 'alta') xpBasePrioridade = 30;
      else if (prio == 'media') xpBasePrioridade = 20;
      else if (prio == 'baixa') xpBasePrioridade = 10;
    }
    
    int xpGanho = quintosCompletados * (xpBasePrioridade ~/ 5);
    int minutosDecorridos = (tempoDecorrido / 60).round();
    if (minutosDecorridos < 1) minutosDecorridos = 1;
    
    int xpPeloTempo = minutosDecorridos * 10;
    onShowConfirmacaoAntecipada(quintosCompletados, xpPeloTempo, xpGanho, xpPeloTempo + xpGanho, () {
      _finalizarSessaoAntecipada(quintosCompletados, xpGanho, tempoDecorrido);
    });
  }

  Future<void> _finalizarSessaoAntecipada(int quintos, int xpGanho, int tempoDecorrido) async {
    _timer?.cancel();
    WakelockPlus.disable();
    _isRodando = false;
    notifyListeners();

    if (quintos > 0) {
      int minDecorridos = (tempoDecorrido / 60).round();
      if (minDecorridos < 1) minDecorridos = 1;
      await MissaoService.salvarSessaoHiperfoco(minDecorridos, xpBonus: xpGanho);
      onShowSnackbar('+${(minDecorridos * 10) + xpGanho} XP! Sessão concluída antecipadamente!', true);
      await _processarFimDeSessaoDaMissao();
      mudarModo(1);
    } else {
      onShowSnackbar('Sessão abortada sem recompensas.', false);
      resetarTimer(abortouFoco: true);
    }
  }
}