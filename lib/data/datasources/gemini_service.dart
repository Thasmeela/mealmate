import 'package:google_generative_ai/google_generative_ai.dart';
import '../../domain/entities/recipe.dart';

class GeminiService {
  // TODO: Replace with your actual Gemini API Key
  static const String _apiKey = 'YOUR_GEMINI_API_KEY';

  final GenerativeModel _model;

  GeminiService()
      : _model = GenerativeModel(
          model: 'gemini-1.5-flash',
          apiKey: _apiKey,
        );

  Future<String> explainSteps(List<String> steps) async {
    final prompt =
        "Explain these cooking steps in very simple language for a beginner: ${steps.join('\n')}";
    final content = [Content.text(prompt)];
    final response = await _model.generateContent(content);
    return response.text ?? "Sorry, I couldn't explain the steps right now.";
  }

  Future<String> generateRecipeFromIngredients(List<String> ingredients) async {
    final prompt =
        "Generate a simple healthy recipe using these ingredients: ${ingredients.join(', ')}. Include title, ingredients, and steps.";
    final content = [Content.text(prompt)];
    final response = await _model.generateContent(content);
    return response.text ?? "Sorry, I couldn't generate a recipe right now.";
  }

  Future<String> suggestHealthyAlternatives(
      String recipeName, List<String> ingredients) async {
    final prompt =
        "Suggest healthy alternatives for the ingredients in this recipe \"$recipeName\": ${ingredients.join(', ')}";
    final content = [Content.text(prompt)];
    final response = await _model.generateContent(content);
    return response.text ?? "Sorry, I couldn't suggest alternatives right now.";
  }

  Future<String> getCalorieAwarenessTips(Recipe recipe) async {
    final prompt =
        "Provide calorie awareness tips for this dish: ${recipe.name}. It has ${recipe.caloriesPerServing} calories per serving. Mention portion control and light substitutions.";
    final content = [Content.text(prompt)];
    final response = await _model.generateContent(content);
    return response.text ?? "Sorry, I couldn't provide tips right now.";
  }
}
