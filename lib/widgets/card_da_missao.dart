import 'package:flutter/material.dart';
import '../models/missao.dart';

class CardDaMissao extends StatefulWidget {
  final ValueChanged<Missao> onCriarMissao;

  const CardDaMissao({
    super.key,
    required this.onCriarMissao,
  });

  @override
  State<CardDaMissao> createState() => _CardDaMissaoState();
}

class _CardDaMissaoState extends State<CardDaMissao> {
  final TextEditingController _controladorTitulo = TextEditingController();
  final TextEditingController _controladorDescricao = TextEditingController();
  final TextEditingController _controladorMicroPasso = TextEditingController();
  final List<TextEditingController> _controladoresMicroPassos = [];
  String? _prioridadeSelecionada;
  String? _atributoSelecionado;

  @override
  void dispose() {
    _controladorTitulo.dispose();
    _controladorDescricao.dispose();
    _controladorMicroPasso.dispose();
    for (final controller in _controladoresMicroPassos) {
      controller.dispose();
    }
    super.dispose();
  }

  void _limparCamposDialogo() {
    _controladorTitulo.clear();
    _controladorDescricao.clear();
    _controladorMicroPasso.clear();
    for (final controller in _controladoresMicroPassos) {
      controller.dispose();
    }
    _controladoresMicroPassos.clear();
    _prioridadeSelecionada = null;
    _atributoSelecionado = null;
  }

  void _abrirDialogoNovaMissao() {
    _limparCamposDialogo();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E1E2A),
              title: const Text(
                'Nova missão',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '📊 Titulo da missão',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _controladorTitulo,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Digite o título da missão',
                        hintStyle: const TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: const Color(0xFF13131A),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF2E2E40)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF2E2E40)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.blue, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Descrição (Opcional)',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _controladorDescricao,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Digite a descrição da missão',
                        hintStyle: const TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: const Color(0xFF13131A),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF2E2E40)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF2E2E40)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.blue, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Prioridade',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _prioridadeSelecionada = 'alta';
                            });
                          },
                          child: Container(
                            width: 80,
                            height: 30,
                            decoration: BoxDecoration(
                              color: _prioridadeSelecionada == 'alta'
                                  ? Colors.red
                                  : const Color(0xFF13131A),
                              border: Border.all(
                                color: _prioridadeSelecionada == 'alta'
                                    ? Colors.red
                                    : const Color(0xFF2E2E40),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Text(
                                'Alta',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _prioridadeSelecionada = 'media';
                            });
                          },
                          child: Container(
                            width: 80,
                            height: 30,
                            decoration: BoxDecoration(
                              color: _prioridadeSelecionada == 'media'
                                  ? Colors.amber
                                  : const Color(0xFF13131A),
                              border: Border.all(
                                color: _prioridadeSelecionada == 'media'
                                    ? Colors.amber
                                    : const Color(0xFF2E2E40),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Text(
                                'Média',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _prioridadeSelecionada = 'baixa';
                            });
                          },
                          child: Container(
                            width: 80,
                            height: 30,
                            decoration: BoxDecoration(
                              color: _prioridadeSelecionada == 'baixa'
                                  ? Colors.green
                                  : const Color(0xFF13131A),
                              border: Border.all(
                                color: _prioridadeSelecionada == 'baixa'
                                    ? Colors.green
                                    : const Color(0xFF2E2E40),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Text(
                                'Baixa',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Atributo Relacionado (Recompensa)',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildBotaoAtributo('Foco', Icons.my_location, const Color(0xFF6B4EFF), setState),
                        _buildBotaoAtributo('Disciplina', Icons.assignment_turned_in, Colors.orangeAccent, setState),
                        _buildBotaoAtributo('Intelecto', Icons.psychology, Colors.blueAccent, setState),
                        _buildBotaoAtributo('Força', Icons.fitness_center, const Color(0xFF4ADE80), setState),
                        _buildBotaoAtributo('Consistência', Icons.loop, Colors.redAccent, setState),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Micro-passos',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _controladorMicroPasso,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Digite um micro-passo',
                        hintStyle: const TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: const Color(0xFF13131A),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF2E2E40)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF2E2E40)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.blue, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () {
                        if (_controladoresMicroPassos.length < 2) {
                          setState(() {
                            _controladoresMicroPassos.add(TextEditingController());
                          });
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.purple, width: 1.8),
                        foregroundColor: Colors.purple,
                      ),
                      child: const Text('+Adicionar micro-passo'),
                    ),
                    const SizedBox(height: 8),
                    ..._controladoresMicroPassos.asMap().entries.map(
                      (entry) {
                        final index = entry.key;
                        final controller = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: controller,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    hintText: 'Micro-passo adicional ${index + 1}',
                                    hintStyle: const TextStyle(color: Colors.grey),
                                    filled: true,
                                    fillColor: const Color(0xFF13131A),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(color: Color(0xFF2E2E40)),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(color: Color(0xFF2E2E40)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(color: Colors.blue, width: 2),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    controller.dispose();
                                    _controladoresMicroPassos.removeAt(index);
                                  });
                                },
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _limparCamposDialogo();
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    String titulo = _controladorTitulo.text;
                    if (titulo.isNotEmpty) {
                      final microPassos = <MicroPasso>[];
                      if (_controladorMicroPasso.text.trim().isNotEmpty) {
                        microPassos.add(MicroPasso(descricao: _controladorMicroPasso.text.trim()));
                      }
                      for (final controller in _controladoresMicroPassos) {
                        final texto = controller.text.trim();
                        if (texto.isNotEmpty) {
                          microPassos.add(MicroPasso(descricao: texto));
                        }
                      }
                      final missao = Missao(
                        titulo: titulo.trim(),
                        descricao: _controladorDescricao.text.trim(),
                        tags: _atributoSelecionado != null ? [_atributoSelecionado!] : [],
                        prioridade: _prioridadeSelecionada ?? 'baixa',
                        microPassos: microPassos,
                      );
                      widget.onCriarMissao(missao);
                      _limparCamposDialogo();
                      Navigator.of(context).pop();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Criar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: _abrirDialogoNovaMissao,
      icon: const Icon(Icons.add),
      label: const Text('Nova missão'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildBotaoAtributo(String nome, IconData icone, Color cor, StateSetter setStateDialogo) {
    final isSelecionado = _atributoSelecionado == nome;
    
    return GestureDetector(
      onTap: () {
        setStateDialogo(() {
          // Se já estiver selecionado, desmarca. Senão, seleciona.
          _atributoSelecionado = isSelecionado ? null : nome;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelecionado ? cor.withOpacity(0.2) : const Color(0xFF13131A),
          border: Border.all(
            color: isSelecionado ? cor : const Color(0xFF2E2E40),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, size: 16, color: isSelecionado ? cor : Colors.grey),
            const SizedBox(width: 6),
            Text(
              nome,
              style: TextStyle(
                color: isSelecionado ? Colors.white : Colors.grey,
                fontSize: 12,
                fontWeight: isSelecionado ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
