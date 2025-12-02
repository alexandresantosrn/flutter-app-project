import 'package:flutter/material.dart';
import '../utils/stats_db.dart';
import '../models/practice_stat.dart';
import '../utils/config_logger.dart';

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
    logger.i('StatisticsPage.initState');
    _load();
  }

  void _load() {
    logger.d('StatisticsPage._load: carregando estatísticas do DB');
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

  Widget _buildRecentBars(BuildContext ctx, List<PracticeStat> recent) {
    if (recent.isEmpty) return const SizedBox.shrink();
    final maxPercent =
        recent.map((s) => s.percent).fold<double>(0.0, (p, e) => e > p ? e : p);
    final screenW = MediaQuery.of(ctx).size.width;
    final tsWidth = (screenW * 0.35).clamp(80.0, 120.0);

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
                  width: tsWidth,
                  child: Text('${_formatTimestamp(s.timestamp)}',
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis),
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
    logger.d('StatisticsPage._confirmClearAll: solicitando confirmação');
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
          'StatisticsPage._confirmClearAll -> usuário confirmou apagar todo histórico');
      await StatsDb.clearAll();
      logger.d('StatisticsPage._confirmClearAll -> histórico apagado');
      setState(_load);
    } else {
      logger.d('StatisticsPage._confirmClearAll -> usuário cancelou a ação');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final tsWidth = (screenW * 0.35).clamp(80.0, 120.0);

    return FutureBuilder<List<PracticeStat>>(
      future: _futureStats,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          logger.d(
              'StatisticsPage.build: aguardando dados (connectionState=${snap.connectionState})');
          return const Center(child: CircularProgressIndicator());
        }
        final stats = snap.data ?? [];
        if (stats.isEmpty) {
          logger.d('StatisticsPage.build: sem registros de estatísticas');
          // sem botão de atualizar; apenas mensagem central
          return Center(
              child: Text('Nenhum registro ainda',
                  style: Theme.of(context).textTheme.bodyLarge));
        }

        logger.i('StatisticsPage.build: ${stats.length} registros carregados');
        final totalSessions = stats.length;
        final avgPercent =
            stats.map((s) => s.percent).fold<double>(0.0, (p, e) => p + e) /
                totalSessions;
        final best = stats.reduce((a, b) => a.percent >= b.percent ? a : b);
        final worst = stats.reduce((a, b) => a.percent <= b.percent ? a : b);

        logger.i(
            'Statistics computed -> total=$totalSessions avg=${avgPercent.toStringAsFixed(1)} best=${best.percent.toStringAsFixed(1)} worst=${worst.percent.toStringAsFixed(1)}');

        final Map<String, int> byLang = {};
        for (var s in stats) {
          byLang[s.language] = (byLang[s.language] ?? 0) + 1;
        }
        final langEntries = byLang.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        final recent = stats.take(7).toList();

        return RefreshIndicator(
          onRefresh: () async {
            logger.d('StatisticsPage.onRefresh: iniciando atualização');
            setState(_load);
            await _futureStats;
            logger.d('StatisticsPage.onRefresh: atualização concluída');
          },
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text('Estatísticas',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w700),
                        overflow: TextOverflow.ellipsis),
                  ),
                  ConstrainedBox(
                    constraints:
                        const BoxConstraints.tightFor(width: 40, height: 40),
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
              _buildRecentBars(context, recent),
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
