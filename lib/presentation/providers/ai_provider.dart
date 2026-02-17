import 'dart:convert';
import 'package:flutter/material.dart';
import '../../data/datasources/gemini_service.dart';
import '../../domain/entities/recipe.dart';

class AIProvider extends ChangeNotifier {
  final GeminiService _geminiService = GeminiService();
  bool _isLoading = false;
  String _aiResponse = '';
  Recipe? _generatedRecipe;

  bool get isLoading => _isLoading;
  String get aiResponse => _aiResponse;
  Recipe? get generatedRecipe => _generatedRecipe;

  Future<void> explainSteps(List<String> steps) async {
    _setLoading(true);
    _aiResponse = await _geminiService.explainSteps(steps);
    _setLoading(false);
  }

  Future<void> generateRecipe(List<String> ingredients) async {
    _setLoading(true);
    _generatedRecipe = null;
    _aiResponse = '';

    try {
      final jsonString =
          await _geminiService.generateRecipeFromIngredients(ingredients);

      // Clean up markdown code blocks if present
      String cleanJson = jsonString;
      if (cleanJson.contains('```json')) {
        cleanJson = cleanJson.replaceAll('```json', '').replaceAll('```', '');
      } else if (cleanJson.contains('```')) {
        cleanJson = cleanJson.replaceAll('```', '');
      }

      final Map<String, dynamic> data = jsonDecode(cleanJson);

      _generatedRecipe = Recipe(
        id: DateTime.now().millisecondsSinceEpoch, // temporary ID
        name: data['name'] ?? 'AI Recipe',
        ingredients: List<String>.from(data['ingredients'] ?? []),
        instructions: List<String>.from(data['instructions'] ?? []),
        prepTimeMinutes: data['prepTimeMinutes'] ?? 0,
        cookTimeMinutes: data['cookTimeMinutes'] ?? 0,
        servings: 2, // Default
        difficulty: data['difficulty'] ?? 'Medium',
        cuisine: data['cuisine'] ?? 'Fusion',
        caloriesPerServing: data['caloriesPerServing'] ?? 0,
        tags: [],
        userId: 'ai',
        image:
            'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?q=80&w=1000&auto=format&fit=crop', // Generic food image
        rating: 0,
        reviewCount: 0,
        mealType: [],
        isUserGenerated: false,
      );
    } catch (e) {
      _aiResponse =
          "I couldn't generate a recipe. Please try again with different ingredients.";
      debugPrint("Error parsing recipe: $e");
    }

    _setLoading(false);
  }

  Future<void> suggestAlternatives(
      String name, List<String> ingredients) async {
    _setLoading(true);
    _aiResponse =
        await _geminiService.suggestHealthyAlternatives(name, ingredients);
    _setLoading(false);
  }

  Future<void> calorieTips(Recipe recipe) async {
    _setLoading(true);
    _aiResponse = await _geminiService.getCalorieAwarenessTips(recipe);
    _setLoading(false);
  }

  void clearResponse() {
    _aiResponse = '';
    _generatedRecipe = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
