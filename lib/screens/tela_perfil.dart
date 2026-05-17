import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '../services/perfil_service.dart';
import '../services/auth_service.dart';
import 'tela_login.dart';
import 'tela_editar_perfil.dart';
import '../services/inventario_service.dart'; // Importante para poder salvar os itens ao equipá-los pela tela de Perfil
import '../main.dart'; // Importa os notifiers globais de XP e Nível


class TelaPerfil extends StatefulWidget {
  const TelaPerfil({super.key});

  @override
  State<TelaPerfil> createState() => _TelaPerfilState();
}

class _TelaPerfilState extends State<TelaPerfil> {
  // Inventário
  // 'id' único para identificar, 'nome' do item, 'icone', e se foi 'desbloqueado'
  final List<Map<String, dynamic>> _inventario = [
    {'id': 0, 'nome': 'Sem armadura', 'icone': Icons.accessibility_new, 'desbloqueado': true},
    {'id': 1, 'nome': 'Set de Couro', 'icone': Icons.security, 'desbloqueado': false},
    {'id': 2, 'nome': 'Set de Ferro', 'icone': Icons.shield, 'desbloqueado': false},
    {'id': 3, 'nome': 'Set de Ouro', 'icone': Icons.workspace_premium, 'desbloqueado': false},
    {'id': 4, 'nome': 'Set de Diamante', 'icone': Icons.diamond, 'desbloqueado': false},
    {'id': 5, 'nome': 'Set de Netherite', 'icone': Icons.military_tech, 'desbloqueado': false},
  ];

  int _itemEquipadoId = 0;
  int _tituloEquipadoId = 1;
  bool _isLoading = true;
  String _nomeUsuario = 'Herói';
  String _emailUsuario = '';
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

  // Chaves para o Tutorial
  final GlobalKey _keyInfoBasica = GlobalKey();
  final GlobalKey _keyAtributos = GlobalKey();
  final GlobalKey _keyInventario = GlobalKey();
  final GlobalKey _keyTitulos = GlobalKey();

  @override
  void initState() {
    super.initState();
    _fetchPerfil();
    _verificarTutorial();
  }

  Future<void> _verificarTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id') ?? '';
    final chaveTutorial = 'primeiro_acesso_perfil_tela_$userId';
    // Puxa se é o primeiro acesso na tela de Perfil
    final bool primeiroAcesso = prefs.getBool(chaveTutorial) ?? true;

