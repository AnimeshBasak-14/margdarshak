enum Sender { user, assistant }

/// How a key number should read: plain, a deadline to watch, or good news.
enum FactTone { neutral, review, success }

/// A big-number callout under an assistant reply, e.g. "3 days" / "left to
/// apply".
class KeyFact {
  final String value;
  final String label;
  final FactTone tone;

  const KeyFact(this.value, this.label, {this.tone = FactTone.neutral});
}

class ChatMessage {
  final Sender sender;
  final String text;
  final List<KeyFact> facts;

  const ChatMessage.user(this.text)
      : sender = Sender.user,
        facts = const [];

  const ChatMessage.assistant(this.text, {this.facts = const []})
      : sender = Sender.assistant;
}

/// Something the assistant emits while answering: a visible pipeline stage,
/// then the reply itself.
sealed class AssistantEvent {
  const AssistantEvent();
}

class StageEvent extends AssistantEvent {
  final String label;
  const StageEvent(this.label);
}

class ReplyEvent extends AssistantEvent {
  final ChatMessage message;
  const ReplyEvent(this.message);
}
