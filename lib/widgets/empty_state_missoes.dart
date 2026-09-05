import 'package:flutter/material.dart';

class EmptyStateMissoes extends StatelessWidget {
  const EmptyStateMissoes({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.developer_board,
              size: 80,
              color: isDark ? Colors.white.withAlpha(40) : Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Seu quadro de contratos está vazio, Herói!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
