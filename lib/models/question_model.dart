class Question {
  final String questionText;
  final List<AnswerOption> options;

  Question({required this.questionText, required this.options});
}

class AnswerOption {
  final String optionText;
  final String skinType;
  final List<String> recommendedIngredients;

  AnswerOption({
    required this.optionText,
    required this.skinType,
    required this.recommendedIngredients,
  });
}
