import 'package:flutter/material.dart';
import '../utils/stats_db.dart';
import '../models/practice_stat.dart';

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
    _load();
  }

  void _load() {
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
      await StatsDb.clearAll();
      setState(_load);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PracticeStat>>(
      future: _futureStats,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final stats = snap.data ?? [];

        if (stats.isEmpty) {
          // sem histórico: apenas mensagem central (sem título)
          return const Center(
            child:
                Text('Nenhum histórico ainda', style: TextStyle(fontSize: 16)),
          );
        }

        // quando há histórico, mostra cabeçalho + lista (titulo exibido aqui)
        return RefreshIndicator(
          onRefresh: () async {
            setState(_load);
            await _futureStats;
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
                            onPressed: _confirmClearAll,
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
                      await StatsDb.deleteStat(s.id!);
                      setState(_load);
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
