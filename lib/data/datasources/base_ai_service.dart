import '../../domain/entities/recipe.dart';

abstract class BaseAIService {
  Future<String> explainSteps(List<String> steps);
  Future<String> generateRecipeFromIngredients(List<String> ingredients);
  Future<String> suggestHealthyAlternatives(String recipeName, List<String> ingredients);
  Future<String> getCalorieAwarenessTips(Recipe recipe);
}
