import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../domain/entities/recipe.dart';
import 'base_ai_service.dart';

class GroqService implements BaseAIService {
  // TODO: Replace with your actual Groq API Key
  static const String _apiKey = '';
  static const String _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const String _model = 'llama3-8b-8192';

  Future<String> _callGroq(String prompt) async {
    if (_apiKey == '') {
      return "ERROR: MOCK_MODE";
    }

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {
              'role': 'system',
              'content': 'You are a helpful culinary AI assistant for MealMate.'
            },
            {'role': 'user', 'content': prompt}
          ],
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'] ?? "";
      } else {
        debugPrint("Groq API Error: ${response.statusCode} - ${response.body}");
        return "";
      }
    } catch (e) {
      debugPrint("Groq Connection Error: $e");
      return "";
    }
  }

  Future<String> explainSteps(List<String> steps) async {
    final prompt =
        "Explain these cooking steps in very simple language for a beginner: ${steps.join('\n')}";
    
    final result = await _callGroq(prompt);
    if (result == "ERROR: MOCK_MODE") {
      return "Cooking is easy! Just take your time with each step. For beginners, the key is to have all ingredients prepped before you start heat. You're doing great!";
    }
    return result.isNotEmpty ? result : "I'm having trouble explaining the steps right now. Just follow them as listed!";
  }

  Future<String> generateRecipeFromIngredients(List<String> ingredients) async {
    if (_apiKey == 'YOUR_GROQ_API_KEY') {
      await Future.delayed(const Duration(seconds: 2));
      return jsonEncode({
        "name": "Healthy ${ingredients.first} Medley (Groq Demo)",
        "ingredients": ingredients,
        "instructions": [
          "Wash the ${ingredients.first} thoroughly.",
          "Prepare other ingredients and mix them in a bowl.",
          "Season with salt and pepper to taste.",
          "Serve fresh and enjoy your healthy meal!"
        ],
        "caloriesPerServing": 320,
        "prepTimeMinutes": 10,
        "cookTimeMinutes": 15,
        "difficulty": "Easy",
        "cuisine": "Fusion"
      });
    }

    final prompt =
        "Generate a healthy recipe using these ingredients: ${ingredients.join(', ')}. Return ONLY a JSON object with these fields: name (string), ingredients (list of strings), instructions (list of strings), caloriesPerServing (int), prepTimeMinutes (int), cookTimeMinutes (int), difficulty (string), cuisine (string). Do not allow markdown formatting in the response.";

    final result = await _callGroq(prompt);
    return result.isNotEmpty ? result : "{}";
  }

  Future<String> suggestHealthyAlternatives(
      String recipeName, List<String> ingredients) async {
    final prompt =
        "Suggest healthy alternatives for the ingredients in this recipe \"$recipeName\": ${ingredients.join(', ')}";

    final result = await _callGroq(prompt);
    if (result == "ERROR: MOCK_MODE") {
      return "Since you're in demo mode with Groq, try substituting processed grains with quinoa or brown rice for a healthier touch!";
    }
    return result.isNotEmpty ? result : "I couldn't find alternatives right now. Focus on fresh, whole ingredients!";
  }

  Future<String> getCalorieAwarenessTips(Recipe recipe) async {
    final prompt =
        "Provide calorie awareness tips for this dish: ${recipe.name}. It has ${recipe.caloriesPerServing} calories per serving. Mention portion control and light substitutions.";

    final result = await _callGroq(prompt);
    if (result == "ERROR: MOCK_MODE") {
      return "This dish looks great! To keep it light, focus on portion control and use olive oil instead of butter.";
    }
    return result.isNotEmpty ? result : "To keep this healthy, watch your portions and enjoy!";
  }
}
