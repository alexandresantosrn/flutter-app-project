// Modelo que representa uma estatística de sessão de quiz.
class PracticeStat {
  final int? id;
  final int timestamp; // epoch ms
  final String language;
  final int total;
  final int correct;
  final double percent;

  PracticeStat({
    this.id,
    required this.timestamp,
    required this.language,
    required this.total,
    required this.correct,
    required this.percent,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp,
      'language': language,
      'total': total,
      'correct': correct,
      'percent': percent,
    };
  }

  factory PracticeStat.fromMap(Map<String, dynamic> m) {
    return PracticeStat(
      id: m['id'] as int?,
      timestamp: m['timestamp'] as int,
      language: m['language'] as String,
      total: m['total'] as int,
      correct: m['correct'] as int,
      percent: (m['percent'] as num).toDouble(),
    );
  }
}
