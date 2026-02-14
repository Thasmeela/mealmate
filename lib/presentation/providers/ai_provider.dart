import 'package:flutter/material.dart';
import '../../data/datasources/gemini_service.dart';
import '../../domain/entities/recipe.dart';

class AIProvider extends ChangeNotifier {
  final GeminiService _geminiService = GeminiService();
  bool _isLoading = false;
  String _aiResponse = '';

  bool get isLoading => _isLoading;
  String get aiResponse => _aiResponse;

  Future<void> explainSteps(List<String> steps) async {
    _setLoading(true);
    _aiResponse = await _geminiService.explainSteps(steps);
    _setLoading(false);
  }

  Future<void> generateRecipe(List<String> ingredients) async {
    _setLoading(true);
    _aiResponse =
        await _geminiService.generateRecipeFromIngredients(ingredients);
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
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
