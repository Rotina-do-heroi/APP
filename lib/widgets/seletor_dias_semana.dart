import 'package:flutter/material.dart';

class SeletorDiasSemana extends StatefulWidget {
  final Function(List<int>) onSelectionChanged;
  final List<int> diasSelecionadosInicial;

  const SeletorDiasSemana({
    super.key,
    required this.onSelectionChanged,
    this.diasSelecionadosInicial = const [],
  });

  @override
  State<SeletorDiasSemana> createState() => _SeletorDiasSemanaState();
}

class _SeletorDiasSemanaState extends State<SeletorDiasSemana> {
  late List<int> _diasSelecionados;
  final List<String> _diasDaSemana = ['SEG', 'TER', 'QUA', 'QUI', 'SEX', 'SAB', 'DOM'];

  @override
  void initState() {
    super.initState();
    _diasSelecionados = List.from(widget.diasSelecionadosInicial);
  }

  void _toggleDia(int dia) {
    setState(() {
      if (_diasSelecionados.contains(dia)) {
        _diasSelecionados.remove(dia);
      } else {
        _diasSelecionados.add(dia);
        _diasSelecionados.sort();
      }
      widget.onSelectionChanged(_diasSelecionados);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final corPrimaria = Theme.of(context).primaryColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Repetir Missão (Opcional)',
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black54,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 12),
        // Linha 1: Seg, Ter, Qua, Qui
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(4, (index) => _buildDiaItem(index + 1, isDark, corPrimaria)),
        ),
        const SizedBox(height: 8),
        // Linha 2: Sex, Sab, Dom
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ...List.generate(3, (index) => Padding(
              padding: const EdgeInsets.only(right: 12),
              child: _buildDiaItem(index + 5, isDark, corPrimaria),
            )),
          ],
        ),
      ],
    );
  }

  Widget _buildDiaItem(int dia, bool isDark, Color corPrimaria) {
    final isSelected = _diasSelecionados.contains(dia);
    return GestureDetector(
      onTap: () => _toggleDia(dia),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isSelected ? corPrimaria : (isDark ? const Color(0xFF252536) : Colors.grey.shade200),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            _diasDaSemana[dia - 1],
            style: TextStyle(
              fontSize: 11,
              color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black54),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
