import 'package:flutter/material.dart';
import '../utils/app_logger.dart';

class PracticePage extends StatelessWidget {
  const PracticePage({super.key});

  @override
  Widget build(BuildContext context) {
    logger.i('Abrindo tela: Praticar');
    return const Center(
      child: Text(
        'Praticar',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }
}
