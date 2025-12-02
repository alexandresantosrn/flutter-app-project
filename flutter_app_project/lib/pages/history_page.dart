import 'package:flutter/material.dart';
import '../utils/stats_db.dart';
import '../models/practice_stat.dart';
import '../utils/config_logger.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late Future<List<PracticeStat>> _futureStats;

  @override
  void initState() {
    super.initState();
    logger.i('HistoryPage.initState');
    _load();
  }

  void _load() {
    logger.d('HistoryPage._load: iniciando carregamento de histórico do DB');
    _futureStats = StatsDb.getAllStats();
  }

  String _formatTimestamp(int ts) {
    final dt = DateTime.fromMillisecondsSinceEpoch(ts).toLocal();
    final date =
        '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    final time =
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    return '$date • $time';
  }

  Future<void> _confirmClearAll() async {
    logger.d(
        'HistoryPage._confirmClearAll: solicitando confirmação para apagar todo histórico');
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Apagar histórico'),
        content: const Text(
            'Deseja apagar todo o histórico de sessões? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(c).pop(false),
              child: const Text('Cancelar')),
          ElevatedButton(
              onPressed: () => Navigator.of(c).pop(true),
              child: const Text('Apagar')),
        ],
      ),
    );
    if (ok == true) {
      logger.i(
          'HistoryPage._confirmClearAll -> usuário confirmou apagar todo histórico');
      await StatsDb.clearAll();
      logger.d('HistoryPage._confirmClearAll -> histórico apagado com sucesso');
      setState(_load);
    } else {
      logger.d('HistoryPage._confirmClearAll -> usuário cancelou a ação');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PracticeStat>>(
      future: _futureStats,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          logger.d(
              'HistoryPage.build: aguardando dados (state=${snap.connectionState})');
          return const Center(child: CircularProgressIndicator());
        }
        final stats = snap.data ?? [];

        if (stats.isEmpty) {
          logger.d('HistoryPage.build: nenhum registro no histórico');
          // sem histórico: apenas mensagem central (sem título)
          return const Center(
            child:
                Text('Nenhum histórico ainda', style: TextStyle(fontSize: 16)),
          );
        }

        logger.i('HistoryPage.build: ${stats.length} registros carregados');
        // quando há histórico, mostra cabeçalho + lista (titulo exibido aqui)
        return RefreshIndicator(
          onRefresh: () async {
            logger.d('HistoryPage.onRefresh: atualização iniciada');
            setState(_load);
            await _futureStats;
            logger.d('HistoryPage.onRefresh: atualização concluída');
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: stats.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                // header exibido somente quando há histórico
                return Column(
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Histórico',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w700),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        ConstrainedBox(
                          constraints: const BoxConstraints.tightFor(
                              width: 40, height: 40),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            iconSize: 22,
                            icon: const Icon(Icons.delete_sweep),
                            onPressed: () {
                              logger.d(
                                  'HistoryPage: botão apagar todo histórico pressionado');
                              _confirmClearAll();
                            },
                            tooltip: 'Apagar todo o histórico',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                );
              }

              final s = stats[index - 1];
              return Card(
                child: ListTile(
                  title: Text(
                      '${s.percent.toStringAsFixed(1)}% • ${s.correct}/${s.total}'),
                  subtitle:
                      Text('${s.language} • ${_formatTimestamp(s.timestamp)}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () async {
                      if (s.id != null) {
                        logger.i('HistoryPage: excluindo stat id=${s.id}');
                        await StatsDb.deleteStat(s.id!);
                        logger.d('HistoryPage: stat id=${s.id} excluído');
                        setState(_load);
                      } else {
                        logger.w(
                            'HistoryPage: tentativa de excluir stat sem id (ignorado)');
                      }
                    },
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
