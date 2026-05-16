import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TelaInventario extends StatefulWidget {
  const TelaInventario({super.key});

  @override
  State<TelaInventario> createState() => _TelaInventarioState();
}

class _TelaInventarioState extends State<TelaInventario> {
  // O mesmo inventário padrão usado no Perfil
  final List<Map<String, dynamic>> _inventario = [
    {'id': 1, 'nome': 'Set de Couro', 'icone': Icons.security, 'desbloqueado': true},
    {'id': 2, 'nome': 'Set de Ferro', 'icone': Icons.shield, 'desbloqueado': false},
    {'id': 3, 'nome': 'Set de Ouro', 'icone': Icons.workspace_premium, 'desbloqueado': false},
    {'id': 4, 'nome': 'Set de Diamante', 'icone': Icons.diamond, 'desbloqueado': false},
    {'id': 5, 'nome': 'Set de Netherite', 'icone': Icons.military_tech, 'desbloqueado': false},
  ];

  int _itemEquipadoId = 1;
  int _tituloEquipadoId = 1;
  int _nivelUsuario = 1;
  bool _isLoading = true;

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

  // Função disparada ao clicar no botão "Equipar" para Títulos
  Future<void> _equiparTitulo(int idTitulo) async {
    setState(() {
      _tituloEquipadoId = idTitulo;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Título equipado com sucesso!'),
        backgroundColor: Color(0xFF4ADE80), // Verde
        duration: Duration(seconds: 2),
      ),
    );

    try {
      String baseUrl = 'https://api-geral-production.up.railway.app';
      if (!kIsWeb && Platform.isAndroid) baseUrl = 'http://10.0.2.2:3000';
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token') ?? '';
      
      await http.put(
        Uri.parse('$baseUrl/inventario/titulo'), 
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode({'tituloEquipadoId': idTitulo}),
      );
    } catch (e) {
      debugPrint('Erro ao salvar título no banco: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchInventario();
  }

  Future<void> _fetchInventario() async {
    String baseUrl = 'https://api-geral-production.up.railway.app';
    if (!kIsWeb && Platform.isAndroid) {
      baseUrl = 'http://10.0.2.2:3000';
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token') ?? '';

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
            _itemEquipadoId = data['itemEquipadoId'] ?? 1;
            _tituloEquipadoId = data['tituloEquipadoId'] ?? 1;
            _nivelUsuario = data['nivel'] ?? 1;

            if (data['itensDesbloqueados'] != null) {
              List<dynamic> desbloqueados = data['itensDesbloqueados'];
              for (var item in _inventario) {
                item['desbloqueado'] = desbloqueados.contains(item['id']);
              }
            }
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

  // Função disparada ao clicar no botão "Equipar"
  Future<void> _equiparItem(int idItem) async {
    // Atualiza a tela imediatamente para dar feedback rápido (Optimistic UI)
    setState(() {
      _itemEquipadoId = idItem;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Item equipado com sucesso!'),
        backgroundColor: Color(0xFF4ADE80), // Verde
        duration: Duration(seconds: 2),
      ),
    );

    // Faz a requisição no background para atualizar no banco de dados
    try {
      String baseUrl = 'http://localhost:3000';
      if (!kIsWeb && Platform.isAndroid) baseUrl = 'http://10.0.2.2:3000';
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token') ?? '';
      
      await http.put(
        Uri.parse('$baseUrl/inventario/equipar'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode({'itemEquipadoId': idItem}),
      );
    } catch (e) {
      debugPrint('Erro ao salvar item no banco: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final corCard = isDark ? const Color(0xFF1E1E2A) : Colors.white;
    final corTextoPrincipal = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A24) : const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text('Inventário', style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold)),
        backgroundColor: isDark ? const Color(0xFF1A1A24) : const Color(0xFFF3F4F6),
        foregroundColor: corTextoPrincipal,
        elevation: 0,
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF6B4EFF)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Equipamentos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 12),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _inventario.length,
                    itemBuilder: (context, index) {
                      final item = _inventario[index];
                      bool isEquipado = item['id'] == _itemEquipadoId;
                      bool isDesbloqueado = item['desbloqueado'];

                      return Card(
                        color: corCard,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(color: isEquipado ? const Color(0xFF6B4EFF) : Colors.transparent, width: 2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListTile(
                            leading: Icon(
                              isDesbloqueado ? item['icone'] : Icons.lock,
                              color: isDesbloqueado ? (isEquipado ? const Color(0xFF6B4EFF) : Colors.amber) : Colors.grey.withOpacity(0.5),
                              size: 32,
                            ),
                            title: Text(
                              item['nome'],
                              style: TextStyle(
                                color: isDesbloqueado ? corTextoPrincipal : Colors.grey,
                                fontWeight: isEquipado ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            subtitle: Text(
                              isEquipado ? 'Item Equipado' : (isDesbloqueado ? 'Toque para equipar' : 'Nível insuficiente'),
                              style: TextStyle(
                                color: isEquipado ? const Color(0xFF4ADE80) : Colors.grey,
                              ),
                            ),
                            trailing: isDesbloqueado && !isEquipado
                                ? ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF6B4EFF).withOpacity(0.2),
                                      foregroundColor: const Color(0xFF6B4EFF),
                                      elevation: 0,
                                    ),
                                    onPressed: () => _equiparItem(item['id']),
                                    child: const Text('Equipar', style: TextStyle(fontWeight: FontWeight.bold)),
                                  )
                                : null,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  
                  const Text('Títulos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 12),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _titulos.length,
                    itemBuilder: (context, index) {
                      final tituloItem = _titulos[index];
                      bool isDesbloqueado = _nivelUsuario >= tituloItem['nivelMinimo'];
                      bool isEquipado = tituloItem['id'] == _tituloEquipadoId;

                      return Card(
                        color: corCard,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(color: isEquipado ? const Color(0xFF6B4EFF) : Colors.transparent, width: 2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListTile(
                            leading: Icon(
                              isDesbloqueado ? Icons.military_tech : Icons.lock,
                              color: isDesbloqueado ? (isEquipado ? const Color(0xFF6B4EFF) : Colors.amber) : Colors.grey.withOpacity(0.5),
                              size: 32,
                            ),
                            title: Text(
                              tituloItem['nome'],
                              style: TextStyle(
                                color: isDesbloqueado ? corTextoPrincipal : Colors.grey,
                                fontWeight: isEquipado ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            subtitle: Text(
                              isEquipado ? 'Título Equipado' : (isDesbloqueado ? 'Toque para equipar' : 'Requer Nível ${tituloItem['nivelMinimo']}'),
                              style: TextStyle(
                                color: isEquipado ? const Color(0xFF4ADE80) : Colors.grey,
                              ),
                            ),
                            trailing: isDesbloqueado && !isEquipado
                                ? ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF6B4EFF).withOpacity(0.2),
                                      foregroundColor: const Color(0xFF6B4EFF),
                                      elevation: 0,
                                    ),
                                    onPressed: () => _equiparTitulo(tituloItem['id']),
                                    child: const Text('Equipar', style: TextStyle(fontWeight: FontWeight.bold)),
                                  )
                                : null,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}