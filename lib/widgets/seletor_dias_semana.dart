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
  // Usando padrão DateTime.weekday: 1=Segunda, 7=Domingo
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
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(7, (index) {
            final dia = index + 1; // 1 para Segunda, 7 para Domingo
            final isSelected = _diasSelecionados.contains(dia);
            return GestureDetector(
              onTap: () => _toggleDia(dia),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected ? corPrimaria : (isDark ? const Color(0xFF252536) : Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(_diasDaSemana[index], style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black54), fontWeight: FontWeight.bold)),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}