import 'package:flutter/material.dart';
import '../utils/config_logger.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    logger.i('Abrindo tela: Estatísticas');
    return const Center(
      child: Text(
        'Estatísticas',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }
}
