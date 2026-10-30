import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/session.dart';
import 'data/assistant_service.dart';
import 'models.dart';

/// Holds one conversation and the live pipeline stage while a reply is
/// being prepared.
class ChatController extends ChangeNotifier {
  final AssistantService service;
  ChatController(this.service);

  final List<ChatMessage> messages = [];

  /// Current stage label ("Translating from Hindi…"), or null when idle.
  String? stage;
  bool get busy => stage != null;

  StreamSubscription<AssistantEvent>? _pending;

  void send(String text, AppLanguage language) {
    final query = text.trim();
    if (query.isEmpty || busy) return;

    messages.add(ChatMessage.user(query));
    stage = '';
    notifyListeners();

    _pending = service.ask(query, language).listen(
      (event) {
        switch (event) {
          case StageEvent(:final label):
            stage = label;
          case ReplyEvent(:final message):
            messages.add(message);
            stage = null;
        }
        notifyListeners();
      },
      onError: (Object _) {
        messages.add(const ChatMessage.assistant(
            DemoAssistantService.fallback));
        stage = null;
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _pending?.cancel();
    super.dispose();
  }
}
