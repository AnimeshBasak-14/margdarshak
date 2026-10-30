import '../../../core/session.dart';
import '../models.dart';

/// Answers a question, reporting each pipeline stage as it goes
/// (translate → search → generate) so the UI can show what is happening.
///
/// The real implementation sits on Bhashini (ASR, translation, TTS) and the
/// RAG-backed assistant; [DemoAssistantService] stands in until then.
abstract class AssistantService {
  Stream<AssistantEvent> ask(String query, AppLanguage language);
}

/// Canned answers so the screens can be built and demoed without a backend.
/// Profile and exam figures below are sample data, not real notifications.
class DemoAssistantService implements AssistantService {
  const DemoAssistantService();

  static const _pause = Duration(milliseconds: 900);

  /// Spoken back verbatim when the context doesn't cover the question.
  static const fallback =
      "I'm sorry, I don't have that specific information right now. "
      'Please check the official notification document.';

  @override
  Stream<AssistantEvent> ask(String query, AppLanguage language) async* {
    final topic = _Topic.match(query);

    if (language.needsTranslation) {
      yield StageEvent('Translating from ${language.englishName}…');
      await Future<void>.delayed(_pause);
    }
    yield StageEvent(topic == null
        ? 'Searching notifications…'
        : 'Searching notifications for ${topic.exam}…');
    await Future<void>.delayed(_pause);
    yield const StageEvent('Generating response…');
    await Future<void>.delayed(_pause);

    yield ReplyEvent(topic?.reply ?? const ChatMessage.assistant(fallback));
  }
}

class _Topic {
  final String exam;
  final List<String> keywords;
  final ChatMessage reply;

  const _Topic(this.exam, this.keywords, this.reply);

  static _Topic? match(String query) {
    final q = query.toLowerCase();
    for (final t in _topics) {
      if (t.keywords.any(q.contains)) return t;
    }
    return null;
  }

  static const _topics = [
    _Topic(
      'BPSC',
      ['bpsc', 'bihar', 'another state', 'other state', 'domicile'],
      ChatMessage.assistant(
        'Yes, you can apply to BPSC from another state, but you will be '
        'treated as General category. Caste reservation and the 35% women\'s '
        'quota are only for permanent residents of Bihar.',
        facts: [
          KeyFact('Unreserved', 'Your category from outside Bihar'),
          KeyFact('35%', 'Women\'s quota, Bihar domicile only'),
        ],
      ),
    ),
    _Topic(
      'SSC CGL',
      ['negative', 'marking', 'penalty'],
      ChatMessage.assistant(
        'In SSC CGL Tier 1 you get two marks for a right answer and lose half '
        'a mark for a wrong one. In Tier 2 Paper 1 it is three marks for a '
        'right answer and minus one for a wrong one, so skip guesses there.',
        facts: [
          KeyFact('−0.50', 'Per wrong answer, Tier 1'),
          KeyFact('−1.00', 'Per wrong answer, Tier 2', tone: FactTone.review),
        ],
      ),
    ),
    _Topic(
      'banking exams',
      ['bank', 'niacl', 'uiic', 'insurance', '1000'],
      ChatMessage.assistant(
        'Two insurance officer exams are open with large intakes: NIACL AO '
        'and UIIC AO. Both cut a quarter mark per wrong answer and have '
        'sectional cut-offs, so you need to clear every section.',
        facts: [
          KeyFact('2', 'Open exams over 1,000 posts'),
          KeyFact('−0.25', 'Per wrong answer'),
        ],
      ),
    ),
    _Topic(
      'SSC CGL',
      ['ssc', 'cgl', 'eligible', 'eligibility', 'age', 'पात्र'],
      ChatMessage.assistant(
        'Yes. Born in March 2001, you will be 25 on the crucial date of '
        '1 August 2026, which is inside the age limit for most CGL posts. '
        'Applications close in 3 days, so please apply soon.',
        facts: [
          KeyFact('25 yrs', 'Your age on 01.08.2026', tone: FactTone.success),
          KeyFact('3 days', 'Left to apply', tone: FactTone.review),
        ],
      ),
    ),
  ];
}
