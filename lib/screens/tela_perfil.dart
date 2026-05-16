import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TelaPerfil extends StatefulWidget {
  const TelaPerfil({super.key});

  @override
  State<TelaPerfil> createState() => _TelaPerfilState();
}

class _TelaPerfilState extends State<TelaPerfil> {
  // Inventário
  // 'id' único para identificar, 'nome' do item, 'icone', e se foi 'desbloqueado'
  final List<Map<String, dynamic>> _inventario = [
    {'id': 1, 'nome': 'Set de Couro', 'icone': Icons.security, 'desbloqueado': true},
    {'id': 2, 'nome': 'Set de Ferro', 'icone': Icons.shield, 'desbloqueado': false},
    {'id': 3, 'nome': 'Set de Ouro', 'icone': Icons.workspace_premium, 'desbloqueado': false},
    {'id': 4, 'nome': 'Set de Diamante', 'icone': Icons.diamond, 'desbloqueado': false},
    {'id': 5, 'nome': 'Set de Netherite', 'icone': Icons.military_tech, 'desbloqueado': false},
  ];

  int _itemEquipadoId = 1;
  int _nivelUsuario = 1;
  int _xpUsuario = 0;
  int _tituloEquipadoId = 1;
  bool _isLoading = true;
  String _nomeUsuario = 'Herói';
  String _focoSt = '0', _discSt = '0', _intSt = '0', _forSt = '0', _conSt = '0';
  List<dynamic> _conquistasRecentes = [];

  // Lista de Títulos e níveis necessários para desbloqueá-los
  final List<Map<String, dynamic>> _titulos = [
    {'id': 1, 'nome': 'Iniciante da Jornada', 'nivelMinimo': 1},
    {'id': 2, 'nome': 'Aprendiz do Tempo', 'nivelMinimo': 5},
    {'id': 3, 'nome': 'Explorador do Foco', 'nivelMinimo': 10},
    {'id': 4, 'nome': 'Guerreiro da Disciplina', 'nivelMinimo': 15},
    {'id': 5, 'nome': 'Caçador de Hábitos', 'nivelMinimo': 20},
    {'id': 6, 'nome': 'Cavaleiro da Produtividade', 'nivelMinimo': 30},
    {'id': 7, 'nome': 'Feiticeiro da Concentração', 'nivelMinimo': 40},
    {'id': 8, 'nome': 'Paladino do Hiperfoco', 'nivelMinimo': 50},
    {'id': 9, 'nome': 'Mestre das Tarefas', 'nivelMinimo': 75},
    {'id': 10, 'nome': 'Lenda da Consistência', 'nivelMinimo': 100},
  ];

  @override
  void initState() {
    super.initState();
    _fetchPerfil();
  }

