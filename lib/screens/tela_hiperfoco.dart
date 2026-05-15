// Arquivo: lib/screens/tela_hiperfoco.dart
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async'; // <-- IMPORTANTE: Biblioteca para usar o Timer

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

  // Lista de tarefas vindas da API
  List<dynamic> _tarefas = [];
  bool _isLoadingTarefas = true;

  @override
  void initState() {
    super.initState();
    _fetchTarefas();
  }

  Future<void> _fetchTarefas() async {
    String baseUrl = 'http://localhost:3000';
    if (!kIsWeb && Platform.isAndroid) {
      baseUrl = 'http://10.0.2.2:3000';
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token') ?? '';

      // ATENÇÃO: Verifique se a rota para listar as tarefas é '/tarefas'
      final response = await http.get(
        Uri.parse('$baseUrl/tarefas'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            // Tenta lidar com array direto ou objeto { "tarefas": [...] }
            _tarefas = data is List ? data : (data['tarefas'] ?? []);
            _isLoadingTarefas = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoadingTarefas = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingTarefas = false);
    }
  }

  // Limpa o timer da memória quando a tela for fechada (Boa prática de performance)
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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
            }
          }
        });
      });
    }
  }

  Future<void> _salvarSessaoFoco() async {
    String baseUrl = 'http://localhost:3000';
    if (!kIsWeb && Platform.isAndroid) {
      baseUrl = 'http://10.0.2.2:3000';
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token') ?? '';

      final response = await http.post(
        Uri.parse('$baseUrl/hiperfoco/sessao'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'duracaoMinutos': 25,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('+ XP! Sessão de Foco salva com sucesso!'), backgroundColor: Colors.green),
          );
        }
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

                  if (_isLoadingTarefas)
                    const Center(child: CircularProgressIndicator(color: Color(0xFF6B4EFF)))
                  else if (_tarefas.isEmpty)
                    const Center(child: Padding(padding: EdgeInsets.all(16), child: Text('Nenhuma tarefa pendente.', style: TextStyle(color: Colors.grey))))
                  else
                    ..._tarefas.map((tarefa) => _buildTarefa(tarefa, isDark)).toList(),
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

  Future<void> _toggleTarefa(Map<String, dynamic> tarefa) async {
    // Optimistic Update: atualiza a interface antes mesmo de a API responder
    setState(() {
      if (tarefa['concluida'] != null) {
        tarefa['concluida'] = !tarefa['concluida'];
      } else if (tarefa['status'] != null) {
        tarefa['status'] = tarefa['status'] == 'concluida' ? 'pendente' : 'concluida';
      } else {
        tarefa['concluida'] = true;
      }
    });

    String baseUrl = 'http://localhost:3000';
    if (!kIsWeb && Platform.isAndroid) baseUrl = 'http://10.0.2.2:3000';
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token') ?? '';
      
      final response = await http.put(
        Uri.parse('$baseUrl/tarefas/${tarefa['id']}'), 
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode({'concluida': tarefa['concluida'] ?? (tarefa['status'] == 'concluida')}),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        if (mounted) {
          // Reverte a marcação visual da caixinha porque a API falhou
          setState(() {
            if (tarefa['concluida'] != null) tarefa['concluida'] = !tarefa['concluida'];
            else if (tarefa['status'] != null) tarefa['status'] = tarefa['status'] == 'concluida' ? 'pendente' : 'concluida';
          });
          // Mostra o erro retornado pelo Node.js
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro na API: ${response.body}'), backgroundColor: Colors.redAccent, duration: const Duration(seconds: 4)),
          );
        }
      }
    } catch (e) {
      debugPrint('Erro ao atualizar tarefa no banco: $e');
    }
  }

  Widget _buildTarefa(Map<String, dynamic> tarefa, bool isDark) {
    bool isConcluida = tarefa['concluida'] == true || tarefa['status'] == 'concluida';
    String titulo = tarefa['titulo'] ?? tarefa['title'] ?? tarefa['descricao'] ?? 'Tarefa sem título';

    final corFundoSub = isDark ? const Color(0xFF13131A) : Colors.grey.shade100;
    final corBorda = isDark ? const Color(0xFF252536) : Colors.grey.shade300;
    
    return GestureDetector(
      onTap: () => _toggleTarefa(tarefa),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isConcluida ? const Color.fromRGBO(29, 59, 49, 0.3) : corFundoSub,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isConcluida ? const Color(0xFF4ADE80) : corBorda,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: isConcluida ? const Color(0xFF4ADE80) : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(
                isConcluida ? Icons.check : Icons.crop_square,
                color: isConcluida ? (isDark ? const Color(0xFF1E1E2A) : Colors.white) : corBorda,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                titulo,
                style: TextStyle(
                color: isConcluida ? Colors.grey : (isDark ? Colors.white : Colors.black87),
                  fontWeight: FontWeight.w500,
                  decoration: isConcluida ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}