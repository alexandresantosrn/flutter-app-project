import 'package:flutter/material.dart';
import 'option_card.dart';

/// Widget que exibe a questão (palavra em português) e opções na língua alvo.
/// Ajustes: usa LayoutBuilder para detectar altura disponível e usar ListView
/// quando o pai providencia um limite (evita overflow). Texto das opções pode quebrar.
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
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: LayoutBuilder(builder: (context, constraints) {
          final hasBoundedHeight = constraints.maxHeight.isFinite;
          final question = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Traduza: $portuguese',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
            ],
          );

          final optionsList = hasBoundedHeight
              // quando altura é limitada, usamos ListView para scroll interno e comportamento robusto
              ? ListView.separated(
                  physics: const ClampingScrollPhysics(),
                  itemCount: options.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final isSelected = selectedIndex == index;
                    final isCorrect =
                        correctIndex != null && correctIndex == index;
                    return OptionCard(
                      text: options[index],
                      onTap: (enabled && selectedIndex == null)
                          ? () => onOptionSelected(index)
                          : null,
                      showFeedback: _showFeedback,
                      isCorrect: isCorrect,
                      isSelected: isSelected,
                    );
                  },
                )
              // quando altura não limitada, usamos Column + SingleChildScrollView interno (evita ListView sem limite)
              : SingleChildScrollView(
                  child: Column(
                    children: List.generate(options.length, (index) {
                      final isSelected = selectedIndex == index;
                      final isCorrect =
                          correctIndex != null && correctIndex == index;
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
                );

          return Column(
            children: [
              question,
              // se houver limite de altura, o ListView ocupa o restante; caso contrário, optionsList já cuida do tamanho.
              hasBoundedHeight ? Expanded(child: optionsList) : optionsList,
            ],
          );
        }),
      ),
    );
  }
}
