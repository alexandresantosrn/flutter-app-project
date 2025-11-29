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
          return const Center(child: Text('Nenhum histórico salvo'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: stats.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, idx) {
            final s = stats[idx];
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
        );
      },
    );
  }
}
