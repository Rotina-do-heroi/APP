import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../models/missao.dart';
import '../../screens/tela_inicial.dart';
import '../../services/missao_service.dart';
import '../../services/time_storage_service.dart';
import '../../services/notification_service.dart';
import '../../main.dart'; 

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
    _sincronizarComGlobal();
  }

  void init() {
    WidgetsBinding.instance.addObserver(this);
    autoStartTimerNotifier.addListener(_checkAutoStart);
    _checkAutoStart();
  }

  void _checkAutoStart() {
    if (autoStartTimerNotifier.value) {
      autoStartTimerNotifier.value = false;
      // Garante reset ao iniciar via Tela Inicial para evitar o bug de tempo zerado
      _modoAtual = 0;
      _segundosRestantesPorModo[0] = _temposPadrao[0];
      iniciarPausarTimer();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    autoStartTimerNotifier.removeListener(_checkAutoStart);
    _timer?.cancel();
    WakelockPlus.disable();
    super.dispose();
  }

  void _sincronizarComGlobal() {
    isTimerRodandoGlobal.value = _isRodando;
    // segundosRestantesGlobal sempre monitora o modo de FOCO para travas de segurança da Tela Inicial
    segundosRestantesGlobal.value = _segundosRestantesPorModo[0];
  }

  void iniciarPausarTimer() {
    if (_isRodando) {
      _pararTimer();
    } else {
      if (_modoAtual == 0 && missaoSelecionadaNotifier.value == null) {
        onShowSnackbar('Selecione uma tarefa na lista abaixo para focar! 🎯', false);
        return;
      }
      
      // TRAVA: Impede iniciar se o tempo estiver em 00:00 (Elimina bug da conclusão infinita)
      if (_segundosRestantesPorModo[_modoAtual] <= 0) {
        onShowSnackbar('Sessão finalizada. Resete o tempo para iniciar um novo foco.', false);
        return;
      }

      WakelockPlus.enable();
      _isRodando = true;
      _sincronizarComGlobal();
      notifyListeners();

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_segundosRestantesPorModo[_modoAtual] > 0) {
          _segundosRestantesPorModo[_modoAtual]--;
          _sincronizarComGlobal();
          notifyListeners();
        } else {
          _finalizarSessaoAtual();
        }
      });
    }
  }

  void _pararTimer() {
    _timer?.cancel();
    _timer = null;
    WakelockPlus.disable();
    _isRodando = false;
    _sincronizarComGlobal();
    notifyListeners();
  }

  void _finalizarSessaoAtual() {
    _pararTimer();

    if (_modoAtual == 0) {
      if (_comboAtual < 3) _comboAtual++;
      _salvarSessaoFoco();
      _processarFimDeSessaoDaMissao();
      // O reset agora é assíncrono: depende do diálogo de parabéns ou do fim da função acima
    } else {
      confirmarFimSessao(); // Pausas resetam automaticamente
    }
  }

  /// Reset oficial do Timer. Chamado após o "Parabéns" ou automaticamente no fim de uma sessão simples.
  void confirmarFimSessao() {
    _segundosRestantesPorModo[0] = _temposPadrao[0]; // Restaura 25:00
    _modoAtual = 1; // Transição para Pausa Curta
    _segundosRestantesPorModo[1] = _temposPadrao[1];
    _sincronizarComGlobal();
    notifyListeners();
  }

  void resetarTimer({bool abortouFoco = false}) {
    if (abortouFoco && _comboAtual > 0) {
      onShowSnackbar('Ofensiva perdida! Você interrompeu o foco.', false);
    }
    _pararTimer();
    if (abortouFoco) _comboAtual = 0;
    _segundosRestantesPorModo[_modoAtual] = _temposPadrao[_modoAtual];
    _sincronizarComGlobal();
    notifyListeners();
  }

  void mudarModo(int novoModo) {
    if (_isRodando) {
      onShowSnackbar('Pare o cronômetro para mudar o modo.', false);
      return;
    }
    _modoAtual = novoModo;
    _segundosRestantesPorModo[_modoAtual] = _temposPadrao[_modoAtual];
    _sincronizarComGlobal();
    notifyListeners();
  }

  void selecionarTarefa(Missao missao) {
    if (missao.concluida) return;

    // TRAVA SÊNIOR: Impede troca durante o foco
    if (_isRodando) {
      onShowSnackbar('Finalize seu cronômetro antes de trocar de missão!', false);
      return;
    }
    
    // TRAVA SÊNIOR: Exige reset para nova missão (Impede levar tempo zerado de uma missão para outra)
    if (_modoAtual == 0 && _segundosRestantesPorModo[0] < _temposPadrao[0]) {
      onShowSnackbar('Resete o cronômetro para escolher outra missão.', false);
      return;
    }
    
    missaoSelecionadaNotifier.value = (missaoSelecionadaNotifier.value == missao) ? null : missao;
  }

  Future<void> _processarFimDeSessaoDaMissao() async {
    if (missaoSelecionadaNotifier.value != null) {
      final m = missaoSelecionadaNotifier.value!;
      m.sessoesConcluidas++;
      bool concluida = m.sessoesConcluidas >= m.sessoesNecessarias;
      
      if (concluida) {
        m.concluida = true;
        missaoSelecionadaNotifier.value = null;
      }
      
      missoesNotifier.value = List.from(missoesNotifier.value);
      
      if (m.id != null) {
        try {
          bool ganhou = await MissaoService.atualizarProgressoMissao(m.id!, m.sessoesConcluidas, m.concluida, tags: m.tags, prioridade: m.prioridade);
          await onSincronizarProgresso();
          
          if (concluida) {
            onMissaoConcluida(m, ganhou); // Reset ocorrerá via callback no diálogo "Parabéns"
          } else {
            confirmarFimSessao(); // Reset automático para sessões intermediárias
          }
        } catch (e) {
          confirmarFimSessao();
        }
      } else {
        confirmarFimSessao();
      }
    } else {
      confirmarFimSessao();
    }
  }

  Future<void> _salvarSessaoFoco() async {
    try {
      int bonus = calcularBonusCombo();
      await MissaoService.salvarSessaoHiperfoco(25, xpBonus: bonus, sessaoCompleta: true);
      onShowSnackbar('+${250 + bonus} XP! Sessão concluída com sucesso!', true);
    } catch (e) { debugPrint('Erro API: $e'); }
  }

  int calcularBonusCombo() {
    if (_comboAtual < 2) return 0;
    if (missaoSelecionadaNotifier.value == null) return 2;
    String p = missaoSelecionadaNotifier.value!.prioridade.toLowerCase();
    return p == 'alta' ? 15 : p == 'media' ? 10 : 5;
  }

  String get tempoFormatado {
    int min = segundosRestantes ~/ 60;
    int seg = segundosRestantes % 60;
    return '${min.toString().padLeft(2, '0')}:${seg.toString().padLeft(2, '0')}';
  }

  Color get corAtual => _modoAtual == 0 ? const Color(0xFFA855F7) : _modoAtual == 1 ? const Color(0xFF4ADE80) : const Color(0xFFFBBF24);

  void pularOuConfirmarAntecipado() {
    if (_modoAtual == 0) _iniciarFluxoConclusaoAntecipada();
    else mudarModo((_modoAtual + 1) % 3);
  }

  void _iniciarFluxoConclusaoAntecipada() {
    int decorrido = (25 * 60) - _segundosRestantesPorModo[0];
    int quintos = decorrido ~/ (5 * 60);
    int xpBase = missaoSelecionadaNotifier.value?.prioridade.toLowerCase() == 'alta' ? 30 : 20;
    int bonus = quintos * (xpBase ~/ 5);
    int xpTempo = (decorrido ~/ 60) * 10;
    onShowConfirmacaoAntecipada(quintos, xpTempo, bonus, xpTempo + bonus, () => _finalizarAntecipado(quintos, bonus, decorrido));
  }

  Future<void> _finalizarAntecipado(int quintos, int bonus, int decorrido) async {
    _pararTimer();
    if (quintos > 0) {
      int min = (decorrido / 60).round();
      await MissaoService.salvarSessaoHiperfoco(min, xpBonus: bonus);
      await _processarFimDeSessaoDaMissao();
      confirmarFimSessao();
    } else {
      resetarTimer(abortouFoco: true);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) _lidarComAppEmSegundoPlano();
    else if (state == AppLifecycleState.resumed) _lidarComAppPrimeiroPlano();
  }

  void _lidarComAppEmSegundoPlano() {
    if (!_isRodando) return;
    TimeStorageService().salvarTimestamp(DateTime.now());
    if (segundosRestantes > 0) {
      NotificationService().agendarNotificacaoFimTimer(id: 100, titulo: 'Tempo Esgotado! ⏳', corpo: 'Sua sessão terminou. Abra o app para resgatar o XP!', segundosRestantes: segundosRestantes);
    }
  }

  Future<void> _lidarComAppPrimeiroPlano() async {
    NotificationService().cancelarNotificacao(100);
    if (!_isRodando) return;
    final tempoSalvo = await TimeStorageService().recuperarTimestamp();
    if (tempoSalvo == null) return;
    await TimeStorageService().limparTimestamp();
    final diff = DateTime.now().difference(tempoSalvo).inSeconds;
    if (diff <= 0) return;
    if (diff >= _segundosRestantesPorModo[_modoAtual]) {
      _segundosRestantesPorModo[_modoAtual] = 0;
      _finalizarSessaoAtual();
    } else {
      _segundosRestantesPorModo[_modoAtual] -= diff;
      _sincronizarComGlobal();
      notifyListeners();
    }
  }
}
