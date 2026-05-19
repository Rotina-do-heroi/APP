import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' show pi, cos, sin;
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '../services/perfil_service.dart';

class TelaEstatisticas extends StatefulWidget {
  const TelaEstatisticas({super.key});

  @override
  State<TelaEstatisticas> createState() => _TelaEstatisticasState();
}

class _TelaEstatisticasState extends State<TelaEstatisticas> {
  // Valores reais vindos da API
  double focValue = 0; // Foco
  double disValue = 0; // Disciplina
  double intValue = 0; // Intelecto
  double forValue = 0; // Força
  double conValue = 0; // Consistência

  bool _isLoading = true;

  // Chaves para o Tutorial
  final GlobalKey _keyGrafico = GlobalKey();
  final GlobalKey _keyHabilidades = GlobalKey();

  @override
  void initState() {
    super.initState();
    _fetchEstatisticas();
    _verificarTutorial();
  }

  Future<void> _verificarTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id') ?? '';
    final chaveTutorial = 'primeiro_acesso_estatisticas_$userId';
    // Puxa se é o primeiro acesso na tela de Estatísticas
    final bool primeiroAcesso = prefs.getBool(chaveTutorial) ?? true;

    if (primeiroAcesso) {
      Future.delayed(const Duration(milliseconds: 800), () {
        if (!mounted) return;
        _showEstatisticasTutorial(context);
      });
      // Salva que o usuário já viu o tutorial dessa tela
      await prefs.setBool(chaveTutorial, false);
    }
  }

  void _showEstatisticasTutorial(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    TutorialCoachMark(
      targets: [
        TargetFocus(
          identify: "grafico",
          keyTarget: _keyGrafico,
          contents: [
            TargetContent(
              align: ContentAlign.bottom,
              builder: (context, controller) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  final contexto = _keyGrafico.currentContext;
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
                      Text("Gráfico de Radar 🕸️", style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Text("Visualize rapidamente o equilíbrio dos seus atributos. Um herói forte é um herói equilibrado!", style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 16)),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        TargetFocus(
          identify: "habilidades",
          keyTarget: _keyHabilidades,
          contents: [
            TargetContent(
              align: ContentAlign.top,
              builder: (context, controller) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  final contexto = _keyHabilidades.currentContext;
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
                      Text("Detalhes e Níveis 📈", style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Text("Entenda como cada atributo funciona e o que você precisa fazer para subir o nível deles.", style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 16)),
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

  Future<void> _fetchEstatisticas() async {
    try {
      // Utiliza o PerfilService que já busca e mescla os dados da API Geral do RPG
      final perfilData = await PerfilService.buscarPerfil();
      final estatisticas = perfilData['estatisticas'];
      
      if (!mounted) return;
      
      setState(() {
        focValue = double.tryParse(estatisticas['foco'].toString()) ?? 0;
        disValue = double.tryParse(estatisticas['disciplina'].toString()) ?? 0;
        intValue = double.tryParse(estatisticas['intelecto'].toString()) ?? 0;
        forValue = double.tryParse(estatisticas['forca'].toString()) ?? 0;
        conValue = double.tryParse(estatisticas['consistencia'].toString()) ?? 0;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Erro ao buscar estatísticas: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      Icon(Icons.bar_chart_outlined, color: corTextoPrincipal, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Atributos do Herói',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: corTextoPrincipal,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.help_outline, color: isDark ? Colors.blueAccent : Colors.blue),
                    onPressed: () => _showEstatisticasTutorial(context),
                    tooltip: 'Ver Tutorial',
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Gráfico de Radar (Custom Painter)
              Center(
                child: Container(
                  key: _keyGrafico,
                  height: 300,
                  width: 300,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: corCard,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: corBorda, width: 2),
                  ),
                  child: CustomPaint(
                    size: const Size(250, 250),
                    painter: RadarChartPainter(
                      valores: [focValue, disValue, intValue, forValue, conValue],
                      labels: ['FOC', 'COR', 'INT', 'FOR', 'CON'],
                      corPrimaria: const Color(0xFF6B4EFF),
                      corFundo: isDark ? const Color(0xFF252536) : Colors.grey.shade300,
                      corTextoLabel: corTextoPrincipal,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              const Text(
                'Detalhes das Habilidades',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              const SizedBox(height: 16),

              // Lista de Habilidades Detalhadas
              Container(
                key: _keyHabilidades,
                child: Column(
                  children: [
                    _buildSkillCard(
                      sigla: 'FOC',
                      nome: 'Foco',
                      icone: Icons.my_location,
                      cor: const Color(0xFF6B4EFF),
                      level: (focValue / 10).floor() + 1, // Começa no Nível 1
                      descricao: 'Mede a qualidade da sua concentração e o respeito ao método de Hiperfoco.',
                      criterio: 'Baseado em Sessões de Hiperfoco.',
                    exemplo: 'Conclua 1 sessão inteira sem pausas para ganhar 1 FOC.',
                      isDark: isDark,
                    ),
                    _buildSkillCard(
                      sigla: 'COR',
                      nome: 'Coragem',
                      icone: Icons.local_fire_department,
                      cor: Colors.orangeAccent,
                      level: (disValue / 10).floor() + 1, // Começa no Nível 1
                      descricao: 'Sua bravura para enfrentar as missões mais difíceis e importantes do dia sem hesitar.',
                      criterio: 'Baseado em Missões de Prioridade Alta.',
                      exemplo: 'Conclua missões marcadas como Prioridade Alta para ganhar 1 COR.',
                      isDark: isDark,
                    ),
                    _buildSkillCard(
                      sigla: 'INT',
                      nome: 'Intelecto',
                      icone: Icons.psychology,
                      cor: Colors.blueAccent,
                      level: (intValue / 10).floor() + 1, // Começa no Nível 1
                      descricao: 'Representa o tempo dedicado ao aprendizado profundo e à absorção de conhecimento.',
                      criterio: 'Baseado em Horas de Estudo.',
                    exemplo: 'A cada 1 hora acumulada em "Estudo" ou "Leitura", ganhe 1 INT.',
                      isDark: isDark,
                    ),
                    _buildSkillCard(
                      sigla: 'FOR',
                      nome: 'Força',
                      icone: Icons.fitness_center,
                      cor: const Color(0xFF4ADE80),
                      level: (forValue / 10).floor() + 1, // Começa no Nível 1
                      descricao: 'Cuidado com o corpo. Evita o burnout e mantém sua saúde física.',
                      criterio: 'Baseado em Hábitos de Manutenção.',
                    exemplo: 'Complete uma missão relacionada a este atributo para ganhar 1 FOR.',
                      isDark: isDark,
                    ),
                    _buildSkillCard(
                      sigla: 'CON',
                      nome: 'Consistência',
                      icone: Icons.loop,
                      cor: Colors.redAccent,
                      level: (conValue / 10).floor() + 1, // Começa no Nível 1
                      descricao: 'A constância e a capacidade de manter a rotina mesmo em dias desafiadores.',
                      criterio: 'Baseado em Streaks (Ofensivas).',
                    exemplo: 'Faça login e conclua pelo menos 1 missão no dia para ganhar 1 CON.',
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkillCard({
    required String sigla,
    required String nome,
    required IconData icone,
    required Color cor,
    required int level,
    required String descricao,
    required String criterio,
    required String exemplo,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF252536) : Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: cor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icone, color: cor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$nome ($sigla)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                    ),
                    Text(
                      'Nível $level',
                      style: TextStyle(color: cor, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        Text(descricao, style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 14)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
            color: isDark ? const Color(0xFF13131A) : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cor.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.arrow_upward, color: cor, size: 16),
                    const SizedBox(width: 6),
                    Text('Level Up', style: TextStyle(color: cor, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 6),
            Text(criterio, style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 4),
                Text(exemplo, style: const TextStyle(color: Colors.grey, fontSize: 13, fontStyle: FontStyle.italic)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- CUSTOM PAINTER PARA O GRÁFICO DE RADAR ---
class RadarChartPainter extends CustomPainter {
  final List<double> valores;
  final List<String> labels;
  final Color corPrimaria;
  final Color corFundo;
  final Color corTextoLabel;

  RadarChartPainter({
    required this.valores,
    required this.labels,
    required this.corPrimaria,
    required this.corFundo,
    required this.corTextoLabel,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final center = Offset(centerX, centerY);
    final radius = size.width / 2;
    final int numPontos = valores.length;

    // Pincéis
    final Paint paintFundo = Paint()
      ..color = corFundo
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final Paint paintEixos = Paint()
      ..color = corFundo
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final Paint paintPoligono = Paint()
      ..color = corPrimaria.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;

    final Paint paintBordaPoligono = Paint()
      ..color = corPrimaria
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    // 1. Desenhar a "Teia" (Pentágonos concêntricos)
    for (int i = 1; i <= 4; i++) {
      Path pathTeia = Path();
      double raioAtual = radius * (i / 4);
      for (int j = 0; j < numPontos; j++) {
        double angulo = -pi / 2 + (2 * pi / numPontos) * j;
        double x = centerX + raioAtual * cos(angulo);
        double y = centerY + raioAtual * sin(angulo);
        if (j == 0) {
          pathTeia.moveTo(x, y);
        } else {
          pathTeia.lineTo(x, y);
        }
      }
      pathTeia.close();
      canvas.drawPath(pathTeia, paintFundo);
    }

    // 2. Desenhar Eixos e Labels
    final textStyle = TextStyle(color: corTextoLabel, fontSize: 12, fontWeight: FontWeight.bold);
    for (int i = 0; i < numPontos; i++) {
      double angulo = -pi / 2 + (2 * pi / numPontos) * i;
      double xExtremo = centerX + radius * cos(angulo);
      double yExtremo = centerY + radius * sin(angulo);
      canvas.drawLine(center, Offset(xExtremo, yExtremo), paintEixos);

      // Labels com um leve deslocamento (padding)
      double xLabel = centerX + (radius + 20) * cos(angulo);
      double yLabel = centerY + (radius + 15) * sin(angulo);
      final textSpan = TextSpan(text: labels[i], style: textStyle);
      final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
      textPainter.layout();
      textPainter.paint(canvas, Offset(xLabel - textPainter.width / 2, yLabel - textPainter.height / 2));
    }

    // Encontra o maior atributo para escalar o gráfico dinamicamente (Mínimo de 10)
    double maxValue = 10;
    for (var v in valores) {
      if (v > maxValue) maxValue = v;
    }

    // 3. Desenhar a Área do Atributo Atual
    Path pathValor = Path();
    for (int i = 0; i < numPontos; i++) {
      double angulo = -pi / 2 + (2 * pi / numPontos) * i;
      // Escala o raio baseado no maxValue dinâmico
      double raioValor = radius * (valores[i] / maxValue);
      double x = centerX + raioValor * cos(angulo);
      double y = centerY + raioValor * sin(angulo);
      if (i == 0) pathValor.moveTo(x, y);
      else pathValor.lineTo(x, y);
    }
    pathValor.close();

    canvas.drawPath(pathValor, paintPoligono);
    canvas.drawPath(pathValor, paintBordaPoligono);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}