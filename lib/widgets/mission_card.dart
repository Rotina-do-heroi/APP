import 'package:flutter/material.dart';
import '../models/missao.dart';

class MissionCard extends StatefulWidget {
  final Missao missao;
  final ValueChanged<Missao> onMissaoAtualizada;
  final VoidCallback onDeletarMissao;
  final VoidCallback onFocoRapido;

  const MissionCard({
    super.key,
    required this.missao,
    required this.onMissaoAtualizada,
    required this.onDeletarMissao,
    required this.onFocoRapido,
  });

  @override
  State<MissionCard> createState() => _MissionCardState();
}

class _MissionCardState extends State<MissionCard> {
  bool _estaExpandido = false;

  Color _corPrioridade(String prioridade) {
    switch (prioridade.toLowerCase()) {
      case 'alta':
        return Colors.red;
      case 'media':
        return Colors.amber;
      case 'baixa':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _tituloPrioridade(String prioridade) {
    switch (prioridade.toLowerCase()) {
      case 'alta':
        return 'Alta';
      case 'media':
        return 'Média';
      case 'baixa':
        return 'Baixa';
      default:
        return 'Sem prioridade';
    }
  }

  void _atualizarMissao() {
    widget.onMissaoAtualizada(widget.missao);
  }

  void _confirmarDelecao(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E1E2A) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent),
              SizedBox(width: 8),
              Text('Deletar Missão', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
            ],
          ),
          content: Text(
            'Tem certeza que deseja abandonar esta missão? Ela será excluída permanentemente.',
            style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onDeletarMissao();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              child: const Text('Deletar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final corFundo = isDark ? const Color(0xFF252536) : Colors.white;
    final corBorda = isDark ? const Color(0xFF3A3A54) : Colors.grey.shade300;
    final corTextoPrincipal = isDark ? Colors.white : Colors.black87;
    final corTextoSecundario = isDark ? Colors.white70 : Colors.black54;

    final corPrioridade = _corPrioridade(widget.missao.prioridade);

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: corFundo,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: widget.missao.concluida ? Colors.greenAccent : corBorda,
          width: 1.4,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _estaExpandido = !_estaExpandido;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.missao.titulo,
                          style: TextStyle(
                            color: corTextoPrincipal,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            decoration: widget.missao.concluida ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Color.fromRGBO(
                                  corPrioridade.r.toInt(),
                                  corPrioridade.g.toInt(),
                                  corPrioridade.b.toInt(),
                                  0.18,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _tituloPrioridade(widget.missao.prioridade),
                                style: TextStyle(
                                  color: corPrioridade,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Badge de Sessões de Foco
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6B4EFF).withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.timer, size: 12, color: Color(0xFF6B4EFF)),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${widget.missao.sessoesConcluidas}/${widget.missao.sessoesNecessarias}',
                                    style: const TextStyle(
                                      color: Color(0xFF6B4EFF),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: widget.onFocoRapido,
                    child: const Icon(
                      Icons.center_focus_strong,
                      color: Color(0xFFA855F7),
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => _confirmarDelecao(context),
                    child: const Icon(
                      Icons.delete_outline,
                      color: Colors.redAccent,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () {
                      // Verifica se o usuário está tentando concluir sem ter as sessões necessárias
                      if (!widget.missao.concluida && widget.missao.sessoesConcluidas < widget.missao.sessoesNecessarias) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Use o Modo Foco! Faltam ${widget.missao.sessoesNecessarias - widget.missao.sessoesConcluidas} sessão(ões).'),
                            backgroundColor: Colors.orangeAccent,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                        return; // Impede que o código continue e marque como concluída
                      }

                      setState(() {
                        widget.missao.concluida = !widget.missao.concluida;
                        _atualizarMissao();
                      });
                    },
                    child: Icon(
                      widget.missao.concluida ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: widget.missao.concluida ? Colors.greenAccent : Colors.grey,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_estaExpandido) ...[
            Divider(color: corBorda, height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.missao.descricao.isNotEmpty) ...[
                    Text(
                      'Descrição',
                      style: TextStyle(
                        color: corTextoSecundario,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.missao.descricao,
                      style: TextStyle(color: corTextoPrincipal, fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Text(
                    'Micro-passos',
                    style: TextStyle(
                      color: corTextoSecundario,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (widget.missao.microPassos.isEmpty)
                    Text(
                      'Nenhum micro-passo adicionado.',
                      style: TextStyle(color: isDark ? Colors.white54 : Colors.black38),
                    )
                  else
                    Column(
                      children: widget.missao.microPassos.map(
                        (micro) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      micro.concluido = !micro.concluido;
                                      _atualizarMissao();
                                    });
                                  },
                                  child: Icon(
                                    micro.concluido ? Icons.check_circle : Icons.radio_button_unchecked,
                                    color: micro.concluido ? Colors.greenAccent : (isDark ? Colors.grey : Colors.black45),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    micro.descricao,
                                    style: TextStyle(
                                      color: micro.concluido ? (isDark ? Colors.white54 : Colors.black38) : corTextoPrincipal,
                                      decoration: micro.concluido ? TextDecoration.lineThrough : null,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ).toList(),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
