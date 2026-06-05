import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class HiperfocoTutorial {
  static void showTutorial(
    BuildContext context, {
    required GlobalKey keyAbas,
    required GlobalKey keyTimer,
    required GlobalKey keyControles,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    TutorialCoachMark(
      targets: [
        TargetFocus(
          identify: "abas",
          keyTarget: keyAbas,
          contents: [
            TargetContent(
              align: ContentAlign.bottom,
              builder: (context, controller) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  final contexto = keyAbas.currentContext;
                  if (contexto != null) {
                    Scrollable.ensureVisible(contexto, duration: const Duration(milliseconds: 300), alignment: 0.5);
                  }
                });
                return _buildTooltip(isDark, "Modos de Tempo ⏳", "Alterne entre Foco, Pausa Curta e Pausa Longa. O cronômetro ajusta automaticamente.");
              },
            ),
          ],
        ),
        TargetFocus(
          identify: "timer",
          keyTarget: keyTimer,
          contents: [
            TargetContent(
              align: ContentAlign.bottom,
              builder: (context, controller) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  final contexto = keyTimer.currentContext;
                  if (contexto != null) {
                    Scrollable.ensureVisible(contexto, duration: const Duration(milliseconds: 300), alignment: 0.5);
                  }
                });
                return _buildTooltip(isDark, "Cronômetro ⏱️", "Acompanhe seu tempo aqui. Cumpra o foco até o relógio zerar para computar a sessão e ganhar XP!");
              },
            ),
          ],
        ),
        TargetFocus(
          identify: "controles",
          keyTarget: keyControles,
          contents: [
            TargetContent(
              align: ContentAlign.top,
              builder: (context, controller) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  final contexto = keyControles.currentContext;
                  if (contexto != null) {
                    Scrollable.ensureVisible(contexto, duration: const Duration(milliseconds: 300), alignment: 0.5);
                  }
                });
                return _buildTooltip(isDark, "Controles ⏯️", "Inicie ou pause sua sessão. Você também pode resetar caso se perca, ou pular de fase se terminar rápido.");
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

  static Widget _buildTooltip(bool isDark, String titulo, String descricao) {
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
          Text(titulo, style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(descricao, style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 16)),
        ],
      ),
    );
  }
}