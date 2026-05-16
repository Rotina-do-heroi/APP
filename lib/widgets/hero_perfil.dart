// Arquivo: lib/widgets/hero_perfil.dart
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart'; // Importa o main.dart para acessar o temaNotifier
import '../screens/tela_inventario.dart'; // Importa a nova tela de inventário
import '../screens/tela_inicial.dart'; // Para acessar os Notifiers do foco

class HeroPerfil extends StatefulWidget {
  const HeroPerfil({super.key});

  @override
  State<HeroPerfil> createState() => _HeroPerfilState();
}

class _HeroPerfilState extends State<HeroPerfil> {
  String _nome = "Herói";
  int _nivelAtual = 1;
  int _xpAtual = 0;
  int _itemEquipadoId = 1;

  // Mapeia o ID do item equipado para o ícone correspondente
  IconData _getIconeEquipado() {
    switch (_itemEquipadoId) {
      case 1: return Icons.security;
      case 2: return Icons.shield;
      case 3: return Icons.workspace_premium;
      case 4: return Icons.diamond;
      case 5: return Icons.military_tech;
      default: return Icons.person;
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchDadosPerfil();
  }

  Future<void> _fetchDadosPerfil() async {
    const String baseUrl = 'https://api-autenticacao-production.up.railway.app';

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token') ?? '';
      final savedName = prefs.getString('user_name');

      if (savedName != null && savedName.isNotEmpty && mounted) {
        setState(() {
          _nome = savedName;
        });
      }

      final response = await http.get(
        Uri.parse('$baseUrl/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _nivelAtual = data['nivel'] ?? 1;
            _xpAtual = data['xp'] ?? 0;
            _itemEquipadoId = data['itemEquipadoId'] ?? 1;
            
            // Extrai o nome de diversas formas que o back-end possa retornar
            String? nomeApi = data['name'] ?? data['nome'];
            if (nomeApi == null && data['user'] != null) nomeApi = data['user']['name'] ?? data['user']['nome'];
            
            if (nomeApi != null && nomeApi.isNotEmpty) {
              _nome = nomeApi;
              prefs.setString('user_name', nomeApi); // Salva o nome no cache para uso na próxima vez
            }
          });
        }
      }
    } catch (e) {
      debugPrint('Erro ao buscar perfil no Hero: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Cálculos reais vindos da API
    final int nivelProximo = _nivelAtual + 1;
    final int xpNaBarra = _xpAtual % 100;
    final int xpTotalDoNivel = 100;
    
    // Calcula a porcentagem da barra
    final double progressoXp = xpNaBarra / xpTotalDoNivel;

    // Variáveis de adaptação para o Tema
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color corTexto = isDark ? Colors.white : Colors.black87;
    final Color corFundoAvatar = isDark ? const Color(0xFF1E1E2A) : Colors.white;
    final Color corBordaAvatar = isDark ? const Color(0xFF2E2E40) : Colors.grey.shade300;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 1. Avatar com Badge de Nível (usando Stack para sobreposição)
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: corFundoAvatar,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: corBordaAvatar, width: 2),
              ),
              // Como ainda não temos o arquivo da imagem, deixei um ícone de placeholder.
              // No futuro, troque o Icon por: Image.asset('assets/seu_pixel_art.png')
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/images/hero_avatar.gif',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback para o ícone caso o GIF não carregue
                    return Icon(
                      _getIconeEquipado(),
                      size: 36,
                      color: Colors.grey,
                    );
                  },
                ),
              ),
            ),
            // Insígnia amarela de nível no canto inferior direito
            Positioned(
              bottom: -6,
              right: -6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB800), // Amarelo
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$_nivelAtual',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 16),

        // 2. Informações de XP e Barra de Progresso
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nome e Pontuação
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _nome,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: corTexto,
                      fontFamily: 'monospace', // Fonte retrô
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.bolt, color: Color(0xFFFFB800), size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '$xpNaBarra',
                        style: const TextStyle(
                          color: Color(0xFFFFB800),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        ' / $xpTotalDoNivel XP',
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Barra de Progresso com Gradiente
              Container(
                height: 10,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E2A) : Colors.grey.shade300, // Fundo da barra vazia
                  borderRadius: BorderRadius.circular(6),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progressoXp,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFA855F7), // Roxo
                          Color(0xFF4ADE80), // Verde
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),

              // Indicadores de Nível (Abaixo da barra)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Nível $_nivelAtual',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  Text(
                    'Nível $nivelProximo →',
                    style: const TextStyle(color: Color(0xFFA855F7), fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),

        // 3. Botões de Ação Laterais
        Row(
          children: [
            _buildBotaoAcao(
              icone: Icons.center_focus_strong,
              corFundo: const Color(0xFFA855F7),
              corIcone: Colors.white,
              onTap: () {
                // Pega apenas as missões que ainda não foram concluídas
                final missoesPendentes = missoesNotifier.value.where((m) => !m.concluida).toList();

                if (missoesPendentes.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Você não tem nenhuma missão pendente! 🏆'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                // Seleciona a primeira missão pendente e ativa o auto-start
                missaoSelecionadaNotifier.value = missoesPendentes.first;
                autoStartTimerNotifier.value = true;
                abaAtualNotifier.value = 1; // Navega automaticamente para a Tela de Foco!
              },
            ),
            const SizedBox(width: 8),
            _buildBotaoAcao(
              icone: Icons.inventory_2_outlined,
              corFundo: isDark ? const Color(0xFF2A2A1A) : Colors.amber.shade100, // Fundo escurecido
              corIcone: const Color(0xFFFFB800), // Ícone amarelo
              corBorda: isDark ? const Color.fromRGBO(255, 184, 0, 0.4) : Colors.amber,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TelaInventario()),
                );
              },
            ),
            const SizedBox(width: 8),
            _buildBotaoAcao(
              icone: Icons.help_outline,
              corFundo: isDark ? const Color(0xFF1E1E2A) : Colors.white,
              corIcone: isDark ? Colors.blueAccent : Colors.blue,
              corBorda: isDark ? const Color(0xFF2E2E40) : Colors.grey.shade300,
              onTap: () {
                showAppTutorial(context); // Chama o tutorial novamente!
              },
            ),
            const SizedBox(width: 8),
            ValueListenableBuilder<ThemeMode>(
              valueListenable: temaNotifier,
              builder: (context, modoAtual, child) {
                final bool isDarkTema = modoAtual == ThemeMode.dark;
                return _buildBotaoAcao(
                  icone: isDarkTema ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                  corFundo: isDarkTema ? const Color(0xFF1E1E2A) : Colors.white,
                  corIcone: isDarkTema ? Colors.grey : Colors.black87,
                  corBorda: isDarkTema ? const Color(0xFF2E2E40) : Colors.grey.shade300,
                  onTap: () {
                    temaNotifier.value = isDarkTema ? ThemeMode.light : ThemeMode.dark;
                  },
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  // Função auxiliar para criar os quadradinhos dos botões da direita
  Widget _buildBotaoAcao({
    required IconData icone,
    required Color corFundo,
    required Color corIcone,
    Color? corBorda,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: corFundo,
          borderRadius: BorderRadius.circular(10),
          border: corBorda != null ? Border.all(color: corBorda, width: 1.5) : null,
        ),
        child: Icon(
          icone,
          color: corIcone,
          size: 18,
        ),
      ),
    );
  }
}