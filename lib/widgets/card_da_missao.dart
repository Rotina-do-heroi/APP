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
  final ScrollController _scrollController = ScrollController();
  
  String? _prioridadeSelecionada;
  String? _atributoSelecionado;
  int _sessoesNecessarias = 1;
  List<int> _diasRepeticao = [];

  @override
  void dispose() {
    _controladorTitulo.dispose();
    _controladorDescricao.dispose();
    _controladorMicroPasso.dispose();
    _scrollController.dispose();
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(
                'Nova missão',
                style: TextStyle(color: corTextoDialog, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('📊 Titulo da missão', corTextoSecundario),
                    _buildTextField(_controladorTitulo, 'Ex: Estudar Flutter', corTextoDialog, corFundoInput, corBordaInput),
                    const SizedBox(height: 16),
                    
                    _buildLabel('Descrição (Opcional)', corTextoSecundario),
                    _buildTextField(_controladorDescricao, 'Detalhes da jornada...', corTextoDialog, corFundoInput, corBordaInput),
                    const SizedBox(height: 16),

                    _buildLabel('Prioridade', corTextoSecundario),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildPrioridadeBtn('Alta', Colors.red, setState, corFundoInput, corBordaInput, corTextoDialog),
                        _buildPrioridadeBtn('Média', Colors.amber, setState, corFundoInput, corBordaInput, corTextoDialog),
                        _buildPrioridadeBtn('Baixa', Colors.green, setState, corFundoInput, corBordaInput, corTextoDialog),
                      ],
                    ),
                    const SizedBox(height: 16),

                    _buildLabel('Atributo Relacionado', corTextoSecundario),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8, runSpacing: 8,
                      children: [
                        _buildBotaoAtributo('Intelecto', Icons.psychology, Colors.blueAccent, setState, isDark),
                        _buildBotaoAtributo('Força', Icons.fitness_center, const Color(0xFF4ADE80), setState, isDark),
                      ],
                    ),
                    const SizedBox(height: 16),

                    _buildLabel('Sessões de Foco', corTextoSecundario),
                    Row(
                      children: [
                        IconButton(onPressed: _sessoesNecessarias > 1 ? () => setState(() => _sessoesNecessarias--) : null, icon: Icon(Icons.remove_circle_outline, color: corTextoDialog)),
                        Text('$_sessoesNecessarias', style: TextStyle(color: corTextoDialog, fontSize: 18, fontWeight: FontWeight.bold)),
                        IconButton(onPressed: () => setState(() => _sessoesNecessarias++), icon: Icon(Icons.add_circle_outline, color: corTextoDialog)),
                      ],
                    ),
                    const SizedBox(height: 16),

                    SeletorDiasSemana(
                      diasSelecionadosInicial: _diasRepeticao,
                      onSelectionChanged: (dias) => setState(() => _diasRepeticao = dias),
                    ),
                    const SizedBox(height: 24),

                    _buildLabel('Micro-passos (Máx 3)', corTextoSecundario),
                    const SizedBox(height: 8),
                    _buildTextField(_controladorMicroPasso, 'Primeiro passo...', corTextoDialog, corFundoInput, corBordaInput),
                    
                    const SizedBox(height: 8),
                    ..._controladoresMicroPassos.asMap().entries.map((entry) {
                      final index = entry.key;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            Expanded(child: _buildTextField(entry.value, 'Passo adicional ${index + 2}', corTextoDialog, corFundoInput, corBordaInput)),
                            IconButton(
                              onPressed: () => setState(() {
                                entry.value.dispose();
                                _controladoresMicroPassos.removeAt(index);
                              }),
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                            ),
                          ],
                        ),
                      );
                    }),

                    if (_controladoresMicroPassos.length < 2)
                      OutlinedButton.icon(
                        onPressed: () {
                          setState(() => _controladoresMicroPassos.add(TextEditingController()));
                          // Rolagem automática leve para o novo campo
                          Future.delayed(const Duration(milliseconds: 150), () {
                            _scrollController.animateTo(
                              _scrollController.position.maxScrollExtent,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                            );
                          });
                        },
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Adicionar micro-passo'),
                        style: OutlinedButton.styleFrom(foregroundColor: Colors.purple, side: const BorderSide(color: Colors.purple)),
                      )
                    else
                      const Text('⚠️ Limite de 3 micro-passos atingido', style: TextStyle(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
                ElevatedButton(
                  onPressed: () => _finalizarCriacao(context),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                  child: const Text('Criar Missão'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _finalizarCriacao(BuildContext context) {
    if (_controladorTitulo.text.isEmpty) return;
    
    final microPassos = <MicroPasso>[];
    if (_controladorMicroPasso.text.isNotEmpty) microPassos.add(MicroPasso(descricao: _controladorMicroPasso.text.trim()));
    for (var c in _controladoresMicroPassos) {
      if (c.text.isNotEmpty) microPassos.add(MicroPasso(descricao: c.text.trim()));
    }

    final missao = Missao(
      titulo: _controladorTitulo.text.trim(),
      descricao: _controladorDescricao.text.trim(),
      tags: _atributoSelecionado != null ? [_atributoSelecionado!] : [],
      prioridade: _prioridadeSelecionada ?? 'baixa',
      microPassos: microPassos,
      sessoesNecessarias: _sessoesNecessarias,
      diasRepeticao: _diasRepeticao,
    );

    widget.onCriarMissao(missao);
    Navigator.pop(context);
  }

  // --- HELPERS DE INTERFACE ---

  Widget _buildLabel(String texto, Color cor) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(texto, style: TextStyle(color: cor, fontSize: 13, fontWeight: FontWeight.w600)),
  );

  Widget _buildTextField(TextEditingController controller, String hint, Color textoCor, Color fundo, Color borda) => TextField(
    controller: controller,
    style: TextStyle(color: textoCor, fontSize: 14),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
      filled: true, fillColor: fundo,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: borda)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: borda)),
    ),
  );

  Widget _buildPrioridadeBtn(String label, Color cor, StateSetter setState, Color fundo, Color borda, Color texto) {
    final slug = label.toLowerCase().replaceAll('é', 'e');
    final isSelected = _prioridadeSelecionada == slug;
    return GestureDetector(
      onTap: () => setState(() => _prioridadeSelecionada = slug),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? cor : fundo,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? cor : borda),
        ),
        child: Text(label, style: TextStyle(color: isSelected ? Colors.white : texto, fontSize: 12, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildBotaoAtributo(String nome, IconData icone, Color cor, StateSetter setState, bool isDark) {
    final isSelecionado = _atributoSelecionado == nome;
    return GestureDetector(
      onTap: () => setState(() => _atributoSelecionado = isSelecionado ? null : nome),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelecionado ? cor.withOpacity(0.2) : (isDark ? const Color(0xFF13131A) : Colors.grey.shade100),
          border: Border.all(color: isSelecionado ? cor : (isDark ? const Color(0xFF2E2E40) : Colors.grey.shade300), width: 1.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, size: 16, color: isSelecionado ? cor : Colors.grey),
            const SizedBox(width: 6),
            Text(nome, style: TextStyle(color: isSelecionado ? (isDark ? Colors.white : Colors.black87) : Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: _abrirDialogoNovaMissao,
      icon: const Icon(Icons.add, size: 20),
      label: const Text('Nova missão', style: TextStyle(fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
    );
  }
}
