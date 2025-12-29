import 'dart:math';

class GeminiService {
  static Future<String> getFocusSuggestion() async {
    await Future.delayed(const Duration(seconds: 1)); // simulate AI thinking

    final suggestions = [
      "Recommended Focus Time: 25 minutes\n\n💡 Tip: Short, focused sessions boost concentration. Stay disciplined!",
      "Recommended Focus Time: 45 minutes\n\n🔥 Motivation: Deep focus now means more free time later.",
      "Recommended Focus Time: 60 minutes\n\n🚀 Advice: Silence notifications and commit fully. You’ve got this!",
      "Recommended Focus Time: 30 minutes\n\n🎯 Tip: Small wins lead to big success. Start strong!",
    ];

    return suggestions[Random().nextInt(suggestions.length)];
  }
}
