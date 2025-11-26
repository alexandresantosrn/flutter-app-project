import 'package:flutter/material.dart';
import '../utils/config_logger.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    logger.i('Abrindo tela: Configurações');
    return const Center(
      child: Text(
        'Configurações',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }
}
