import 'package:flutter/material.dart';
import 'screens/tela_inicial.dart';
import 'screens/tela_hiperfoco.dart';
import 'screens/tela_login.dart';
import 'screens/tela_perfil.dart';
import 'screens/tela_estatisticas.dart';

// Notifier global para controlar o tema em todo o app
final ValueNotifier<ThemeMode> temaNotifier = ValueNotifier(ThemeMode.dark);

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
  Widget build(BuildContext context) {
    return Scaffold(
      // O corpo do app vai mostrar a tela correspondente ao índice selecionado
      body: _telas[_indiceAtual],
      
      // Barra de navegação inferior
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Mantém os ícones fixos
        currentIndex: _indiceAtual,
        onTap: (indice) {
          // Atualiza a tela quando um ícone é clicado
          setState(() {
            _indiceAtual = indice;
          });
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
