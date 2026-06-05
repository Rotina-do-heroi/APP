import 'package:flutter/material.dart';
import '../models/missao.dart';
import 'seletor_dias_semana.dart';


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
  int _sessoesNecessarias = 1;
  List<int> _diasRepeticao = [];

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
    _sessoesNecessarias = 1;
    _diasRepeticao = [];
  }

  void _abrirDialogoNovaMissao() {
    _limparCamposDialogo();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final corFundoDialog = isDark ? const Color(0xFF1E1E2A) : Colors.white;
        final corTextoDialog = isDark ? Colors.white : Colors.black87;
        final corTextoSecundario = isDark ? Colors.white70 : Colors.black54;
        final corFundoInput = isDark ? const Color(0xFF13131A) : Colors.grey.shade100;
        final corBordaInput = isDark ? const Color(0xFF2E2E40) : Colors.grey.shade300;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              backgroundColor: corFundoDialog,
              title: Text(
                'Nova missão',
                style: TextStyle(
                  color: corTextoDialog,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📊 Titulo da missão',
                      style: TextStyle(
                        color: corTextoSecundario,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _controladorTitulo,
                      style: TextStyle(color: corTextoDialog),
                      decoration: InputDecoration(
                        hintText: 'Digite o título da missão',
                        hintStyle: const TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: corFundoInput,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: corBordaInput),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: corBordaInput),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.blue, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Descrição (Opcional)',
                      style: TextStyle(
                        color: corTextoSecundario,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _controladorDescricao,
                      style: TextStyle(color: corTextoDialog),
                      decoration: InputDecoration(
                        hintText: 'Digite a descrição da missão',
                        hintStyle: const TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: corFundoInput,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: corBordaInput),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: corBordaInput),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.blue, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Prioridade',
                      style: TextStyle(
                        color: corTextoSecundario,
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
                                  : corFundoInput,
                              border: Border.all(
                                color: _prioridadeSelecionada == 'alta'
                                    ? Colors.red
                                    : corBordaInput,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                'Alta',
                                style: TextStyle(
                                  color: _prioridadeSelecionada == 'alta' ? Colors.white : corTextoDialog,
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
                                  : corFundoInput,
                              border: Border.all(
                                color: _prioridadeSelecionada == 'media'
                                    ? Colors.amber
                                    : corBordaInput,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                'Média',
                                style: TextStyle(
                                  color: _prioridadeSelecionada == 'media' ? Colors.white : corTextoDialog,
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
                                  : corFundoInput,
                              border: Border.all(
                                color: _prioridadeSelecionada == 'baixa'
                                    ? Colors.green
                                    : corBordaInput,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                'Baixa',
                                style: TextStyle(
                                  color: _prioridadeSelecionada == 'baixa' ? Colors.white : corTextoDialog,
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
                    Text(
                      'Atributo Relacionado (Recompensa)',
                      style: TextStyle(
                        color: corTextoSecundario,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildBotaoAtributo('Intelecto', Icons.psychology, Colors.blueAccent, setState, isDark),
                        _buildBotaoAtributo('Força', Icons.fitness_center, const Color(0xFF4ADE80), setState, isDark),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Sessões de Foco Necessárias',
                      style: TextStyle(
                        color: corTextoSecundario,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        IconButton(
                          onPressed: _sessoesNecessarias > 1
                              ? () => setState(() => _sessoesNecessarias--)
                              : null,
                          icon: Icon(Icons.remove_circle_outline, color: corTextoDialog),
                        ),
                        Text(
                          '$_sessoesNecessarias',
                          style: TextStyle(color: corTextoDialog, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          onPressed: () => setState(() => _sessoesNecessarias++),
                          icon: Icon(Icons.add_circle_outline, color: corTextoDialog),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'sessão(ões) de 25 min',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SeletorDiasSemana(
                      diasSelecionadosInicial: _diasRepeticao,
                      onSelectionChanged: (dias) {
                        setState(() {
                          _diasRepeticao = dias;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Micro-passos',
                      style: TextStyle(
                        color: corTextoSecundario,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _controladorMicroPasso,
                      style: TextStyle(color: corTextoDialog),
                      decoration: InputDecoration(
                        hintText: 'Digite um micro-passo',
                        hintStyle: const TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: corFundoInput,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: corBordaInput),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: corBordaInput),
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
                                  style: TextStyle(color: corTextoDialog),
                                  decoration: InputDecoration(
                                    hintText: 'Micro-passo adicional ${index + 1}',
                                    hintStyle: const TextStyle(color: Colors.grey),
                                    filled: true,
                                    fillColor: corFundoInput,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(color: corBordaInput),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(color: corBordaInput),
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
                        sessoesNecessarias: _sessoesNecessarias,
                        diasRepeticao: _diasRepeticao,
                      );
                      debugPrint('Enviando missão com dias repetidos: ${missao.diasRepeticao}');
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

  Widget _buildBotaoAtributo(String nome, IconData icone, Color cor, StateSetter setStateDialogo, bool isDark) {
    final isSelecionado = _atributoSelecionado == nome;
    final corFundoInput = isDark ? const Color(0xFF13131A) : Colors.grey.shade100;
    final corBordaInput = isDark ? const Color(0xFF2E2E40) : Colors.grey.shade300;
    final corTextoDialog = isDark ? Colors.white : Colors.black87;
    
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
          color: isSelecionado ? cor.withOpacity(0.2) : corFundoInput,
          border: Border.all(
            color: isSelecionado ? cor : corBordaInput,
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
                color: isSelecionado ? corTextoDialog : Colors.grey,
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
