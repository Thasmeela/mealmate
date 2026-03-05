import 'dart:convert';
import 'package:flutter/material.dart';
import '../../data/datasources/groq_service.dart';
import '../../data/datasources/base_ai_service.dart';
import '../../domain/entities/recipe.dart';

class AIProvider extends ChangeNotifier {
  final BaseAIService _activeService = GroqService();

  bool _isLoading = false;
  String _aiResponse = '';
  String _stepExplanation = '';
  String _healthyAlternatives = '';
  String _calorieTips = '';
  Recipe? _generatedRecipe;

  bool get isLoading => _isLoading;
  String get aiResponse => _aiResponse;
  String get stepExplanation => _stepExplanation;
  String get healthyAlternatives => _healthyAlternatives;
  String get calorieTips => _calorieTips;
  Recipe? get generatedRecipe => _generatedRecipe;

  Future<void> explainSteps(List<String> steps) async {
    _setLoading(true);
    _stepExplanation = await _activeService.explainSteps(steps);
    _setLoading(false);
  }

  Future<void> generateRecipe(List<String> ingredients) async {
    _setLoading(true);
    _generatedRecipe = null;
    _aiResponse = '';

    try {
      final jsonString =
          await _activeService.generateRecipeFromIngredients(ingredients);

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
    _healthyAlternatives =
        await _activeService.suggestHealthyAlternatives(name, ingredients);
    _setLoading(false);
  }

  Future<void> getCalorieTips(Recipe recipe) async {
    _setLoading(true);
    _calorieTips = await _activeService.getCalorieAwarenessTips(recipe);
    _setLoading(false);
  }

  Future<String> sendMessage(String message, {Recipe? context}) async {
    _setLoading(true);
    final response = await _activeService.chat(message, context: context);
    _setLoading(false);
    return response;
  }

  void clearResponse() {
    _aiResponse = '';
    _stepExplanation = '';
    _healthyAlternatives = '';
    _calorieTips = '';
    _generatedRecipe = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
