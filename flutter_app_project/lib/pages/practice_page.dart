import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/config_logger.dart';
import '../utils/preferences_service.dart';
import '../utils/quiz_card.dart';
import '../utils/seed_questions.dart';
import '../utils/stats_db.dart';
import '../models/practice_stat.dart';

class PracticePage extends StatefulWidget {
  const PracticePage({super.key});

  @override
  State<PracticePage> createState() => _PracticePageState();
}

class _PracticePageState extends State<PracticePage> {
  late int _totalQuestions;
  late String _language;
  List<Question> _allSeed = [];
  List<Question> _sessionQuestions = [];
  // cache de opções por pergunta (gera uma vez por sessão)
  List<List<String>> _optionsCache = [];
  List<int> _correctIndexCache = [];

  int _currentIndex = 0;
  int _correct = 0;
  int? _selectedOptionIndex;
  bool _loading = true;
  bool _finished = false;
  bool _savedStat = false;

  @override
  void initState() {
    super.initState();
    logger.i('Abrindo tela: Praticar');
    _allSeed = getSeedQuestions();
    _initQuiz();
  }

  Future<void> _initQuiz() async {
    setState(() {
      _loading = true;
      _finished = false;
      _currentIndex = 0;
      _correct = 0;
      _selectedOptionIndex = null;
      _optionsCache = [];
      _correctIndexCache = [];
    });

    _totalQuestions = PreferencesService.dailyLessonSize;
    _language = PreferencesService.language;

    // seleciona sem repetição a partir do seed
    _sessionQuestions = getRandomSeedSubset(_totalQuestions);

    // prepara cache de opções e índices corretos — gerado apenas uma vez
    _prepareOptionsCache();

    setState(() {
      _loading = false;
    });
  }

  // Gera e armazena as 4 opções (1 correta + 3 distratores) para cada pergunta da sessão.
  void _prepareOptionsCache() {
    _optionsCache = List.generate(_sessionQuestions.length, (i) => <String>[]);
    _correctIndexCache = List.generate(_sessionQuestions.length, (i) => -1);

    // constroi pool global de traduções (sem duplicatas)
    final allTranslations = <String>{};
    for (var s in _allSeed) {
      final t = s.translations[_language];
      if (t != null && t.isNotEmpty) allTranslations.add(t);
    }

    // remove as traduções CORRETAS da sessão para evitar que sejam usadas como distratores
    for (var q in _sessionQuestions) {
      final corr = q.translations[_language] ?? '';
      if (corr.isNotEmpty) allTranslations.remove(corr);
    }

    final globalPoolBase = allTranslations.toList();
    final rnd = Random();
    final pool =
        <String>[]; // mutable pool usado e reabastecido quando necessário

    // função para reabastecer pool (mantendo ordem aleatória)
    void refillPool() {
      pool
        ..clear()
        ..addAll(List<String>.from(globalPoolBase)..shuffle(rnd));
    }

    // inicializa pool
    refillPool();

    for (var i = 0; i < _sessionQuestions.length; i++) {
      final q = _sessionQuestions[i];
      final correct = q.translations[_language] ?? '';
      final distractors = <String>[];

      // garante pool suficiente; se pequeno, reabastece
      if (pool.length < 3) refillPool();

      // escolhe distratores do pool sem reposição
      pool.shuffle(rnd);
      for (var candidate in List<String>.from(pool)) {
        if (distractors.length >= 3) break;
        if (candidate == correct) continue;
        distractors.add(candidate);
        pool.remove(
            candidate); // evita repetir esse distrator em outras perguntas
      }

      // se ainda faltar, completa a partir do seed completo (sem duplicatas)
      if (distractors.length < 3) {
        final extras = _allSeed
            .map((s) => s.translations[_language])
            .whereType<String>()
            .where(
                (t) => t.isNotEmpty && t != correct && !distractors.contains(t))
            .toList()
          ..shuffle(rnd);
        for (var e in extras) {
          if (distractors.length >= 3) break;
          distractors.add(e);
        }
      }

      final options = <String>[correct, ...distractors]..shuffle(rnd);
      _optionsCache[i] = options;
      _correctIndexCache[i] = options.indexOf(correct);
    }
  }

  // retorna opções já cacheadas para a pergunta atual
  List<String> _buildOptionsForCurrent() {
    if (_optionsCache.isEmpty) return <String>[];
    return _optionsCache[_currentIndex];
  }

  void _onOptionSelected(int idx) {
    if (_selectedOptionIndex != null) return;
    final correctIdx = _correctIndexCache[_currentIndex];
    final isCorrect = idx == correctIdx;

    setState(() {
      _selectedOptionIndex = idx;
      if (isCorrect) _correct++;
    });

    Timer(const Duration(milliseconds: 800), () async {
      if (_currentIndex + 1 >= _sessionQuestions.length) {
        setState(() {
          _finished = true;
        });
        // salva estatística apenas uma vez
        if (!_savedStat) {
          _savedStat = true;
          final stat = PracticeStat(
            timestamp: DateTime.now().millisecondsSinceEpoch,
            language: _language,
            total: _sessionQuestions.length,
            correct: _correct,
            percent: (_sessionQuestions.isNotEmpty)
                ? (_correct / _sessionQuestions.length) * 100.0
                : 0.0,
          );
          await StatsDb.insertStat(stat);
        }
      } else {
        setState(() {
          _currentIndex++;
          _selectedOptionIndex = null;
        });
      }
    });
  }

  double _scorePercent() {
    if (_sessionQuestions.isEmpty) return 0.0;
    return (_correct / _sessionQuestions.length) * 100.0;
  }

  void _restart() {
    _initQuiz();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    if (_finished) {
      final pct = _scorePercent();
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Fim do Quiz',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 12),
              Text(
                  'Você acertou $_correct de ${_sessionQuestions.length} (${pct.toStringAsFixed(1)}%)',
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 18),
              ElevatedButton(
                  onPressed: _restart, child: const Text('Recomeçar')),
            ],
          ),
        ),
      );
    }

    if (_sessionQuestions.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Sem questões disponíveis',
                style: TextStyle(fontSize: 18)),
            const SizedBox(height: 12),
            ElevatedButton(
                onPressed: _restart, child: const Text('Carregar novamente')),
          ],
        ),
      );
    }

    final q = _sessionQuestions[_currentIndex];
    final options = _buildOptionsForCurrent();
    final correctIndex = _correctIndexCache[_currentIndex];

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Align(
              alignment: Alignment.centerLeft,
              child: Text(
                  'Pergunta ${_currentIndex + 1} / ${_sessionQuestions.length}',
                  style: const TextStyle(fontSize: 14))),
          const SizedBox(height: 12),
          QuizCard(
            portuguese: q.portuguese,
            options: options,
            selectedIndex: _selectedOptionIndex,
            correctIndex: _selectedOptionIndex == null ? null : correctIndex,
            enabled: _selectedOptionIndex == null,
            onOptionSelected: _onOptionSelected,
          ),
          const Spacer(),
          Align(
              alignment: Alignment.centerLeft,
              child: Text('Acertos: $_correct',
                  style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}