    if (primeiroAcesso) {
      Future.delayed(const Duration(milliseconds: 800), () {
        if (!mounted) return;
        _showPerfilTutorial(context);
      });
      // Salva que o usuário já viu o tutorial dessa tela
      await prefs.setBool(chaveTutorial, false);
    }
  }

  void _showPerfilTutorial(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    TutorialCoachMark(
      targets: [
        TargetFocus(
          identify: "info_basica",
          keyTarget: _keyInfoBasica,
          contents: [
            TargetContent(
              align: ContentAlign.bottom,
              builder: (context, controller) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  final contexto = _keyInfoBasica.currentContext;
                  if (contexto != null) {
                    Scrollable.ensureVisible(contexto,
                        duration: const Duration(milliseconds: 300), alignment: 0.5);
                  }
                });
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF252536) : Colors.white,
                    borderRadius: const BorderRadius.all(Radius.circular(16)),
                    border: Border.all(color: const Color(0xFF6B4EFF), width: 2),
                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Status do Herói 🛡️", style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Text("Aqui você vê seu nível atual, seu título e o progresso para alcançar o próximo nível!", style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 16)),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        TargetFocus(
          identify: "atributos",
          keyTarget: _keyAtributos,
          contents: [
            TargetContent(
              align: ContentAlign.bottom,
              builder: (context, controller) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  final contexto = _keyAtributos.currentContext;
                  if (contexto != null) {
                    Scrollable.ensureVisible(contexto,
                        duration: const Duration(milliseconds: 300), alignment: 0.5);
                  }
                });
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF252536) : Colors.white,
                    borderRadius: const BorderRadius.all(Radius.circular(16)),
                    border: Border.all(color: const Color(0xFF6B4EFF), width: 2),
                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Seus Atributos 📊", style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Text("Veja quantos pontos de progresso você acumulou em cada habilidade com base no seu desempenho nas missões!", style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 16)),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        TargetFocus(
          identify: "inventario",
          keyTarget: _keyInventario,
          contents: [
            TargetContent(
              align: ContentAlign.top,
              builder: (context, controller) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  final contexto = _keyInventario.currentContext;
                  if (contexto != null) {
                    Scrollable.ensureVisible(contexto,
                        duration: const Duration(milliseconds: 300), alignment: 0.5);
                  }
                });
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF252536) : Colors.white,
                    borderRadius: const BorderRadius.all(Radius.circular(16)),
                    border: Border.all(color: const Color(0xFF6B4EFF), width: 2),
                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Equipamentos 🎒", style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Text("Complete missões para desbloquear e equipar novas armaduras.", style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 16)),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        TargetFocus(
          identify: "titulos",
          keyTarget: _keyTitulos,
          contents: [
            TargetContent(
              align: ContentAlign.top,
              builder: (context, controller) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  final contexto = _keyTitulos.currentContext;
                  if (contexto != null) {
                    Scrollable.ensureVisible(contexto,
                        duration: const Duration(milliseconds: 300), alignment: 0.5);
                  }
                });
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF252536) : Colors.white,
                    borderRadius: const BorderRadius.all(Radius.circular(16)),
                    border: Border.all(color: const Color(0xFF6B4EFF), width: 2),
                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Títulos de Glória 📜", style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Text("Suba de nível para ganhar novos títulos e mostrar o quão focado você é!", style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 16)),
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

  Future<void> _fetchPerfil() async {
    try {
      // Chamada usando o método estático conforme o padrão de serviços
      final perfilData = await PerfilService.buscarPerfil();
      
      if (!mounted) return;
      
      setState(() {
        _tituloEquipadoId = perfilData['tituloEquipadoId'];
        _itemEquipadoId = perfilData['itemEquipadoId'];
        _nomeUsuario = perfilData['nomeUsuario'];
        _emailUsuario = perfilData['emailUsuario'] ?? '';
        
        final estatisticas = perfilData['estatisticas'];
        _focoSt = estatisticas['foco'];
        _discSt = estatisticas['disciplina'];
        _intSt = estatisticas['intelecto'];
        _forSt = estatisticas['forca'];
        _conSt = estatisticas['consistencia'];

        // Fallback de segurança vazio caso a API retorne null no primeiro login
        List<dynamic> desbloqueados = perfilData['itensDesbloqueados'] ?? [];
        for (var item in _inventario) {
          if (item['id'] == 0) {
            item['desbloqueado'] = true; // Sempre disponível
          } else {
            item['desbloqueado'] = desbloqueados.contains(item['id']);
          }
        }

        _conquistasRecentes = perfilData['conquistasRecentes'];
        _isLoading = false;
      });
      xpNotifier.value = perfilData['xp'] ?? 0;
      nivelNotifier.value = perfilData['nivel'] ?? 1;
    } catch (e) {
      debugPrint('Erro ao buscar perfil na Tela: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _confirmarLogout(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E1E2A) : Colors.white,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
          title: Row(
            children: [
              const Icon(Icons.exit_to_app, color: Colors.redAccent),
              const SizedBox(width: 8),
              Text('Sair da Conta', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
            ],
          ),
          content: Text(
            'Tem certeza que deseja sair da conta atual?',
            style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // Fecha o dialog usando o contexto do dialog
                await AuthService.logout(); // Limpa os dados de sessão
                
                if (!context.mounted) return; // Verifica o contexto passado na função, e não o Estado
                
                // Remove todas as rotas anteriores e envia para o Login
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const TelaLogin()),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              child: const Text('Sair', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Pega o título equipado com tratamento de erro e tipagem segura
    final Map<String, dynamic> tituloEncontrado = _titulos.firstWhere(
      (t) => t['id'] == _tituloEquipadoId,
      orElse: () => _titulos.first,
    );
    String nomeTituloEquipado = tituloEncontrado['nome'] as String;

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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit_outlined, color: corTextoPrincipal),
                        onPressed: () async {
                          final atualizou = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => TelaEditarPerfil(nomeAtual: _nomeUsuario, emailAtual: _emailUsuario)),
                          );
                          if (!mounted) return;
                          if (atualizou == true) _fetchPerfil();
                        },
                        tooltip: 'Editar Perfil',
                      ),
                      IconButton(
                        icon: Icon(Icons.help_outline, color: isDark ? Colors.blueAccent : Colors.blue),
                        onPressed: () => _showPerfilTutorial(context),
                        tooltip: 'Ver Tutorial',
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout, color: Colors.redAccent),
                        onPressed: () => _confirmarLogout(context),
                        tooltip: 'Sair da Conta',
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // --- 1. CARTÃO DE INFORMAÇÕES BÁSICAS E AVATAR ---
              Container(
                key: _keyInfoBasica,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: corCard,
                  borderRadius: const BorderRadius.all(Radius.circular(24)),
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
                        color: const Color(0xFF6B4EFF).withValues(alpha: 0.3),
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
                      AnimatedBuilder(
                        animation: Listenable.merge([xpNotifier, nivelNotifier]),
                        builder: (context, _) {
                          final int nvl = nivelNotifier.value;
                          final int xp = xpNotifier.value;
                          return Row(
                            children: [
                              Text('Nvl $nvl', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                                  child: LinearProgressIndicator(
                                    value: (xp % 100) / 100, // Calcula % barra de xp
                                    backgroundColor: isDark ? const Color(0xFF13131A) : Colors.grey.shade200,
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
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // --- 2. ESTATÍSTICAS DETALHADAS ---
              Container(
                key: _keyAtributos,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                        const Expanded(child: SizedBox.shrink()), // const movido para englobar o Widget inteiro
                      ],
                    ),
                  ],
                ),
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
                key: _keyInventario,
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
                          // Salva a alteração na API no Back-ground
                          InventarioService.equiparItem(item['id']).catchError((e) {
                            debugPrint('Erro ao equipar item no perfil: $e');
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Item equipado com sucesso!'),
                              backgroundColor: Color(0xFF4ADE80),
                              duration: Duration(seconds: 2),
                            ),
                          );
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
                          ? const Color(0xFF6B4EFF).withValues(alpha: 0.2) 
                          : corCard,
                          borderRadius: const BorderRadius.all(Radius.circular(16)),
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
                            : Colors.grey.withValues(alpha: 0.5),
                              size: 32,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item['nome'],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: isEquipado ? FontWeight.bold : FontWeight.normal,
                        color: isDesbloqueado ? corTextoPrincipal : Colors.grey.withValues(alpha: 0.5),
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
                key: _keyTitulos,
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _titulos.length,
                  itemBuilder: (context, index) {
                    final tituloItem = _titulos[index];
                bool isDesbloqueado = nivelNotifier.value >= tituloItem['nivelMinimo'];
                    bool isEquipado = tituloItem['id'] == _tituloEquipadoId;

                    return GestureDetector(
                      onTap: () {
                        if (isDesbloqueado) {
                          setState(() {
                            _tituloEquipadoId = tituloItem['id'];
                          });
                          // Salva a alteração na API no Back-ground
                          InventarioService.equiparTitulo(tituloItem['id']).catchError((e) {
                            debugPrint('Erro ao equipar título no perfil: $e');
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Título equipado com sucesso!'),
                              backgroundColor: Color(0xFF4ADE80),
                              duration: Duration(seconds: 2),
                            ),
                          );
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
                          ? const Color(0xFF6B4EFF).withValues(alpha: 0.2)
                          : corCard,
                          borderRadius: const BorderRadius.all(Radius.circular(12)),
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
                      color: isDesbloqueado ? corTextoPrincipal : Colors.grey.withValues(alpha: 0.5),
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
                    // toLocal() garante que se a API devolver a data de Londres (UTC), ela seja convertida para a hora do celular do usuário
                    DateTime dt = DateTime.tryParse(dataStr)?.toLocal() ?? DateTime.now();
                    dataStr = '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')} às ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
                  }

                  String xp = '+${tarefa['xp'] ?? tarefa['xpGanho'] ?? 5} XP';

                  return _buildTarefaCompletada(
                    titulo: titulo,
                    data: dataStr,
                    xp: xp,
                    isDark: isDark,
                  );
                }),
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
                borderRadius: const BorderRadius.all(Radius.circular(16)),
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
                borderRadius: const BorderRadius.all(Radius.circular(16)),
        border: Border.all(color: isDark ? const Color(0xFF252536) : Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF4ADE80).withValues(alpha: 0.2),
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