import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart'; // novo
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
    logger.d(
        'PracticePage.initState -> seed questions carregadas: ${_allSeed.length}');
    _initQuiz();
  }

  Future<void> _initQuiz() async {
    logger.d('PracticePage._initQuiz -> iniciando nova sessão');
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
    logger.i(
        'PracticePage._initQuiz -> total=$_totalQuestions language=$_language');

    // seleciona sem repetição a partir do seed
    _sessionQuestions = getRandomSeedSubset(_totalQuestions);
    logger.d(
        'PracticePage._initQuiz -> sessão com ${_sessionQuestions.length} perguntas');

    // prepara cache de opções e índices corretos — gerado apenas uma vez
    _prepareOptionsCache();

    setState(() {
      _loading = false;
    });
    logger.d('PracticePage._initQuiz -> sessão pronta (loading=false)');
  }

  void _prepareOptionsCache() {
    logger.d('PracticePage._prepareOptionsCache -> preparando cache de opções');
    _optionsCache = List.generate(_sessionQuestions.length, (i) => <String>[]);
    _correctIndexCache = List.generate(_sessionQuestions.length, (i) => -1);

    // constroi pool global de traduções (sem duplicatas)
    final allTranslations = <String>{};
    for (var s in _allSeed) {
      final t = s.translations[_language];
      if (t != null && t.isNotEmpty) allTranslations.add(t);
    }
    logger.d(
        'PracticePage._prepareOptionsCache -> pool base size=${allTranslations.length}');

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
      logger.d(
          'PracticePage._prepareOptionsCache -> pool reabastecido (size=${pool.length})');
    }

    // inicializa pool
    refillPool();

    for (var i = 0; i < _sessionQuestions.length; i++) {
      final q = _sessionQuestions[i];
      final correct = q.translations[_language] ?? '';
      final distractors = <String>[];

      // garante pool suficiente; se pequeno, reabastece
      if (pool.length < 3) {
        refillPool();
      }

      // escolhe distratores do pool sem reposição
      pool.shuffle(rnd);
      for (var candidate in List<String>.from(pool)) {
        if (distractors.length >= 3) break;
        if (candidate == correct) continue;
        distractors.add(candidate);
        pool.remove(candidate);
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
      logger.d(
          'PracticePage._prepareOptionsCache -> pergunta[$i] options=${options.length} correctIndex=${_correctIndexCache[i]}');
    }

    logger.i(
        'PracticePage._prepareOptionsCache -> cache preparado para ${_optionsCache.length} perguntas');
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

    logger.i(
        'PracticePage._onOptionSelected -> pergunta=$_currentIndex selecionou=$idx correct=$correctIdx isCorrect=$isCorrect');

    // vibração/feedback háptico ao acertar
    if (isCorrect) {
      // Vibration plugin
      Vibration.hasVibrator().then((has) async {
        if (has == true) {
          try {
            final hasAmp = await Vibration.hasAmplitudeControl();
            if (hasAmp) {
              Vibration.vibrate(duration: 300, amplitude: 255);
            } else {
              Vibration.vibrate(duration: 300);
            }
            logger.d(
                'PracticePage._onOptionSelected -> Vibration.vibrate chamada (acerto)');
          } catch (e, st) {
            logger.w(
                'PracticePage._onOptionSelected -> erro ao chamar Vibration.vibrate',
                e,
                st);
          }
        } else {
          logger
              .d('PracticePage._onOptionSelected -> dispositivo sem vibrator');
        }
      }).catchError((e, st) {
        logger.w('PracticePage._onOptionSelected -> erro ao verificar vibrator',
            e, st);
      });
    }

    setState(() {
      _selectedOptionIndex = idx;
      if (isCorrect) _correct++;
    });

    Timer(const Duration(milliseconds: 800), () async {
      if (_currentIndex + 1 >= _sessionQuestions.length) {
        setState(() {
          _finished = true;
        });
        logger.i(
            'PracticePage -> sessão finalizada acertos=$_correct de ${_sessionQuestions.length}');

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
          try {
            logger.d(
                'PracticePage -> salvando stat: ${stat.percent.toStringAsFixed(1)}% language=${stat.language}');
            await StatsDb.insertStat(stat);
            logger.i('PracticePage -> stat salvo com sucesso');
          } catch (e, st) {
            logger.e('PracticePage -> erro ao salvar stat', e, st);
          }
        }
      } else {
        setState(() {
          _currentIndex++;
          _selectedOptionIndex = null;
        });
        logger.d('PracticePage -> avançando para pergunta ${_currentIndex}');
      }
    });
  }

  double _scorePercent() {
    if (_sessionQuestions.isEmpty) return 0.0;
    return (_correct / _sessionQuestions.length) * 100.0;
  }

  void _restart() {
    logger.i('PracticePage._restart -> reiniciando quiz');
    _initQuiz();
  }

  @override
  Widget build(BuildContext context) {
    logger.d(
        'PracticePage.build -> loading=$_loading finished=$_finished currentIndex=$_currentIndex');
    if (_loading) return const Center(child: CircularProgressIndicator());

    if (_finished) {
      final pct = _scorePercent();
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Fim do Quiz',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 12),
              Text('Você acertou $_correct de ${_sessionQuestions.length}',
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              Text('Percentual: ${pct.toStringAsFixed(1)}%',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final mq = MediaQuery.of(context);
        final availableHeight =
            constraints.maxHeight - mq.padding.top - mq.padding.bottom;

        // Thresholds ajustáveis:
        const compactThreshold = 520.0; // abaixo disso usamos layout compacto
        final isCompact = availableHeight < compactThreshold;

        // altura reservada para header + footer
        const headerApprox = 56.0;
        const footerApprox = 44.0;
        final reserved = headerApprox + footerApprox + 32.0; // +padding
        // altura máxima para o QuizCard em modo compacto
        final maxCardHeight =
            (availableHeight - reserved).clamp(120.0, availableHeight * 0.85);

        final header = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pergunta ${_currentIndex + 1} / ${_sessionQuestions.length}',
                style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 12),
          ],
        );

        final footer = Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Acertos: $_correct',
                  style: const TextStyle(fontSize: 16))),
        );

        final quizCard = QuizCard(
          portuguese: q.portuguese,
          options: options,
          selectedIndex: _selectedOptionIndex,
          correctIndex: _selectedOptionIndex == null ? null : correctIndex,
          enabled: _selectedOptionIndex == null,
          onOptionSelected: _onOptionSelected,
        );

        if (isCompact) {
          // modo compacto: não usar Expanded; limitar altura do card e permitir rolagem da página
          return SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    header,
                    ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: maxCardHeight),
                      child: quizCard,
                    ),
                    footer,
                  ],
                ),
              ),
            ),
          );
        } else {
          // modo normal: usar Expanded para que o card ocupe o espaço restante
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  header,
                  Expanded(child: quizCard),
                  footer,
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
