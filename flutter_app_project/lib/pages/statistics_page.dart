import 'package:flutter/material.dart';
import '../utils/stats_db.dart';
import '../models/practice_stat.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
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

  Widget _buildStatCard(String title, String value,
      {IconData? icon, Color? color}) {
    return Card(
      child: ListTile(
        leading: icon != null ? Icon(icon, color: color ?? Colors.blue) : null,
        title: Text(title,
            style: const TextStyle(fontSize: 14, color: Colors.black54)),
        subtitle: Text(value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      ),
    );
  }

  // simples "grafico" de barras horizontais para últimas sessões
  Widget _buildRecentBars(List<PracticeStat> recent) {
    if (recent.isEmpty) return const SizedBox.shrink();
    final maxPercent =
        recent.map((s) => s.percent).fold<double>(0.0, (p, e) => e > p ? e : p);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text('Últimas sessões',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ),
        ...recent.map((s) {
          final wFactor = (maxPercent <= 0) ? 0.0 : (s.percent / maxPercent);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Row(
              children: [
                SizedBox(
                  width: 120,
                  child: Text('${_formatTimestamp(s.timestamp)}',
                      style: const TextStyle(fontSize: 12)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        height: 22,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: wFactor.clamp(0.02, 1.0),
                        child: Container(
                          height: 22,
                          decoration: BoxDecoration(
                            color: s.percent >= 70
                                ? Colors.green.shade600
                                : (s.percent >= 40
                                    ? Colors.orange.shade600
                                    : Colors.red.shade600),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          alignment: Alignment.centerLeft,
                          child: Text('${s.percent.toStringAsFixed(0)}%',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
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
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Nenhum registro ainda',
                    style: TextStyle(fontSize: 16)),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _load,
                  child: const Text('Atualizar'),
                ),
              ],
            ),
          );
        }

        // cálculos agregados
        final totalSessions = stats.length;
        final avgPercent =
            stats.map((s) => s.percent).fold<double>(0.0, (p, e) => p + e) /
                totalSessions;
        final best = stats.reduce((a, b) => a.percent >= b.percent ? a : b);
        final worst = stats.reduce((a, b) => a.percent <= b.percent ? a : b);

        // distribuição por idioma
        final Map<String, int> byLang = {};
        for (var s in stats) {
          byLang[s.language] = (byLang[s.language] ?? 0) + 1;
        }
        final langEntries = byLang.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        // últimas 7 sessões
        final recent = stats.take(7).toList();

        return RefreshIndicator(
          onRefresh: () async {
            setState(_load);
            await _futureStats;
          },
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Estatísticas',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                  IconButton(
                      icon: const Icon(Icons.delete_sweep),
                      onPressed: _confirmClearAll,
                      tooltip: 'Apagar todo o histórico'),
                ],
              ),
              const SizedBox(height: 8),
              _buildStatCard('Sessões totais', '$totalSessions',
                  icon: Icons.history),
              _buildStatCard(
                  'Média de acerto', '${avgPercent.toStringAsFixed(1)}%',
                  icon: Icons.show_chart),
              _buildStatCard('Melhor sessão',
                  '${best.percent.toStringAsFixed(1)}% • ${best.correct}/${best.total}',
                  icon: Icons.emoji_events, color: Colors.amber),
              _buildStatCard('Pior sessão',
                  '${worst.percent.toStringAsFixed(1)}% • ${worst.correct}/${worst.total}',
                  icon: Icons.warning_amber_rounded, color: Colors.red),
              const SizedBox(height: 12),
              if (langEntries.isNotEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Sessões por idioma',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        ...langEntries.map((e) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [Text(e.key), Text('${e.value}')],
                              ),
                            )),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              _buildRecentBars(recent),
              const SizedBox(height: 20),
              const Text('Histórico completo',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              ...stats.map((s) => Card(
                    child: ListTile(
                      title: Text(
                          '${s.percent.toStringAsFixed(1)}% • ${s.correct}/${s.total}'),
                      subtitle: Text(
                          '${s.language} • ${_formatTimestamp(s.timestamp)}'),
                    ),
                  )),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }
}
