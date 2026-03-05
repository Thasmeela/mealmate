import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../domain/entities/recipe.dart';
import 'base_ai_service.dart';

import '../../core/constants/api_keys.dart';

class GeminiService implements BaseAIService {
  static const String _apiKey = ApiKeys.geminiApiKey;

  final GenerativeModel _model;

  GeminiService()
      : _model = GenerativeModel(
          model: 'gemini-1.5-flash',
          apiKey: _apiKey,
        );

  Future<String> explainSteps(List<String> steps) async {
    if (_apiKey == 'YOUR_GEMINI_API_KEY') {
      return "Cooking is easy! Just take your time with each step. For beginners, the key is to have all ingredients prepped before you start heat. You're doing great!";
    }
    final prompt =
        "Explain these cooking steps in very simple language for a beginner: ${steps.join('\n')}";
    final content = [Content.text(prompt)];
    try {
      final response = await _model.generateContent(content);
      return response.text ?? "Sorry, I couldn't explain the steps right now.";
    } catch (e) {
      debugPrint("Gemini Error in explainSteps: $e");
      return "I'm having trouble explaining the steps right now. Just follow them as listed!";
    }
  }

  Future<String> generateRecipeFromIngredients(List<String> ingredients) async {
    if (_apiKey == 'YOUR_GEMINI_API_KEY') {
      // Return a mock response if API key is not set
      await Future.delayed(const Duration(seconds: 2));
      return jsonEncode({
        "name": "Healthy ${ingredients.first} Medley",
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
    final content = [Content.text(prompt)];
    try {
      final response = await _model.generateContent(content);
      return response.text ?? "{}";
    } catch (e) {
      debugPrint("Gemini Error: $e");
      return "{}";
    }
  }

  Future<String> suggestHealthyAlternatives(
      String recipeName, List<String> ingredients) async {
    if (_apiKey == 'YOUR_GEMINI_API_KEY') {
      return "Since you're in demo mode, try substituting processed grains with quinoa or brown rice for a healthier touch!";
    }
    final prompt =
        "Suggest healthy alternatives for the ingredients in this recipe \"$recipeName\": ${ingredients.join(', ')}";
    final content = [Content.text(prompt)];
    try {
      final response = await _model.generateContent(content);
      return response.text ?? "Sorry, I couldn't suggest alternatives right now.";
    } catch (e) {
      debugPrint("Gemini Error in alternatives: $e");
      return "I couldn't find alternatives right now. Focus on fresh, whole ingredients!";
    }
  }

  Future<String> getCalorieAwarenessTips(Recipe recipe) async {
    if (_apiKey == 'YOUR_GEMINI_API_KEY') {
      return "This dish looks great! To keep it light, focus on portion control and use olive oil instead of butter.";
    }
    final prompt =
        "Provide calorie awareness tips for this dish: ${recipe.name}. It has ${recipe.caloriesPerServing} calories per serving. Mention portion control and light substitutions.";
    final content = [Content.text(prompt)];
    try {
      final response = await _model.generateContent(content);
      return response.text ?? "Sorry, I couldn't provide tips right now.";
    } catch (e) {
      debugPrint("Gemini Error in calorie tips: $e");
      return "To keep this healthy, watch your portions and enjoy!";
    }
  }

  @override
  Future<String> chat(String message, {Recipe? context}) async {
    if (_apiKey == 'YOUR_GEMINI_API_KEY') {
       return "That's a great question! For preparation, I always recommend 'mise en place'—getting all your ingredients chopped and measured before you start the heat.";
    }
    
    String contextInfo = context != null ? "Context: User is cooking ${context.name}." : "";
    final prompt = "You are a professional chef. $contextInfo Answer this question: $message";
    final content = [Content.text(prompt)];
    try {
      final response = await _model.generateContent(content);
      return response.text ?? "I'm here to help! What's your culinary question?";
    } catch (e) {
      return "I'm having trouble connecting to my chef brain right now. Try again in a moment!";
    }
  }
}
