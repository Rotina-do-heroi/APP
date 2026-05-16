import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'screens/tela_inicial.dart';
import 'screens/tela_hiperfoco.dart';
import 'screens/tela_login.dart';
import 'screens/tela_perfil.dart';
import 'screens/tela_estatisticas.dart';

// Notifier global para controlar o tema em todo o app
final ValueNotifier<ThemeMode> temaNotifier = ValueNotifier(ThemeMode.dark);

// Notifier global para controlar a navegação das abas
final ValueNotifier<int> abaAtualNotifier = ValueNotifier(0);

// Chaves Globais para os alvos do Tutorial
final GlobalKey keyPerfil = GlobalKey();
final GlobalKey keyNovaMissao = GlobalKey();
final GlobalKey keyNavBar = GlobalKey();

// Função global para exibir o tutorial a partir de qualquer tela
void showAppTutorial(BuildContext context) {
  TutorialCoachMark(
    targets: [
      TargetFocus(
        identify: "perfil",
        keyTarget: keyPerfil,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              final isDark = Theme.of(context).brightness == Brightness.dark;
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
                    Text("Seu Perfil de Herói! 🛡️", style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text("Acompanhe seu Nível, Experiência (XP) e veja seus itens mágicos equipados. Complete missões para evoluir!", style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 16)),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      TargetFocus(
        identify: "nova_missao",
        keyTarget: keyNovaMissao,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              final isDark = Theme.of(context).brightness == Brightness.dark;
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
                    Text("Sua Jornada ⚔️", style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text("Toque aqui para criar missões. Você definirá quantas sessões de Foco são necessárias para completá-las.", style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 16)),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      TargetFocus(
        identify: "nav_bar",
        keyTarget: keyNavBar,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              final isDark = Theme.of(context).brightness == Brightness.dark;
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
                    Text("Navegação 🗺️", style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text("Aqui embaixo você alterna entre o Quadro de Missões, a tela de Hiperfoco (Timer), suas Estatísticas e o Perfil.", style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 16)),
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

void main() {
  runApp(const AppRotina());
}

class AppRotina extends StatelessWidget {
  const AppRotina({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: temaNotifier,
      builder: (context, modoAtual, _) {
        return MaterialApp(
          title: 'App Rotina MVP',
          debugShowCheckedModeBanner: false,
          themeMode: modoAtual,
          // Tema Claro
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFF3F4F6),
            primaryColor: const Color(0xFF6B4EFF),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: Colors.white,
              selectedItemColor: Color(0xFF6B4EFF),
              unselectedItemColor: Colors.grey,
            ),
          ),
          // Tema Escuro
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF1A1A24),
            primaryColor: const Color(0xFF6B4EFF),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: Color(0xFF252536),
              selectedItemColor: Color(0xFF6B4EFF),
              unselectedItemColor: Colors.grey,
            ),
          ),
          home: const TelaLogin(),
        );
      },
    );
  }
}

// Widget Stateful porque a tela precisa mudar quando clicamos na barra de navegação
class TelaPrincipal extends StatefulWidget {
  const TelaPrincipal({super.key});

  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  // Variável para controlar qual aba está selecionada
  int _indiceAtual = 0;

  // Lista de telas (por enquanto são apenas textos para visualização)
  final List<Widget> _telas = [
    const TelaInicialTarefas(),
    const TelaHiperfoco(),
    const TelaEstatisticas(),
    const TelaPerfil(),
  ];

  @override
  void initState() {
    super.initState();
    _verificarTutorial();

    // Fica escutando mudanças na aba para quando o Foco Rápido for acionado
    abaAtualNotifier.addListener(() {
      if (mounted) {
        setState(() {
          _indiceAtual = abaAtualNotifier.value;
        });
      }
    });
  }

  Future<void> _verificarTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    // Puxa se é o primeiro acesso (se for nulo, significa que é a primeira vez, então é true)
    final bool primeiroAcesso = prefs.getBool('primeiro_acesso_tutorial') ?? true;

    if (primeiroAcesso) {
      // Pequeno delay para garantir que a tela foi renderizada antes de exibir os balões
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) showAppTutorial(context);
      });
      // Salva que o usuário já viu o tutorial para não mostrar novamente
      await prefs.setBool('primeiro_acesso_tutorial', false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // O corpo do app vai mostrar a tela correspondente ao índice selecionado
      body: _telas[_indiceAtual],
      
      // Barra de navegação inferior
      bottomNavigationBar: BottomNavigationBar(
        key: keyNavBar,
        type: BottomNavigationBarType.fixed, // Mantém os ícones fixos
        currentIndex: _indiceAtual,
        onTap: (indice) {
          // Atualiza a tela quando um ícone é clicado
          abaAtualNotifier.value = indice;
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timer_outlined),
            activeIcon: Icon(Icons.timer),
            label: 'Foco',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: 'Progresso',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
