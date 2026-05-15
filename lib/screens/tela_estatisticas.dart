import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:math' show pi, cos, sin;

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

  @override
  void initState() {
    super.initState();
    _fetchEstatisticas();
  }

  Future<void> _fetchEstatisticas() async {
    String baseUrl = 'http://localhost:3000';
    if (!kIsWeb && Platform.isAndroid) {
      baseUrl = 'http://10.0.2.2:3000';
    }

    try {
      // ATENÇÃO: Substitua '/estatisticas' pela rota real da sua API.
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token') ?? '';

      final response = await http.get(
        Uri.parse('$baseUrl/estatisticas'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        }
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            focValue = (data['foco'] ?? 0).toDouble();
            disValue = (data['disciplina'] ?? 0).toDouble();
            intValue = (data['intelecto'] ?? 0).toDouble();
            forValue = (data['forca'] ?? 0).toDouble();
            conValue = (data['consistencia'] ?? 0).toDouble();
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
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
              const SizedBox(height: 32),

              // Gráfico de Radar (Custom Painter)
              Center(
                child: Container(
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
                      labels: ['FOC', 'DIS', 'INT', 'FOR', 'CON'],
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
              _buildSkillCard(
                sigla: 'FOC',
                nome: 'Foco',
                icone: Icons.my_location,
                cor: const Color(0xFF6B4EFF),
                level: (focValue / 10).floor(),
                descricao: 'Mede a qualidade da sua concentração e o respeito ao método de Hiperfoco.',
                criterio: 'Baseado em Sessões de Hiperfoco.',
                exemplo: 'Conclua 10 sessões de 25min sem pausas antes da hora para ganhar 1 FOC.',
                isDark: isDark,
              ),
              _buildSkillCard(
                sigla: 'DIS',
                nome: 'Disciplina',
                icone: Icons.assignment_turned_in,
                cor: Colors.orangeAccent,
                level: (disValue / 10).floor(),
                descricao: 'Sua capacidade de lidar com tarefas diárias e não deixar pendências.',
                criterio: 'Baseado em Quantidade de Tarefas.',
                exemplo: 'A cada 15 subtarefas concluídas, ganhe 1 DIS.',
                isDark: isDark,
              ),
              _buildSkillCard(
                sigla: 'INT',
                nome: 'Intelecto',
                icone: Icons.psychology,
                cor: Colors.blueAccent,
                level: (intValue / 10).floor(),
                descricao: 'Representa o tempo dedicado ao aprendizado profundo e à absorção de conhecimento.',
                criterio: 'Baseado em Horas de Estudo.',
                exemplo: 'A cada 5 horas acumuladas em "Estudo" ou "Leitura", ganhe 1 INT.',
                isDark: isDark,
              ),
              _buildSkillCard(
                sigla: 'FOR',
                nome: 'Força',
                icone: Icons.fitness_center,
                cor: const Color(0xFF4ADE80),
                level: (forValue / 10).floor(),
                descricao: 'Cuidado com o corpo. Evita o burnout e mantém sua saúde física.',
                criterio: 'Baseado em Hábitos de Manutenção.',
                exemplo: 'Pratique exercícios físicos. A cada 3 dias consecutivos, ganhe 1 FOR.',
                isDark: isDark,
              ),
              _buildSkillCard(
                sigla: 'CON',
                nome: 'Consistência',
                icone: Icons.loop,
                cor: Colors.redAccent,
                level: (conValue / 10).floor(),
                descricao: 'A constância e a capacidade de manter a rotina mesmo em dias desafiadores.',
                criterio: 'Baseado em Streaks (Ofensivas).',
                exemplo: 'A cada 7 dias seguidos de login e 1 tarefa concluída, ganhe 1 CON.',
                isDark: isDark,
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
                  color: cor.withOpacity(0.2),
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
              border: Border.all(color: cor.withOpacity(0.3)),
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
      ..color = corPrimaria.withOpacity(0.4)
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

    // 3. Desenhar a Área do Atributo Atual
    Path pathValor = Path();
    for (int i = 0; i < numPontos; i++) {
      double angulo = -pi / 2 + (2 * pi / numPontos) * i;
      // O valor máximo é 100, então mapeamos de 0-100 para o raio.
      double raioValor = radius * (valores[i] / 100);
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