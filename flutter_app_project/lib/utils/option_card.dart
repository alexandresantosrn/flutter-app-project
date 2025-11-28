import 'package:flutter/material.dart';

/// Card reutilizável para uma opção do quiz.
/// - onTap é chamado somente se não estiver desabilitado (null para desabilitar).
class OptionCard extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final bool showFeedback; // se true mostra cores de acerto/erro
  final bool isCorrect;
  final bool isSelected;

  const OptionCard({
    super.key,
    required this.text,
    this.onTap,
    this.showFeedback = false,
    this.isCorrect = false,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    // determina cores com contraste adequado
    final Color bg;
    final Color fg;
    if (!showFeedback) {
      bg = Colors.white;
      fg = Colors.black87;
    } else if (isCorrect) {
      bg = Colors.green.shade600;
      fg = Colors.white;
    } else if (isSelected && !isCorrect) {
      bg = Colors.red.shade600;
      fg = Colors.white;
    } else {
      bg = Colors.white;
      fg = Colors.black87;
    }

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            text,
            style: TextStyle(fontSize: 16, color: fg),
            textAlign: TextAlign.left,
          ),
        ),
      ),
    );
  }
}
