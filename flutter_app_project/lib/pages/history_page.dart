import 'package:flutter/material.dart';
import '../utils/config_logger.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    logger.i('Abrindo tela: Histórico');
    return const Center(
      child: Text(
        'Histórico',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }
}