  Future<void> _fetchPerfil() async {
    String baseUrl = 'https://api-autenticacao-production.up.railway.app';
    if (!kIsWeb && Platform.isAndroid) {
      baseUrl = 'http://10.0.2.2:3000';
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token') ?? '';
      final savedName = prefs.getString('user_name');
      _nomeUsuario = savedName ?? 'Herói';
      // Resgata o nome salvo no login para evitar ficar sem nome em caso de erro da API
      if (savedName != null && savedName.isNotEmpty && mounted) {
        setState(() {
          _nomeUsuario = savedName;
        });
      }

      final response = await http.get(
        Uri.parse('$baseUrl/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      // --- DEBUG ---
      debugPrint('=== DEBUG API PERFIL ===');
      debugPrint('Token sendo enviado: $token');
      debugPrint('Status Code recebido: ${response.statusCode}');
      debugPrint('Corpo da resposta: ${response.body}');
      // -------------

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _nivelUsuario = data['nivel'] ?? 1;
            _xpUsuario = data['xp'] ?? 0;
            _tituloEquipadoId = data['tituloEquipadoId'] ?? 1;
            _itemEquipadoId = data['itemEquipadoId'] ?? 1;
            
           if (data['user'] != null && data['user']['name'] != null) {
              _nomeUsuario = data['user']['name'];
            }
            
            if (data['estatisticas'] != null) {
              _focoSt = data['estatisticas']['foco']?.toString() ?? '0';
              _discSt = data['estatisticas']['disciplina']?.toString() ?? '0';
              _intSt = data['estatisticas']['intelecto']?.toString() ?? '0';
              _forSt = data['estatisticas']['forca']?.toString() ?? '0';
              _conSt = data['estatisticas']['consistencia']?.toString() ?? '0';
            }

            if (data['itensDesbloqueados'] != null) {
              List<dynamic> desbloqueados = data['itensDesbloqueados'];
              for (var item in _inventario) {
                item['desbloqueado'] = desbloqueados.contains(item['id']);
              }
            }

            // Tenta pegar o histórico de tarefas usando possíveis chaves comuns de APIs
            if (data['tarefasConcluidas'] != null) {
              _conquistasRecentes = data['tarefasConcluidas'];
            } else if (data['conquistasRecentes'] != null) {
              _conquistasRecentes = data['conquistasRecentes'];
            } else if (data['historico'] != null) {
              _conquistasRecentes = data['historico'];
            }

            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Pega o nome do título equipado
    String nomeTituloEquipado = _titulos.firstWhere((t) => t['id'] == _tituloEquipadoId)['nome'];

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final corCard = isDark ? const Color(0xFF1E1E2A) : Colors.white;
    final corBorda = isDark ? const Color(0xFF252536) : Colors.grey.shade300;
    final corTextoPrincipal = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A24) : const Color(0xFFF3F4F6),
      body: SafeArea(
        child: _isLoading 
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF6B4EFF)))
            : SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho
              Row(
                children: [
                  Icon(Icons.person_outline, color: corTextoPrincipal, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Perfil do Herói',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: corTextoPrincipal,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // --- 1. CARTÃO DE INFORMAÇÕES BÁSICAS E AVATAR ---
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: corCard,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: corBorda, width: 2),
                ),
                child: Row(
                  children: [
                    // Avatar com Borda Gamificada
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF6B4EFF), width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6B4EFF).withOpacity(0.3),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        // Tenta carregar o GIF, se não existir usa o ícone fallback
                        child: Image.asset(
                          'assets/images/hero_avatar.gif',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: const Color(0xFF13131A),
                              child: const Icon(Icons.person, size: 40, color: Colors.grey),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    // Informações
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                        _nomeUsuario,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: corTextoPrincipal,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Título: $nomeTituloEquipado',
                            style: const TextStyle(
                              color: Color(0xFF4ADE80),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Barra de XP
                          Row(
                            children: [
                              Text('Nvl $_nivelUsuario', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                              value: (_xpUsuario % 100) / 100, // Calcula % barra de xp
                                  backgroundColor: isDark ? const Color(0xFF13131A) : Colors.grey.shade200,
                                    color: Colors.amber,
                                    minHeight: 8,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text('Nvl ${_nivelUsuario + 1}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // --- 2. ESTATÍSTICAS DETALHADAS ---
              const Text(
                'Atributos',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
              _buildEstatistica(icone: Icons.my_location, cor: const Color(0xFF6B4EFF), titulo: 'Foco', valor: _focoSt, isDark: isDark),
                  const SizedBox(width: 12),
              _buildEstatistica(icone: Icons.assignment_turned_in, cor: Colors.orangeAccent, titulo: 'Disciplina', valor: _discSt, isDark: isDark),
                  const SizedBox(width: 12),
              _buildEstatistica(icone: Icons.psychology, cor: Colors.blueAccent, titulo: 'Intelecto', valor: _intSt, isDark: isDark),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
              _buildEstatistica(icone: Icons.fitness_center, cor: const Color(0xFF4ADE80), titulo: 'Força', valor: _forSt, isDark: isDark),
                  const SizedBox(width: 12),
              _buildEstatistica(icone: Icons.loop, cor: Colors.redAccent, titulo: 'Consistência', valor: _conSt, isDark: isDark),
                  const SizedBox(width: 12),
                  // Dummy widget para manter a proporção da largura dos cards
                  Expanded(child: const SizedBox.shrink()),
                ],
              ),
              const SizedBox(height: 32),

              // --- 3. INVENTÁRIO (DECORAÇÕES) ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Inventário',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  Text(
                    'Equipamentos',
                    style: TextStyle(fontSize: 12, color: Color(0xFF6B4EFF)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 110,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _inventario.length,
                  itemBuilder: (context, index) {
                    final item = _inventario[index];
                    bool isEquipado = item['id'] == _itemEquipadoId;
                    bool isDesbloqueado = item['desbloqueado'];

                    return GestureDetector(
                      onTap: () {
                        if (isDesbloqueado) {
                          setState(() {
                            _itemEquipadoId = item['id'];
                          });
                        } else {
                          // Feedback caso o item esteja bloqueado
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Este item ainda está bloqueado!'),
                              backgroundColor: Colors.redAccent,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 90,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: isEquipado 
                              ? const Color(0xFF6B4EFF).withOpacity(0.2) 
                          : corCard,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                        color: isEquipado ? const Color(0xFF6B4EFF) : corBorda,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isDesbloqueado ? item['icone'] : Icons.lock,
                              color: isDesbloqueado 
                                ? (isEquipado ? const Color(0xFF6B4EFF) : corTextoPrincipal)
                                  : Colors.grey.withOpacity(0.5),
                              size: 32,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item['nome'],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: isEquipado ? FontWeight.bold : FontWeight.normal,
                              color: isDesbloqueado ? corTextoPrincipal : Colors.grey.withOpacity(0.5),
                              ),
                            ),
                            if (isEquipado)
                              const Padding(
                                padding: EdgeInsets.only(top: 4),
                                child: Text('EQUIPADO', style: TextStyle(color: Color(0xFF4ADE80), fontSize: 8, fontWeight: FontWeight.bold)),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),

              // --- 4. TÍTULOS ---
              const Text(
                'Títulos',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _titulos.length,
                  itemBuilder: (context, index) {
                    final tituloItem = _titulos[index];
                    bool isDesbloqueado = _nivelUsuario >= tituloItem['nivelMinimo'];
                    bool isEquipado = tituloItem['id'] == _tituloEquipadoId;

                    return GestureDetector(
                      onTap: () {
                        if (isDesbloqueado) {
                          setState(() {
                            _tituloEquipadoId = tituloItem['id'];
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Atinja o Nível ${tituloItem['nivelMinimo']} para desbloquear este título!'),
                              backgroundColor: Colors.redAccent,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isEquipado
                              ? const Color(0xFF6B4EFF).withOpacity(0.2)
                          : corCard,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                        color: isEquipado ? const Color(0xFF6B4EFF) : corBorda,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!isDesbloqueado) ...[
                              const Icon(Icons.lock, size: 14, color: Colors.grey),
                              const SizedBox(width: 6),
                            ],
                            Text(
                              tituloItem['nome'],
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isEquipado ? FontWeight.bold : FontWeight.normal,
                            color: isDesbloqueado ? corTextoPrincipal : Colors.grey.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),

              // --- 5. TAREFAS COMPLETADAS (HISTÓRICO) ---
              const Text(
                'Conquistas Recentes',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              if (_conquistasRecentes.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text('Nenhuma conquista recente encontrada.', style: TextStyle(color: Colors.grey)),
                )
              else
                ..._conquistasRecentes.take(5).map((tarefa) {
                  String titulo = tarefa['titulo'] ?? tarefa['title'] ?? tarefa['descricao'] ?? 'Tarefa Concluída';
                  String dataStr = tarefa['data'] ?? tarefa['createdAt'] ?? 'Recentemente';
                  
                  // Formata caso a data retorne no formato ISO do banco (ex: 2024-10-25T14:30:00Z)
                  if (dataStr.length >= 10 && dataStr.contains('T')) {
                    DateTime dt = DateTime.tryParse(dataStr) ?? DateTime.now();
                    dataStr = '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')} às ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
                  }

                  String xp = '+${tarefa['xp'] ?? tarefa['xpGanho'] ?? 5} XP';

                  return _buildTarefaCompletada(
                    titulo: titulo,
                    data: dataStr,
                    xp: xp,
                    isDark: isDark,
                  );
                }).toList(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // Widget auxiliar para as Estatísticas Superiores
  Widget _buildEstatistica({required IconData icone, required Color cor, required String titulo, required String valor, required bool isDark}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E2A) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? const Color(0xFF252536) : Colors.grey.shade300),
        ),
        child: Column(
          children: [
            Icon(icone, color: cor, size: 28),
            const SizedBox(height: 8),
            Text(
              valor,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                titulo,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget auxiliar para as Tarefas Completadas
  Widget _buildTarefaCompletada({required String titulo, required String data, required String xp, required bool isDark}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF252536) : Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF4ADE80).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Color(0xFF4ADE80), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(data, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Text(
            xp,
            style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}