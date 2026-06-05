import 'package:flutter/material.dart';

class AbaModoWidget extends StatelessWidget {
  final int indice;
  final String titulo;
  final IconData icone;
  final bool isSelecionado;
  final Color corAtual;
  final VoidCallback onTap;

  const AbaModoWidget({
    super.key,
    required this.indice,
    required this.titulo,
    required this.icone,
    required this.isSelecionado,
    required this.corAtual,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelecionado ? corAtual : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icone, size: 16, color: isSelecionado ? Colors.white : Colors.grey),
            const SizedBox(width: 6),
            Text(titulo, style: TextStyle(color: isSelecionado ? Colors.white : Colors.grey, fontWeight: isSelecionado ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }
}