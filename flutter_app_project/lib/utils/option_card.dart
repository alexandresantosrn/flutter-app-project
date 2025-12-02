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
    Color bg;
    Color fg = Colors.black87;
    if (showFeedback) {
      if (isCorrect) {
        bg = Colors.green.shade600;
        fg = Colors.white;
      } else if (isSelected) {
        bg = Colors.red.shade600;
        fg = Colors.white;
      } else {
        bg = Colors.grey.shade200;
      }
    } else {
      bg = Colors.grey.shade100;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Text(
            text,
            style: TextStyle(fontSize: 16, color: fg),
            softWrap: true,
            overflow: TextOverflow.visible,
          ),
        ),
      ),
    );
  }
}
