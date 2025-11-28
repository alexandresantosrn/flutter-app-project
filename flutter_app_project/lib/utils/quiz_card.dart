import 'package:flutter/material.dart';
import 'option_card.dart';

/// Widget que exibe a questão (palavra em português) e 4 opções na língua alvo.
/// - Opções dispostas verticalmente (um card acima do outro).
/// - Exibe feedback de acerto (verde) / erro (vermelho) quando o usuário responde.
/// - `selectedIndex` é o índice escolhido pelo usuário (ou null se ainda não respondeu).
/// - `correctIndex` é o índice da opção correta (mostrado após a resposta).
class QuizCard extends StatelessWidget {
  final String portuguese;
  final List<String> options; // 4 opções na língua alvo
  final int? selectedIndex; // índice selecionado pelo usuário
  final int? correctIndex;
  final bool enabled;
  final ValueChanged<int> onOptionSelected;

  const QuizCard({
    super.key,
    required this.portuguese,
    required this.options,
    required this.onOptionSelected,
    this.selectedIndex,
    this.correctIndex,
    this.enabled = true,
  }) : assert(options.length == 4, 'São esperadas 4 opções');

  bool get _showFeedback => selectedIndex != null;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Traduza: $portuguese',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        // opções empilhadas verticalmente com espaçamento
        Column(
          children: List.generate(options.length, (index) {
            final isSelected = selectedIndex == index;
            final isCorrect = correctIndex != null && correctIndex == index;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: OptionCard(
                text: options[index],
                onTap: (enabled && selectedIndex == null)
                    ? () => onOptionSelected(index)
                    : null,
                showFeedback: _showFeedback,
                isCorrect: isCorrect,
                isSelected: isSelected,
              ),
            );
          }),
        ),
      ],
    );
  }
}
