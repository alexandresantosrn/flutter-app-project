import 'package:flutter/material.dart';
import '../utils/config_logger.dart';
import '../utils/theme_notifier.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  String _notificationTime = '08:00';
  bool _darkMode = false;
  int _dailyLessonSize = 10;
  String _language = 'Inglês';

  late final List<String> _halfHourTimes;

  @override
  void initState() {
    super.initState();
    _halfHourTimes = [
      for (int h = 0; h < 24; h++)
        for (int m in [0, 30])
          ('${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}')
    ];
    logger.i('Configurações: inicializando SettingsPage');
  }

  void _onNotificationsChanged(bool value) {
    setState(() => _notificationsEnabled = value);
    logger.i('Notificações: ${value ? "Habilitadas" : "Desabilitadas"}');
  }

  // Ao mudar o modo noturno, atualiza o notifier global para alterar o tema do app.
  void _onDarkModeChanged(bool value) {
    setState(() {
      _darkMode = value;
    });
    themeModeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
    logger.i('Modo noturno: ${value ? "Ativado" : "Desativado"}');
  }

  void _onTimeChanged(String value) {
    setState(() => _notificationTime = value);
    logger.i('Horário selecionado: $_notificationTime');
  }

  Future<void> _openTimeSelector() async {
    if (!_notificationsEnabled) return;

    final result = await showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        String tempSelection = _notificationTime;
        return StatefulBuilder(builder: (context, setModalState) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header com Cancelar (esq), título centralizado (Stack) e Ok (dir)
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 8.0),
                  child: SizedBox(
                    height: 48,
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: () => Navigator.of(ctx).pop('CANCELAR'),
                            child: const Text('Cancelar'),
                          ),
                        ),
                        const Center(
                          child: Text(
                            'Escolher Horário',
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 16),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () =>
                                Navigator.of(ctx).pop(tempSelection),
                            child: const Text('Ok'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 1),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.55,
                  child: ListView.builder(
                    itemCount: _halfHourTimes.length,
                    itemBuilder: (context, index) {
                      final t = _halfHourTimes[index];
                      final selected = t == tempSelection;
                      return ListTile(
                        onTap: () => setModalState(() => tempSelection = t),
                        title: Center(
                          child: Text(
                            t,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: selected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: selected
                                  ? Theme.of(context).colorScheme.primary
                                  : null,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        });
      },
    );

    if (result == null) return;
    if (result == 'CANCELAR') {
      logger.i('Seleção de horário cancelada');
      return;
    }
    if (_halfHourTimes.contains(result)) {
      _onTimeChanged(result);
    }
  }

  void _onLessonSizeChanged(int value) {
    setState(() => _dailyLessonSize = value);
    logger.i('Tamanho da lição diária: $value palavras');
  }

  void _onLanguageChanged(String value) {
    setState(() => _language = value);
    logger.i('Idioma selecionado: $_language');
  }

  void _saveSettings() {
    logger.i('Salvar configurações: notifications=$_notificationsEnabled, '
        'notificationTime=$_notificationTime, darkMode=$_darkMode, '
        'dailyLessonSize=$_dailyLessonSize, language=$_language');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Configurações salvas')),
    );
  }

  Widget _buildLessonSizeButtons(BuildContext context) {
    final theme = Theme.of(context);
    final selectedColor = theme.colorScheme.primary;
    final unselectedBg = Colors.grey.shade200;
    final unselectedFg = Colors.black87;

    Widget buildButton(int value) {
      final isSelected = _dailyLessonSize == value;
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6.0),
          child: ElevatedButton(
            onPressed: () => _onLessonSizeChanged(value),
            style: ElevatedButton.styleFrom(
              backgroundColor: isSelected ? selectedColor : unselectedBg,
              foregroundColor: isSelected ? Colors.white : unselectedFg,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text('$value', style: const TextStyle(fontSize: 16)),
          ),
        ),
      );
    }

    return Row(children: [buildButton(5), buildButton(10), buildButton(15)]);
  }

  Widget _buildLanguageButtons(BuildContext context) {
    final theme = Theme.of(context);
    final selectedColor = theme.colorScheme.primary;
    final unselectedBg = Colors.grey.shade200;
    final unselectedFg = Colors.black87;
    final options = ['Espanhol', 'Francês', 'Inglês'];

    Widget buildButton(String value) {
      final isSelected = _language == value;
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6.0),
          child: ElevatedButton(
            onPressed: () => _onLanguageChanged(value),
            style: ElevatedButton.styleFrom(
              backgroundColor: isSelected ? selectedColor : unselectedBg,
              foregroundColor: isSelected ? Colors.white : unselectedFg,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(value,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14)),
          ),
        ),
      );
    }

    return Row(children: options.map(buildButton).toList());
  }

  @override
  Widget build(BuildContext context) {
    final enabled = _notificationsEnabled;
    const sectionSpacing = 18.0;
    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 28),
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 8.0, bottom: 18.0),
          child: Text('Configurações',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ),

        // Notificações com subtitle
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Notificações'),
          subtitle: const Text('Habilitar/Desabilitar Notificações'),
          value: _notificationsEnabled,
          onChanged: _onNotificationsChanged,
        ),

        const SizedBox(height: sectionSpacing),

        // Linha inteira fica "desativada" (efeito cinza) quando notifications off
        IgnorePointer(
          ignoring: !enabled,
          child: Opacity(
            opacity: enabled ? 1.0 : 0.5,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
              decoration: BoxDecoration(
                color: enabled ? Colors.transparent : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  const Expanded(
                      child: Text('Horário de Notificação',
                          style: TextStyle(fontSize: 16))),
                  GestureDetector(
                    onTap: _openTimeSelector,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 10.0),
                      decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(6)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ConstrainedBox(
                              constraints:
                                  BoxConstraints(minWidth: 56, maxWidth: 96),
                              child: Text(_notificationTime,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: enabled
                                          ? Colors.black87
                                          : Colors.grey.shade600,
                                      fontSize: 16))),
                          const SizedBox(width: 8),
                          Icon(Icons.expand_more,
                              size: 22,
                              color: enabled
                                  ? Colors.black54
                                  : Colors.grey.shade600),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: sectionSpacing),

        const Divider(height: 1),

        const SizedBox(height: sectionSpacing - 6),

        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Modo Noturno'),
          subtitle: const Text('Habilitar/Desabilitar modo noturno'),
          value: _darkMode,
          onChanged: _onDarkModeChanged,
        ),

        const SizedBox(height: sectionSpacing),

        const Padding(
            padding: EdgeInsets.only(bottom: 10.0), child: Text('Idioma')),
        _buildLanguageButtons(context),

        const SizedBox(height: sectionSpacing),

        const Padding(
            padding: EdgeInsets.only(bottom: 10.0),
            child: Text('Tamanho da lição diária')),
        _buildLessonSizeButtons(context),

        const SizedBox(height: 8),

        Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
          child: Text('Limite máximo: 15 palavras por lição',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center),
        ),

        const SizedBox(height: 24),

        Center(
          child: SizedBox(
            width: 220,
            child: ElevatedButton(
              onPressed: _saveSettings,
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14)),
              child: const Text('Salvar Configurações'),
            ),
          ),
        ),
      ],
    );
  }
}
